import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 利用WidgetsBindingObserver监听键盘事件
void main() => runApp(const JobsMaterialRunner(KeyboardDemo(), title: 'XXX'));

class KeyboardDemo extends StatefulWidget {
  const KeyboardDemo({super.key});
  @override
  _KeyboardDemoState createState() => _KeyboardDemoState();
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
            decoration: const InputDecoration(
              hintText: 'Tap the buttons to show/hide keyboard',
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
                child: const Text('Show Keyboard'),
              ),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
                child: const Text('Hide Keyboard'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Keyboard Height: $_keyboardHeight'),
        ],
      ),
    );
  }
}
