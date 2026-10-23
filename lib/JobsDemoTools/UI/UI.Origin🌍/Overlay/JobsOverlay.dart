import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() => runApp(
    const JobsMaterialRunner(JobsOverlay(), title: 'Custom Overlay Demo'));

class JobsOverlay extends StatefulWidget {
  const JobsOverlay({super.key});

  @override
  _CustomOverlayDemoState createState() => _CustomOverlayDemoState();
}

class _CustomOverlayDemoState extends State<JobsOverlay> {
  OverlayEntry? _overlayEntry;

  OverlayEntry _createOverlayEntry(ThemeData theme) {
    return OverlayEntry(
      builder: (context) => Positioned.fill(
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                child: Material(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'This is a custom overlay',
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _overlayEntry?.remove();
                            _overlayEntry = null;
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    _overlayEntry = _createOverlayEntry(Theme.of(context));
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showOverlay(context),
      child: const Text('Show Custom Overlay'),
    );
  }
}
