import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 箭头不好看
// dependencies:
//   flutter:
//     sdk: flutter
//   clipboard:
//   fluttertoast:

// 点击一个复制按钮以后，复制输入框的内容到剪切板，
// 并且在点击复制按钮的任意方向（方向我可以自定义，默认上方），出现一个气泡，
// 气泡内容为复制成功，2秒后气泡自动消失

void main() => runApp(const JobsMaterialRunner(CopyToClipboardWidget()));

class CopyToClipboardWidget extends StatefulWidget {
  const CopyToClipboardWidget({super.key});

  @override
  _CopyToClipboardWidgetState createState() => _CopyToClipboardWidgetState();
}

class _CopyToClipboardWidgetState extends State<CopyToClipboardWidget> {
  final TextEditingController _controller = TextEditingController();
  OverlayEntry? _overlayEntry;

  void _showOverlay(
      BuildContext context, Offset offset, ArrowDirection direction) {
    _overlayEntry = _createOverlayEntry(context, offset, direction);
    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
    });
  }

  OverlayEntry _createOverlayEntry(
      BuildContext context, Offset offset, ArrowDirection direction) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: direction == ArrowDirection.down ? offset.dy + 30 : offset.dy - 60,
        left: offset.dx - 20,
        child: Material(
          color: Colors.transparent,
          child: CustomPaint(
            painter: BubblePainter(direction),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                '复制成功',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(
      BuildContext context, GlobalKey key, ArrowDirection direction) {
    Clipboard.setData(ClipboardData(text: _controller.text));
    RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    _showOverlay(context, offset, direction);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey buttonKey1 = GlobalKey();
    final GlobalKey buttonKey2 = GlobalKey();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '输入内容',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            key: buttonKey1,
            onPressed: () =>
                _copyToClipboard(context, buttonKey1, ArrowDirection.down),
            child: const Text('复制 (箭头向下)'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            key: buttonKey2,
            onPressed: () =>
                _copyToClipboard(context, buttonKey2, ArrowDirection.up),
            child: const Text('复制 (箭头向上)'),
          ),
        ],
      ),
    );
  }
}

enum ArrowDirection { up, down }

class BubblePainter extends CustomPainter {
  final ArrowDirection direction;

  BubblePainter(this.direction);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path = Path();
    if (direction == ArrowDirection.down) {
      path.moveTo(20, 0);
      path.lineTo(10, 10);
      path.lineTo(30, 10);
      path.lineTo(30, 40);
      path.lineTo(size.width - 10, 40);
      path.lineTo(size.width - 10, 10);
      path.lineTo(size.width, 10);
      path.lineTo(size.width - 20, 0);
    } else {
      path.moveTo(20, 40);
      path.lineTo(10, 30);
      path.lineTo(30, 30);
      path.lineTo(30, 0);
      path.lineTo(size.width - 10, 0);
      path.lineTo(size.width - 10, 30);
      path.lineTo(size.width, 30);
      path.lineTo(size.width - 20, 40);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
