import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

/// An example showing how to drive a StateMachine via one numeric input.
class StateMachineSkills extends StatefulWidget {
  const StateMachineSkills({Key? key}) : super(key: key);

  @override
  _StateMachineSkillsState createState() => _StateMachineSkillsState();
}

class _StateMachineSkillsState extends State<StateMachineSkills> {
  /// Tracks if the animation is playing by whether controller is running.
  bool get isPlaying => _controller?.isActive ?? false;

  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _levelInput;

  @override
  void initState() {
    super.initState();

    // Load the animation file from the bundle, note that you could also
    // download this. The RiveFile just expects a list of bytes.
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
        }
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: _riveArtboard == null
            ? const SizedBox()
            : Stack(
                children: [
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
                            child: const Text('Stop'),
                            onPressed: () => _levelInput?.value = 0,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 30,
                          width: 70,
                          child: ElevatedButton(
                            child: const Text('Run'),
                            onPressed: () => _levelInput?.value = 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 30,
                          width: 70,
                          child: ElevatedButton(
                            child: const Text('Jump'),
                            onPressed: () => _levelInput?.value = 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
