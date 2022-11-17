import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:watch_hackaton/state_machine.dart';
// import 'package:sensors_plus/sensors_plus.dart';
import 'package:wear/wear.dart';
import 'package:workout/workout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Controller for playback
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
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
              child:
                  StateMachineSkills() /*RiveAnimation.asset(
            'assets/octocat.riv',
            controllers: [_controller],
            placeHolder: Icon(Icons.access_alarm),
          )),*/
              ),
          // const Spacer(),
          // Text('HR: $heartRate AC: $accelerometer'),
          // Text(
          //     'Cal: ${calories.toStringAsFixed(2)} UAC: $userAccelerometer'),
          // Text('Step: $steps gyr: $gyroscope'),
          // Text('Dis: ${distance.toStringAsFixed(2)} MG: $magnetometer'),
          // Text('Speed: ${speed.toStringAsFixed(2)}'),
          // const Spacer(),
          // TextButton(
          //   onPressed: toggleExerciseState,
          //   child: Text(started ? 'Stop' : 'Start'),
          // ),
          // ],
          // ),
          // ),
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
