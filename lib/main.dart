import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:watch_hackaton/state_machine.dart';
// import 'package:sensors_plus/sensors_plus.dart';
import 'package:wear/wear.dart';
import 'package:workout/workout.dart';

void main() {
  runApp(const MyApp());
}

enum CharacterState { idle, walk, run, heighfive, jumping }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Controller for playback
  late RiveAnimationController _controller;
  late CharacterState _characterState = CharacterState.idle;

  @override
  void initState() {
    super.initState();

    _characterState = CharacterState.idle;

    setState(() {
      _controller = SimpleAnimation(animation);
    });
  }

  final workout = Workout();

  final exerciseType = ExerciseType.walking;
  final features = [
    WorkoutFeature.heartRate,
    WorkoutFeature.calories,
    WorkoutFeature.steps,
    WorkoutFeature.distance,
    WorkoutFeature.speed,
  ];
  final enableGps = true;

  double heartRate = 0;
  double calories = 0;
  double steps = 0;
  double distance = 0;
  double speed = 0;
  bool started = false;

  String accelerometer = "";
  String userAccelerometer = "";
  String gyroscope = "";
  String magnetometer = "";

  _MyAppState() {
    workout.stream.listen((event) {
      // ignore: avoid_print
      print('${event.feature}: ${event.value} (${event.timestamp})');
      switch (event.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            heartRate = event.value;
            if (heartRate > 120) {
              _characterState = CharacterState.jumping;
            } else if (heartRate <= 120 &&
                _characterState == CharacterState.jumping) {
              _characterState = CharacterState.heighfive;

              //todo: timeout for idle
            }
          });
          break;
        case WorkoutFeature.calories:
          setState(() {
            calories = event.value;
          });
          break;
        case WorkoutFeature.steps:
          setState(() {
            steps = event.value;
          });
          break;
        case WorkoutFeature.distance:
          setState(() {
            distance = event.value;
          });
          break;
        case WorkoutFeature.speed:
          setState(() {
            speed = event.value;
            if (speed > 1 && speed < 2) {
              _characterState = CharacterState.walk;
            } else if (speed >= 2) {
              _characterState = CharacterState.run;
            } else if (_characterState == CharacterState.walk ||
                _characterState == CharacterState.run) {
              _characterState = CharacterState.heighfive;

              //todo: timeout for idle
            }
          });
          break;
      }
    });

// //     accelerometerEvents.listen((AccelerometerEvent event) {
// //       print(event);
// //       setState(() {
// //         accelerometer = (event.x * 100).round().toString() +
// //             " " +
// //             (event.y * 100).round().toString() +
// //             " " +
// //             (event.z * 100).round().toString();
// //       });
// //     });
// // // [AccelerometerEvent (x: 0.0, y: 9.8, z: 0.0)]

// //     userAccelerometerEvents.listen((UserAccelerometerEvent event) {
// //       print(event);
// //       setState(() {
// //         userAccelerometer = (event.x * 100).round().toString() +
// //             " " +
// //             (event.y * 100).round().toString() +
// //             " " +
// //             (event.z * 100).round().toString();
// //       });
// //     });
// // // [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]

// //     gyroscopeEvents.listen((GyroscopeEvent event) {
// //       print(event);
// //       setState(() {
// //         gyroscope = (event.x * 100).round().toString() +
// //             " " +
// //             (event.y * 100).round().toString() +
// //             " " +
// //             (event.z * 100).round().toString();
// //       });
// //     });
// // // [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]

// //     magnetometerEvents.listen((MagnetometerEvent event) {
// //       print(event);
// //       setState(() {
// //         magnetometer = (event.x * 100).round().toString() +
// //             " " +
// //             (event.y * 100).round().toString() +
// //             " " +
// //             (event.z * 100).round().toString();
// //       });
//     });
  }

  String animation = 'Walk';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      // Use ambient mode to stay alive in the foreground
      // Use a foreground service if you want to stay alive in the background
      home: AmbientMode(
        builder: (context, mode, child) => child!,
        child: Scaffold(
          body: Center(
            child: Column(
              children: [
                // body: Center(
                //     child: RiveAnimation.asset(
                //   'assets/octocat.riv',
                //   animations: const ['Run', 'Walk'],
                //   controllers: [_controller],
                //   placeHolder: Icon(Icons.access_alarm),
                // )),
                // const Spacer(),
                // Text('${_characterState.name} '),
                // Text('HR: $heartRate AC: $accelerometer'),
                // Text(
                //     'Cal: ${calories.toStringAsFixed(2)} UAC: $userAccelerometer'),
                // Text('Step: $steps gyr: $gyroscope'),
                // Text('Dis: ${distance.toStringAsFixed(2)} MG: $magnetometer'),
                // Text('Speed: ${speed.toStringAsFixed(2)}'),
                StateMachineSkills(),
                const Spacer(),
                TextButton(
                  onPressed: toggleExerciseState,
                  child: Text(started ? 'Stop' : 'Start'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toggleExerciseState() async {
    setState(() {
      started = !started;
      _controller = SimpleAnimation('Walk');
    });

    if (started) {
      final supportedExerciseTypes = await workout.getSupportedExerciseTypes();
      // ignore: avoid_print
      print('Supported exercise types: ${supportedExerciseTypes.length}');

      final result = await workout.start(
        // In a real application, check the supported exercise types first
        exerciseType: exerciseType,
        features: features,
        enableGps: enableGps,
      );

      if (result.unsupportedFeatures.isNotEmpty) {
        // ignore: avoid_print
        print('Unsupported features: ${result.unsupportedFeatures}');
        // In a real application, update the UI to match
      } else {
        // ignore: avoid_print
        print('All requested features supported');
      }
    } else {
      await workout.stop();
    }
  }
}
