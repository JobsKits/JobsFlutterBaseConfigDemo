import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() =>
    runApp(const JobsMaterialRunner(TapDemo(), title: 'Tap Gesture Demo'));

class TapDemo extends StatelessWidget {
  const TapDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          debugPrint('Single tap');
        },
        onDoubleTap: () {
          debugPrint('Double tap');
        },
        onLongPress: () {
          debugPrint('Long press');
        },
        child: Container(
          color: Colors.blue,
          width: 100,
          height: 100,
          child: const Center(
              child: Text('Tap Me', style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }
}
