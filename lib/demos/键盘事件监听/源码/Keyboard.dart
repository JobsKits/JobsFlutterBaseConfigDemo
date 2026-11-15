import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 利用WidgetsBindingObserver监听键盘事件
void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(KeyboardDemo(), title: 'XXX'));

class KeyboardDemo extends StatefulWidget {
  const KeyboardDemo({super.key});
  @override
  State<KeyboardDemo> createState() => _KeyboardDemoState();
}

class _KeyboardDemoState extends State<KeyboardDemo>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  double _keyboardHeight = 0.0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    setState(() {
      _keyboardHeight = keyboardHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: legacyInputDecoration(
              context,
              InputDecoration(
                hintText: 'Tap the buttons to show/hide keyboard',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(_focusNode);
                },
                child: const LegacyText('Show Keyboard'),
              ),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
                child: const LegacyText('Hide Keyboard'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LegacyText('Keyboard Height: $_keyboardHeight'),
        ],
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '键盘事件监听');
