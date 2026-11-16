// 独立运行：flutter run -t "lib/demos/手写签名板/handwriting_demo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const JobsDemoApp(home: HandwritingDemo()));

/// 笔迹使用归一化坐标保存，横竖屏和独立预览共用同一份数据。
class HandwritingDemo extends StatefulWidget {
  const HandwritingDemo({super.key});

  @override
  State<HandwritingDemo> createState() => _HandwritingDemoState();
}

class _HandwritingDemoState extends State<HandwritingDemo> {
  static const _storageKey = 'jobs_demo_handwriting_v1';
  final _strokes = <_Stroke>[];
  double _width = 3;
  bool _dirty = false;
  bool _loading = true;
  bool _saving = false;
  bool _leaving = false;
  int? _pointer;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString(_storageKey);
      if (encoded != null) {
        final rows = jsonDecode(encoded) as List;
        final restored = rows.map((row) => _Stroke.fromJson(row)).toList();
        if (mounted) _strokes.addAll(restored);
      }
    } catch (_) {
      // 损坏数据不阻止再次书写；用户保存时会覆盖为有效笔迹。
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<bool> _save() async {
    if (_saving || _pointer != null) return false;
    setState(() => _saving = true);
    bool saved = false;
    try {
      final preferences = await SharedPreferences.getInstance();
      saved = await preferences.setString(
        _storageKey,
        jsonEncode(_strokes.map((stroke) => stroke.toJson()).toList()),
      );
    } catch (_) {
      saved = false;
    }
    if (!mounted) return saved;
    setState(() {
      _saving = false;
      if (saved) _dirty = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr(context, saved ? '已保存' : '保存失败'))),
    );
    return saved;
  }

  Future<void> _requestLeave() async {
    if (_leaving || _saving) return;
    _leaving = true;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(context, '未保存的笔迹')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'stay'),
            child: Text(tr(context, '继续编辑')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text(tr(context, '放弃并退出')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text(tr(context, '保存并退出')),
          ),
        ],
      ),
    );
    _leaving = false;
    if (!mounted || choice == null || choice == 'stay') return;
    if (choice == 'save' && !await _save()) return;
    if (choice == 'discard') {
      try {
        final preferences = await SharedPreferences.getInstance();
        if (!await preferences.remove(_storageKey)) return;
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(tr(context, '保存失败'))));
        }
        return;
      }
    }
    if (!mounted) return;
    setState(() => _dirty = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Offset _normalize(Offset point, Size size) => Offset(
    (point.dx / size.width).clamp(0, 1),
    (point.dy / size.height).clamp(0, 1),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestLeave();
      },
      child: Scaffold(
        appBar: JobsDemoAppBar(
          title: Text(tr(context, '手写板')),
          actions: [
            TextButton(
              onPressed: _loading || _saving ? null : _save,
              child: Text(tr(context, '保存')),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(tr(context, '笔宽')),
                    Expanded(
                      child: Slider(
                        value: _width,
                        min: 1,
                        max: 12,
                        divisions: 11,
                        label: _width.toStringAsFixed(0),
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _width = value),
                      ),
                    ),
                    Text(_width.toStringAsFixed(0)),
                  ],
                ),
                Expanded(
                  child: Semantics(
                    label: tr(context, '画布'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ColoredBox(
                        color: colors.surfaceContainerHighest,
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final size = constraints.biggest;
                                  return Listener(
                                    behavior: HitTestBehavior.opaque,
                                    onPointerDown: _saving
                                        ? null
                                        : (event) {
                                            if (_pointer != null) return;
                                            _pointer = event.pointer;
                                            setState(() {
                                              _strokes.add(
                                                _Stroke(_width, [
                                                  _normalize(
                                                    event.localPosition,
                                                    size,
                                                  ),
                                                ]),
                                              );
                                              _dirty = true;
                                            });
                                          },
                                    onPointerMove: (event) {
                                      if (event.pointer != _pointer ||
                                          _strokes.isEmpty) {
                                        return;
                                      }
                                      setState(
                                        () => _strokes.last.points.add(
                                          _normalize(event.localPosition, size),
                                        ),
                                      );
                                    },
                                    onPointerUp: (event) {
                                      if (event.pointer == _pointer) {
                                        _pointer = null;
                                      }
                                    },
                                    onPointerCancel: (event) {
                                      if (event.pointer == _pointer) {
                                        _pointer = null;
                                      }
                                    },
                                    child: CustomPaint(
                                      key: const ValueKey('handwriting-canvas'),
                                      painter: _InkPainter(
                                        _strokes,
                                        colors.onSurface,
                                      ),
                                      size: Size.infinite,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: _strokes.isEmpty || _saving
                          ? null
                          : () => setState(() {
                              _strokes.removeLast();
                              _pointer = null;
                              _dirty = true;
                            }),
                      child: Text(tr(context, '撤销')),
                    ),
                    OutlinedButton(
                      onPressed: _strokes.isEmpty || _saving
                          ? null
                          : () => setState(() {
                              _strokes.clear();
                              _pointer = null;
                              _dirty = true;
                            }),
                      child: Text(tr(context, '清空')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stroke {
  _Stroke(this.width, this.points);
  final double width;
  final List<Offset> points;

  factory _Stroke.fromJson(dynamic json) {
    final row = json as Map<String, dynamic>;
    return _Stroke((row['width'] as num).toDouble().clamp(1, 12), [
      for (final point in row['points'] as List)
        Offset(
          (point[0] as num).toDouble().clamp(0, 1),
          (point[1] as num).toDouble().clamp(0, 1),
        ),
    ]);
  }

  Map<String, dynamic> toJson() => {
    'width': width,
    'points': points.map((point) => [point.dx, point.dy]).toList(),
  };
}

class _InkPainter extends CustomPainter {
  _InkPainter(this.strokes, this.color);
  final List<_Stroke> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final first = Offset(
        stroke.points.first.dx * size.width,
        stroke.points.first.dy * size.height,
      );
      if (stroke.points.length == 1) {
        canvas.drawCircle(first, stroke.width / 2, Paint()..color = color);
        continue;
      }
      final path = Path()..moveTo(first.dx, first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_InkPainter oldDelegate) => true;
}
