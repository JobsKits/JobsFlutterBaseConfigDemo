// 独立运行：flutter run -t "lib/demos/贝塞尔纸张翻页/贝塞尔纸张翻页.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/render_strings.dart';

void main() => runApp(const JobsDemoApp(home: BezierPageTurnPage()));

/// 用折痕半平面裁剪原页，再反射被折区域；圆滑背面采用二次贝塞尔边缘。
class FoldedPageGeometry {
  FoldedPageGeometry(this.front, this.back, this.crease);
  final Path front, back;
  final List<Offset> crease;

  static FoldedPageGeometry calculate(Size size, Offset corner, Offset touch) {
    final rectangle = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];
    final difference = corner - touch;
    if (size.isEmpty || difference.distance < .001) {
      return FoldedPageGeometry(
        Path()..addRect(Offset.zero & size),
        Path(),
        [],
      );
    }
    final normal = difference / difference.distance;
    final middle = (corner + touch) / 2;
    double side(Offset p) =>
        (p.dx - middle.dx) * normal.dx + (p.dy - middle.dy) * normal.dy;
    List<Offset> clip(bool positive) {
      final output = <Offset>[];
      for (var i = 0; i < rectangle.length; i++) {
        final a = rectangle[i], b = rectangle[(i + 1) % rectangle.length];
        final sa = side(a), sb = side(b);
        final aInside = positive ? sa >= 0 : sa <= 0;
        final bInside = positive ? sb >= 0 : sb <= 0;
        if (aInside) output.add(a);
        if (aInside != bInside) output.add(a + (b - a) * (sa / (sa - sb)));
      }
      return output;
    }

    final visible = clip(false), folded = clip(true);
    final front = Path();
    if (visible.length >= 3) front.addPolygon(visible, true);
    final reflected = folded.map((p) => p - normal * (2 * side(p))).toList();
    final back = Path();
    if (reflected.length >= 3) {
      // 折痕两端保持相接，只弯曲露出的纸角，避免背面变成脱离折痕的水滴。
      for (var i = 0; i < reflected.length; i++) {
        final p = reflected[i];
        final previous =
            reflected[(i + reflected.length - 1) % reflected.length];
        final next = reflected[(i + 1) % reflected.length];
        final onCrease = side(p).abs() < .001;
        final entry = onCrease ? p : Offset.lerp(p, previous, .12)!;
        final exit = onCrease ? p : Offset.lerp(p, next, .12)!;
        if (i == 0) {
          back.moveTo(entry.dx, entry.dy);
        } else {
          back.lineTo(entry.dx, entry.dy);
        }
        if (!onCrease) {
          back.quadraticBezierTo(p.dx, p.dy, exit.dx, exit.dy);
        }
      }
      back.close();
    }
    final crease = <Offset>[];
    for (var i = 0; i < rectangle.length; i++) {
      final a = rectangle[i], b = rectangle[(i + 1) % rectangle.length];
      final sa = side(a), sb = side(b);
      if (sa * sb < 0) crease.add(a + (b - a) * (sa / (sa - sb)));
    }
    return FoldedPageGeometry(front, back, crease);
  }
}

class BezierPageTurnPage extends StatefulWidget {
  const BezierPageTurnPage({super.key});
  @override
  State<BezierPageTurnPage> createState() => _BezierPageTurnPageState();
}

