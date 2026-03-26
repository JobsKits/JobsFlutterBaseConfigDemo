import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() => runApp(
    const JobsMaterialRunner(MyHomePage(), title: 'Flutter Overlay Demo'));

/// 在插入新的Overlay前，检查是否已有Overlay存在，如果存在则移除它。
/// 这样就确保了每次点击按钮时，只会显示一个Overlay，并且关闭按钮可以正常工作。
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  OverlayEntry? _overlayEntry;
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 100.0,
        left: MediaQuery.of(context).size.width / 4,
        width: MediaQuery.of(context).size.width / 2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This is an Overlay',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _removeOverlay();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _showOverlay,
        child: const Text('Show Overlay'),
      ),
    );
  }
}
