import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:workout/workout.dart';

class Jogger extends StatefulWidget {
  const Jogger({Key? key}) : super(key: key);

  @override
  _JoggerState createState() => _JoggerState();
}

class _JoggerState extends State<Jogger> {
  bool get isPlaying => _controller?.isActive ?? false;
  Random random = new Random();

  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _levelInput;
  SMIInput<double>? ethnicity;
  SMIInput<double>? gender;

  @override
  void initState() {
    super.initState();

    rootBundle.load('jogger.riv').then(
      (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        var controller =
            StateMachineController.fromArtboard(artboard, 'State Machine 1');
        if (controller != null) {
          artboard.addController(controller);
          _levelInput = controller.findInput('Speed');
          ethnicity = controller.findInput('Ethnicity');
          gender = controller.findInput('Gender');
          _levelInput?.value = 0;
          ethnicity?.value = 0;
          gender?.value = 1;
        }
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  final workout = Workout();
  final exerciseType = ExerciseType.walking;
  final features = [
    WorkoutFeature.speed,
  ];
  double speed = 0;

  _JoggerState() {
    workout.stream.listen(
      (event) {
        if (event.feature == WorkoutFeature.speed) {
          _levelInput?.value = event.value * 1.25;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _riveArtboard == null
              ? const SizedBox()
              : Stack(
                  children: [
                    Image.asset('background.png', fit: BoxFit.fitWidth),
                    Positioned.fill(
                      child: Rive(
                        artboard: _riveArtboard!,
                      ),
                    ),
                    Positioned.fill(
                      bottom: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 70,
                            child: ElevatedButton(
                              child: const Text('Start'),
                              onPressed: toggleExerciseState,
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 30,
                            width: 70,
                            child: ElevatedButton(
                              child: const Text('Man'),
                              onPressed: () => gender?.value = 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 30,
                            width: 70,
                            child: ElevatedButton(
                              child: const Text('Vrouw'),
                              onPressed: () => gender?.value = 0,
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 30,
                            width: 70,
                            child: ElevatedButton(
                              child: const Text('Sport'),
                              onPressed: () => _levelInput?.value =
                                  random.nextInt(99) as double,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void toggleExerciseState() async {
    final supportedExerciseTypes = await workout.getSupportedExerciseTypes();
    // ignore: avoid_print
    print('Supported exercise types: ${supportedExerciseTypes.length}');

    await workout.start(
      // In a real application, check the supported exercise types first
      exerciseType: exerciseType,
      features: features,
    );
  }
}