class _BezierPageTurnPageState extends State<BezierPageTurnPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..addListener(animate);
  int page = 0, direction = 1, revision = 0, turnToken = 0;
  bool top = false, turning = false;
  Size paperSize = Size.zero;
  Offset? dragPoint;
  Offset from = Offset.zero, to = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) cancel();
  }

  Future<void> load() async {
    final before = revision;
    final value = await UiDemoStore.read('curated-book', {'page': 0});
    if (mounted &&
        before == revision &&
        value is Map &&
        value['page'] is num &&
        (value['page'] as num).isFinite) {
      setState(() => page = (value['page'] as num).toInt().clamp(0, 2));
    }
  }

  Future<void> persist() async {
    final before = revision;
    final value = await UiDemoStore.write('curated-book', {'page': page});
    if (mounted &&
        before == revision &&
        !turning &&
        dragPoint == null &&
        value is Map &&
        value['page'] is num &&
        (value['page'] as num).isFinite) {
      setState(() => page = (value['page'] as num).toInt().clamp(0, 2));
    }
  }

  Offset get corner =>
      Offset(direction == 1 ? paperSize.width : 0, top ? 0 : paperSize.height);
  bool canTurn(int delta) => page + delta >= 0 && page + delta <= 2;

  void animate() {
    if (!mounted || !turning) return;
    final progress = Curves.easeOutCubic.transform(controller.value);
    setState(() => dragPoint = Offset.lerp(from, to, progress));
  }

  void cancel() {
    turnToken++;
    revision++;
    controller.stop(canceled: true);
    if (mounted) {
      setState(() {
        turning = false;
        dragPoint = null;
      });
    }
  }

  Future<void> settle(bool complete) async {
    if (paperSize.isEmpty || (complete && !canTurn(direction))) return;
    final token = ++turnToken;
    revision++;
    from = dragPoint ?? corner;
    to = complete
        ? Offset(
            direction == 1 ? -paperSize.width * .9 : paperSize.width * 1.9,
            top ? paperSize.height * .1 : paperSize.height * .9,
          )
        : corner;
    setState(() => turning = true);
    try {
      if (!MediaQuery.disableAnimationsOf(context)) {
        await controller.forward(from: 0).orCancel;
      }
      if (!mounted || token != turnToken) return;
      setState(() {
        if (complete) page += direction;
        turning = false;
        dragPoint = null;
      });
      if (complete) unawaited(persist());
    } on TickerCanceled {
      // 取消或后台切换保留完整原页，不提交半途页码。
    }
  }

  void turn(int delta) {
    if (turning || !canTurn(delta) || paperSize.isEmpty) return;
    direction = delta;
    dragPoint = corner;
    unawaited(settle(true));
  }

  String title(int index) => renderTr(context, 'render.book$index.title');
  String body(int index) => renderTr(context, 'render.book$index.body');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: JobsDemoAppBar(title: Text(renderTr(context, '贝塞尔纸张翻页'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                renderTr(context, 'render.bookHint'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.25,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    paperSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final next = (page + direction).clamp(0, 2);
                    return Semantics(
                      label: '${title(page)}. ${body(page)}',
                      value:
                          '${renderTr(context, 'render.page')} ${page + 1} / 3',
                      increasedValue: !turning && canTurn(1)
                          ? '${renderTr(context, 'render.page')} ${page + 2} / 3'
                          : null,
                      decreasedValue: !turning && canTurn(-1)
                          ? '${renderTr(context, 'render.page')} $page / 3'
                          : null,
                      onIncrease: !turning && canTurn(1) ? () => turn(1) : null,
                      onDecrease: !turning && canTurn(-1)
                          ? () => turn(-1)
                          : null,
                      child: GestureDetector(
                        key: const ValueKey('book-paper'),
                        onPanStart: turning
                            ? null
                            : (details) {
                                final proposed =
                                    details.localPosition.dx <
                                        paperSize.width / 2
                                    ? -1
                                    : 1;
                                if (!canTurn(proposed)) return;
                                revision++;
                                direction = proposed;
                                setState(
                                  () => dragPoint = details.localPosition,
                                );
                              },
                        onPanUpdate: (details) {
                          if (turning || dragPoint == null) return;
                          setState(
                            () => dragPoint = Offset(
                              details.localPosition.dx.clamp(
                                -paperSize.width,
                                paperSize.width * 2,
                              ),
                              details.localPosition.dy.clamp(
                                -paperSize.height * .3,
                                paperSize.height * 1.3,
                              ),
                            ),
                          );
                        },
                        onPanEnd: (_) {
                          final point = dragPoint;
                          if (point != null && !turning) {
                            unawaited(
                              settle(
                                (point.dx - corner.dx).abs() >
                                    paperSize.width * .3,
                              ),
                            );
                          }
                        },
                        onPanCancel: cancel,
                        child: CustomPaint(
                          painter: _BookPainter(
                            title: title(page),
                            body: body(page),
                            nextTitle: title(next),
                            nextBody: body(next),
                            corner: corner,
                            touch: dragPoint,
                            brightness: Theme.of(context).brightness,
                            textStyle: Theme.of(context).textTheme.bodyLarge!,
                            scaler: MediaQuery.textScalerOf(context),
                            page: page,
                            nextPage: next,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '${renderTr(context, 'render.page')} ${page + 1} / 3',
                key: const ValueKey('book-page'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton(
                    onPressed: !turning && canTurn(-1) ? () => turn(-1) : null,
                    child: Text(renderTr(context, 'render.previous')),
                  ),
                  FilledButton(
                    onPressed: !turning && canTurn(1) ? () => turn(1) : null,
                    child: Text(renderTr(context, 'render.next')),
                  ),
                  OutlinedButton(
                    onPressed: dragPoint != null ? cancel : null,
                    child: Text(renderTr(context, 'render.cancel')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(renderTr(context, 'render.corner')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(renderTr(context, 'render.top')),
                    selected: top,
                    onSelected: turning
                        ? null
                        : (_) => setState(() {
                            top = true;
                            dragPoint = null;
                          }),
                  ),
                  ChoiceChip(
                    label: Text(renderTr(context, 'render.bottom')),
                    selected: !top,
                    onSelected: turning
                        ? null
                        : (_) => setState(() {
                            top = false;
                            dragPoint = null;
                          }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Material(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  title: Text(title(page)),
                  childrenPadding: const EdgeInsets.all(18),
                  children: [SelectableText(body(page))],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    turnToken++;
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }
}

class _BookPainter extends CustomPainter {
  _BookPainter({
    required this.title,
    required this.body,
    required this.nextTitle,
    required this.nextBody,
    required this.corner,
    required this.touch,
    required this.brightness,
    required this.textStyle,
    required this.scaler,
    required this.page,
    required this.nextPage,
  });
  final String title, body, nextTitle, nextBody;
  final Offset corner;
  final Offset? touch;
  final Brightness brightness;
  final TextStyle textStyle;
  final TextScaler scaler;
  final int page, nextPage;

  void drawPage(
    Canvas canvas,
    Size size,
    String heading,
    String content,
    int number,
  ) {
    final dark = brightness == Brightness.dark;
    final paper = dark ? const Color(0xFF253337) : const Color(0xFFF6F0DF);
    final ink = dark ? const Color(0xFFE5E9DE) : const Color(0xFF253F37);
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    final margin = size.width * .09;
    final headingPainter = TextPainter(
      text: TextSpan(
        text: heading,
        style: textStyle.copyWith(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: size.width - margin * 2);
    headingPainter.paint(canvas, Offset(margin, size.height * .12));
    final text = TextPainter(
      text: TextSpan(
        text: content,
        style: textStyle.copyWith(
          color: ink.withValues(alpha: .86),
          fontSize: 15,
          height: 1.7,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: (size.height / (scaler.scale(15) * 1.7) - 5).floor().clamp(
        1,
        12,
      ),
      ellipsis: '…',
    )..layout(maxWidth: size.width - margin * 2);
    text.paint(
      canvas,
      Offset(margin, size.height * .18 + headingPainter.height),
    );
    final footer = TextPainter(
      text: TextSpan(
        text: '${number + 1}',
        style: textStyle.copyWith(color: ink, fontSize: 13),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    footer.paint(
      canvas,
      Offset(size.width / 2 - footer.width / 2, size.height * .9),
    );
    headingPainter.dispose();
    text.dispose();
    footer.dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
    );
    final point = touch;
    if (point == null) {
      drawPage(canvas, size, title, body, page);
    } else {
      drawPage(canvas, size, nextTitle, nextBody, nextPage);
      final fold = FoldedPageGeometry.calculate(size, corner, point);
      canvas.save();
      canvas.clipPath(fold.front);
      drawPage(canvas, size, title, body, page);
      canvas.restore();
      final bounds = fold.back.getBounds();
      if (!bounds.isEmpty) {
        canvas.drawShadow(
          fold.back,
          Colors.black.withValues(alpha: .55),
          12,
          false,
        );
        canvas.drawPath(
          fold.back,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: brightness == Brightness.dark
                  ? const [Color(0xFF7C8985), Color(0xFF344742)]
                  : const [Color(0xFFE6D8B7), Color(0xFFFFFCF1)],
            ).createShader(bounds),
        );
      }
      if (fold.crease.length == 2) {
        final first = fold.crease.first, last = fold.crease.last;
        final middle = (first + last) / 2 + (point - corner) * .025;
        canvas.drawPath(
          Path()
            ..moveTo(first.dx, first.dy)
            ..quadraticBezierTo(middle.dx, middle.dy, last.dx, last.dy),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.black.withValues(alpha: .13),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BookPainter old) =>
      title != old.title ||
      body != old.body ||
      nextTitle != old.nextTitle ||
      nextBody != old.nextBody ||
      textStyle != old.textStyle ||
      touch != old.touch ||
      corner != old.corner ||
      page != old.page ||
      nextPage != old.nextPage ||
      brightness != old.brightness ||
      scaler != old.scaler;
}
