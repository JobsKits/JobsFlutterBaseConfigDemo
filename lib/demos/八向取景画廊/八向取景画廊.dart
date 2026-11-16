// 独立运行：flutter run -t "lib/demos/八向取景画廊/八向取景画廊.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/render_strings.dart';
import '../视觉素材共用/场景绘制.dart';

void main() => runApp(const JobsDemoApp(home: EightDirectionGalleryPage()));

/// 行列是真实选中状态，八向手势和按钮使用同一条边界规则。
class GalleryPosition {
  const GalleryPosition(this.row, this.column);
  final int row, column;
  int get index => row * 3 + column;
  GalleryPosition move(int dx, int dy) =>
      GalleryPosition((row + dy).clamp(0, 2), (column + dx).clamp(0, 2));
}

/// 空列表是有效空态；结构错误的服务端响应不能破坏当前可用画廊。
List<int>? parseGalleryScenes(Object? value) {
  if (value is! Map || value['scenes'] is! List) return null;
  final result = <int>[];
  for (final scene in value['scenes'] as List) {
    if (scene is! num ||
        !scene.isFinite ||
        scene != scene.roundToDouble() ||
        scene < 0 ||
        scene > 8 ||
        result.contains(scene.toInt())) {
      return null;
    }
    result.add(scene.toInt());
  }
  return result;
}

class EightDirectionGalleryPage extends StatefulWidget {
  const EightDirectionGalleryPage({super.key});
  @override
  State<EightDirectionGalleryPage> createState() =>
      _EightDirectionGalleryPageState();
}

class _EightDirectionGalleryPageState extends State<EightDirectionGalleryPage> {
  GalleryPosition position = const GalleryPosition(1, 1);
  Offset drag = Offset.zero;
  int? activePointer;
  List<int> scenes = List.generate(9, (index) => index);
  int revision = 0, loadToken = 0;
  bool loading = false;
  final focus = FocusNode();

  void normalizePosition() {
    if (scenes.isNotEmpty && position.index >= scenes.length) {
      position = GalleryPosition(
        (scenes.length - 1) ~/ 3,
        (scenes.length - 1) % 3,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(reload());
  }

  Future<void> reload() async {
    final token = ++loadToken, before = revision;
    setState(() => loading = true);
    final value = await UiDemoStore.read('curated-gallery', {
      'scenes': List.generate(9, (i) => i),
    });
    if (!mounted || token != loadToken || before != revision) return;
    setState(() {
      scenes = parseGalleryScenes(value) ?? scenes;
      normalizePosition();
      loading = false;
    });
  }

  Future<void> restore() async {
    final token = ++revision;
    final defaults = List.generate(9, (i) => i);
    setState(() {
      scenes = defaults;
      loading = false;
      position = const GalleryPosition(1, 1);
    });
    final value = await UiDemoStore.write('curated-gallery', {
      'scenes': defaults,
    });
    if (!mounted || token != revision) return;
    setState(() {
      scenes = parseGalleryScenes(value) ?? scenes;
      normalizePosition();
    });
  }

  void move(int dx, int dy) {
    final next = position.move(dx, dy);
    if (next.index >= scenes.length) return;
    revision++;
    setState(() {
      position = next;
      loading = false;
    });
    if (MediaQuery.supportsAnnounceOf(context)) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        '${renderTr(context, 'render.position')} ${position.row + 1}, ${position.column + 1}',
        Directionality.of(context),
      );
    }
  }

  void finishPan() {
    if (drag.distance < 28) return;
    final octant = (math.atan2(-drag.dy, -drag.dx) / (math.pi / 4)).round();
    final angle = octant * math.pi / 4;
    move(math.cos(angle).round(), math.sin(angle).round());
  }

