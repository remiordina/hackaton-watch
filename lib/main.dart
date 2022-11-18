import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
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
  late CharacterState _characterState = CharacterState.idle;
  bool get isPlaying => _controller?.isActive ?? false;

  final PageController pageController = PageController();

  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _levelInput;

  @override
  void initState() {
    super.initState();

    rootBundle.load('assets/octocat.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller =
            StateMachineController.fromArtboard(artboard, 'StateMachine');
        if (controller != null) {
          artboard.addController(controller);
          _levelInput = controller.findInput('State');
          _levelInput?.value = 0;
        }
        setState(() => _riveArtboard = artboard);
      },
    );

    _characterState = CharacterState.idle;
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
      switch (event.feature) {
        case WorkoutFeature.unknown:
          return;
        case WorkoutFeature.heartRate:
          setState(() {
            heartRate = event.value;
            if (heartRate > 105 && _characterState != CharacterState.jumping) {
              _characterState = CharacterState.jumping;
              _levelInput?.value = 2;
            } else if (heartRate <= 105 &&
                _characterState == CharacterState.jumping &&
                _characterState != CharacterState.heighfive) {
              _characterState = CharacterState.heighfive;
              //_levelInput?.value = 3;

              //todo: timeout for idle
              Future.delayed(const Duration(seconds: 10), () {
                setState(() {
                  _levelInput?.value = 0;
                });
              });
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
            if (speed > 1 &&
                speed < 2 &&
                _characterState != CharacterState.walk) {
              _characterState = CharacterState.walk;
              _levelInput?.value = 1;
            } else if (speed >= 2 && _characterState != CharacterState.run) {
              _characterState = CharacterState.run;
              _levelInput?.value = 4;
            } else if (_characterState == CharacterState.walk ||
                _characterState == CharacterState.run &&
                    _characterState != CharacterState.heighfive) {
              _characterState = CharacterState.heighfive;
              // _levelInput?.value = 3;
              //todo: timeout for idle
              Future.delayed(const Duration(seconds: 10), () {
                setState(() {
                  _levelInput?.value = 0;
                });
              });
            }
          });
          break;
      }
    });

    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   setState(() {
    //     accelerometer = (event.x * 100).round().toString() +
    //         " " +
    //         (event.y * 100).round().toString() +
    //         " " +
    //         (event.z * 100).round().toString();
    //   });
    // });

    // userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //   setState(() {
    //     userAccelerometer = (event.x * 100).round().toString() +
    //         " " +
    //         (event.y * 100).round().toString() +
    //         " " +
    //         (event.z * 100).round().toString();
    //   });
    // });
// [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]

    // gyroscopeEvents.listen((GyroscopeEvent event) {
    //   setState(() {
    //     gyroscope = (event.x * 100).round().toString() +
    //         " " +
    //         (event.y * 100).round().toString() +
    //         " " +
    //         (event.z * 100).round().toString();
    //   });
    // });
// [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]

    // magnetometerEvents.listen((MagnetometerEvent event) {
    //   setState(() {
    //     magnetometer = (event.x * 100).round().toString() +
    //         " " +
    //         (event.y * 100).round().toString() +
    //         " " +
    //         (event.z * 100).round().toString();
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      // Use ambient mode to stay alive in the foreground
      // Use a foreground service if you want to stay alive in the background
      home: AmbientMode(
        builder: (context, mode, child) => child!,
        child: Scaffold(
            backgroundColor: Colors.grey,
            body: _riveArtboard == null
                ? const SizedBox()
                : PageView(
                    scrollDirection: Axis.vertical,
                    controller: pageController,
                    children: [
                      Stack(
                        children: [
                          Positioned.fill(
                            child: Rive(
                              fit: BoxFit.fill,
                              artboard: _riveArtboard!,
                            ),
                          ),
                          if (!started) ...[
                            Positioned.fill(
                              child: TextButton(
                                onPressed: toggleExerciseState,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      started ? 'Stop' : 'Press to start',
                                      style: const TextStyle(
                                        color: Color(0xFFe00625),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (started) ...[
                              Positioned.fill(
                                  child: Center(
                                      child: Column(children: [
                                Text('${(speed * 100).round()}'),
                                Text('$heartRate')
                              ])))
                            ],
                          ],
                        ],
                      ),
                      Container(
                        color: const Color.fromRGBO(194, 165, 173, 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Health Information:',
                              style: TextStyle(color: Color(0xFFe00625)),
                            ),
                            const SizedBox(height: 5),
                            Text('HeartRate: $heartRate'),
                            Text('Calories: ${calories.toStringAsFixed(2)}'),
                            Text('Steps: $steps'),
                            Text('Distance: ${distance.toStringAsFixed(2)}'),
                            Text('Speed: ${speed.toStringAsFixed(2)}'),
                          ],
                        ),
                      )
                    ],
                  )),
      ),
    );
  }

  void toggleExerciseState() async {
    setState(() {
      started = !started;
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