  KeyEventResult key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => const Offset(-1, 0),
      LogicalKeyboardKey.arrowRight => const Offset(1, 0),
      LogicalKeyboardKey.arrowUp => const Offset(0, -1),
      LogicalKeyboardKey.arrowDown => const Offset(0, 1),
      _ => null,
    };
    if (direction == null) return KeyEventResult.ignored;
    move(direction.dx.toInt(), direction.dy.toInt());
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: JobsDemoAppBar(
        title: Text(renderTr(context, '八向取景画廊')),
        actions: [
          IconButton(
            tooltip: renderTr(context, 'render.retry'),
            onPressed: reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Focus(
        focusNode: focus,
        onKeyEvent: key,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  renderTr(context, 'render.galleryHint'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (loading) const LinearProgressIndicator(),
                if (scenes.isEmpty)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.landscape_outlined, size: 52),
                          const SizedBox(height: 12),
                          Text(renderTr(context, 'render.empty')),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: reload,
                            child: Text(renderTr(context, 'render.retry')),
                          ),
                          TextButton(
                            onPressed: restore,
                            child: Text(renderTr(context, 'render.restore')),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AspectRatio(
                      aspectRatio: 1.4,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return RawGestureDetector(
                            // 画廊占有取景窗内的二维拖动，避免父列表抢走竖向分量。
                            gestures: {
                              EagerGestureRecognizer:
                                  GestureRecognizerFactoryWithHandlers<
                                    EagerGestureRecognizer
                                  >(EagerGestureRecognizer.new, (_) {}),
                            },
                            child: Listener(
                              key: const ValueKey('gallery-viewfinder'),
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: (event) {
                                if (activePointer != null) return;
                                activePointer = event.pointer;
                                drag = Offset.zero;
                                focus.requestFocus();
                              },
                              onPointerMove: (event) {
                                if (activePointer == event.pointer) {
                                  drag += event.delta;
                                }
                              },
                              onPointerUp: (event) {
                                if (activePointer != event.pointer) return;
                                activePointer = null;
                                finishPan();
                              },
                              onPointerCancel: (event) {
                                if (activePointer == event.pointer) {
                                  activePointer = null;
                                }
                              },
                              child: TweenAnimationBuilder<Offset>(
                                tween: Tween(
                                  end: Offset(
                                    position.column.toDouble(),
                                    position.row.toDouble(),
                                  ),
                                ),
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 330),
                                curve: Curves.easeOutCubic,
                                builder: (context, camera, _) => CustomPaint(
                                  painter: _GalleryPainter(
                                    camera: camera,
                                    scenes: scenes,
                                    brightness: Theme.of(context).brightness,
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      margin: const EdgeInsets.all(14),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surface.withValues(
                                          alpha: .93,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      child: Text(
                                        '${renderTr(context, 'render.position')}  ${position.row + 1} / ${position.column + 1}',
                                        key: const ValueKey('gallery-position'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: SizedBox(
                      width: 174,
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var y = -1; y <= 1; y++)
                            for (var x = -1; x <= 1; x++)
                              x == 0 && y == 0
                                  ? IconButton(
                                      tooltip: renderTr(
                                        context,
                                        'render.reset',
                                      ),
                                      onPressed: () {
                                        revision++;
                                        setState(() {
                                          position = const GalleryPosition(
                                            1,
                                            1,
                                          );
                                          normalizePosition();
                                          loading = false;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.filter_center_focus,
                                      ),
                                    )
                                  : IconButton(
                                      key: ValueKey('gallery-direction-$x-$y'),
                                      tooltip:
                                          '${renderTr(context, 'render.position')} ${position.move(x, y).row + 1},${position.move(x, y).column + 1}',
                                      onPressed:
                                          position.move(x, y).index ==
                                                  position.index ||
                                              position.move(x, y).index >=
                                                  scenes.length
                                          ? null
                                          : () => move(x, y),
                                      icon: Transform.rotate(
                                        angle: math.atan2(
                                          y.toDouble(),
                                          x.toDouble(),
                                        ),
                                        child: const Icon(Icons.arrow_forward),
                                      ),
                                    ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scenes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) => Semantics(
                      selected: position.index == index,
                      label:
                          '${renderTr(context, 'render.scene')} ${index + 1}',
                      child: InkWell(
                        onTap: () {
                          revision++;
                          setState(() {
                            position = GalleryPosition(index ~/ 3, index % 3);
                            loading = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: position.index == index
                                  ? colors.primary
                                  : colors.outlineVariant,
                              width: position.index == index ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomPaint(
                              painter: CuratedScenePainter(
                                scene: scenes[index],
                                brightness: Theme.of(context).brightness,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    loadToken++;
    focus.dispose();
    super.dispose();
  }
}

class _GalleryPainter extends CustomPainter {
  const _GalleryPainter({
    required this.camera,
    required this.scenes,
    required this.brightness,
  });
  final Offset camera;
  final List<int> scenes;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || scenes.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = brightness == Brightness.dark
            ? const Color(0xff14231f)
            : const Color(0xffdeebe3),
    );
    final tile = Size(size.width * .76, size.height * .76);
    for (var index = 0; index < scenes.length; index++) {
      final row = index ~/ 3, column = index % 3;
      final offset = Offset(
        (column - camera.dx) * tile.width + size.width * .12,
        (row - camera.dy) * tile.height + size.height * .12,
      );
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.clipRect(Offset.zero & tile);
      CuratedScenePainter(
        scene: scenes[index],
        brightness: brightness,
      ).paint(canvas, tile);
      canvas.restore();
    }
    final window = Rect.fromLTWH(
      size.width * .12,
      size.height * .12,
      tile.width,
      tile.height,
    );
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndRadius(window.deflate(5), const Radius.circular(12)),
      );
    canvas.drawPath(
      outside,
      Paint()..color = Colors.black.withValues(alpha: .48),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(window.deflate(5), const Radius.circular(12)),
      Paint()
        ..color = Colors.white.withValues(alpha: .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GalleryPainter old) =>
      camera != old.camera ||
      scenes != old.scenes ||
      brightness != old.brightness;
}
