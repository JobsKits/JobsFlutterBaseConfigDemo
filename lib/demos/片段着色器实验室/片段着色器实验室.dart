// 独立运行：flutter run -t "lib/demos/片段着色器实验室/片段着色器实验室.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/render_strings.dart';
import '../视觉素材共用/场景绘制.dart';

void main() => runApp(const JobsDemoApp(home: FragmentShaderStudioPage()));

class FragmentShaderStudioPage extends StatefulWidget {
  const FragmentShaderStudioPage({super.key, this.programLoader});
  final Future<ui.FragmentProgram> Function()? programLoader;
  @override
  State<FragmentShaderStudioPage> createState() =>
      _FragmentShaderStudioPageState();
}

class _FragmentShaderStudioPageState extends State<FragmentShaderStudioPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final clock = ValueNotifier<double>(0);
  late final Ticker ticker = createTicker(tick);
  Duration? lastTick;
  ui.FragmentShader? shader;
  ui.Image? texture;
  Brightness? textureBrightness;
  int generation = 0;
  int revision = 0;
  int mode = 0;
  double strength = .7, radius = .32, blend = 1, speed = 1;
  Offset center = const Offset(.5, .5);
  bool playing = true, foreground = true, loading = true;
  bool tickersEnabled = true, reducedMotion = false;
  String? error;
  static const effects = [
    'render.glass',
    'render.wave',
    'render.elastic',
    'render.mosaic',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(loadParameters());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tickersEnabled = TickerMode.valuesOf(context).enabled;
    reducedMotion = MediaQuery.disableAnimationsOf(context);
    final brightness = Theme.of(context).brightness;
    if (textureBrightness != brightness) {
      textureBrightness = brightness;
      unawaited(loadShader(brightness));
    }
    syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    syncTicker();
  }

  void syncTicker() {
    final active =
        playing &&
        mode != 0 &&
        shader != null &&
        texture != null &&
        foreground &&
        tickersEnabled &&
        !reducedMotion;
    if (active && !ticker.isActive) ticker.start();
    if (!active && ticker.isActive) {
      ticker.stop();
      lastTick = null;
    }
  }

  void tick(Duration elapsed) {
    final previous = lastTick;
    lastTick = elapsed;
    if (previous == null) return;
    clock.value +=
        ((elapsed - previous).inMicroseconds / 1e6).clamp(0, .05) * speed;
  }

  Future<void> loadShader(Brightness brightness) async {
    final token = ++generation;
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }
    ui.FragmentShader? nextShader;
    ui.Image? nextTexture;
    try {
      final program =
          await (widget.programLoader?.call() ??
              ui.FragmentProgram.fromAsset('shaders/jobs_visual_effects.frag'));
      nextShader = program.fragmentShader();
      nextTexture = await createCuratedTexture(brightness);
      if (!mounted || token != generation) {
        nextShader.dispose();
        nextTexture.dispose();
        return;
      }
      final previousShader = shader;
      final previousTexture = texture;
      setState(() {
        shader = nextShader;
        texture = nextTexture;
        loading = false;
      });
      previousShader?.dispose();
      previousTexture?.dispose();
      syncTicker();
    } catch (failure) {
      nextShader?.dispose();
      nextTexture?.dispose();
      if (mounted && token == generation) {
        setState(() {
          loading = false;
          error = failure.toString();
        });
        syncTicker();
      }
    }
  }

  Map<String, Object> get parameters => {
    'mode': mode,
    'strength': strength,
    'radius': radius,
    'blend': blend,
    'speed': speed,
  };

  void applyParameters(Object? value) {
    if (value is! Map) return;
    double number(String key, double previous, double low, double high) {
      final result = value[key];
      return result is num && result.isFinite
          ? result.toDouble().clamp(low, high)
          : previous;
    }

    mode = number('mode', mode.toDouble(), 0, 3).round();
    strength = number('strength', strength, 0, 1);
    radius = number('radius', radius, .08, .7);
    blend = number('blend', blend, 0, 1);
    speed = number('speed', speed, .2, 2);
  }

  Future<void> loadParameters() async {
    final token = revision;
    final value = await UiDemoStore.read('curated-shader', parameters);
    if (mounted && token == revision) {
      setState(() => applyParameters(value));
      syncTicker();
    }
  }

  Future<void> saveParameters() async {
    final token = revision;
    final value = await UiDemoStore.write('curated-shader', parameters);
    if (!mounted || token != revision) return;
    setState(() => applyParameters(value));
    syncTicker();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(renderTr(context, 'render.saved'))));
  }

  void change(VoidCallback action) {
    revision++;
    setState(action);
    syncTicker();
  }

  Widget slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('${renderTr(context, label)}  ${value.toStringAsFixed(2)}'),
      Slider(
        value: value,
        min: min,
        max: max,
        onChanged: (next) => change(() => onChanged(next)),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final actualShader = shader != null && texture != null;
    return Scaffold(
      appBar: JobsDemoAppBar(title: Text(renderTr(context, '片段着色器实验室'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                renderTr(context, 'render.pointer'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      void point(Offset position) => change(
                        () => center = Offset(
                          (position.dx / constraints.maxWidth).clamp(0, 1),
                          (position.dy / constraints.maxHeight).clamp(0, 1),
                        ),
                      );
                      return Semantics(
                        label: renderTr(context, 'render.pointer'),
                        child: GestureDetector(
                          key: const ValueKey('shader-canvas'),
                          onPanDown: (details) => point(details.localPosition),
                          onPanUpdate: (details) =>
                              point(details.localPosition),
                          child: CustomPaint(
                            painter: _ShaderPainter(
                              shader: shader,
                              texture: texture,
                              clock: clock,
                              center: center,
                              mode: mode,
                              strength: strength,
                              radius: radius,
                              blend: blend,
                              brightness: Theme.of(context).brightness,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface.withValues(alpha: .9),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  renderTr(
                                    context,
                                    actualShader
                                        ? 'render.gpu'
                                        : loading
                                        ? 'render.loading'
                                        : 'render.fallback',
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
              if (!actualShader || error != null) ...[
                const SizedBox(height: 12),
                Text(
                  renderTr(
                    context,
                    error == null ? 'render.fallback' : 'render.error',
                  ),
                ),
                if (loading) const LinearProgressIndicator(),
                if (error != null)
                  TextButton(
                    onPressed: () => loadShader(Theme.of(context).brightness),
                    child: Text(renderTr(context, 'render.retry')),
                  ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < effects.length; i++)
                    ChoiceChip(
                      label: Text(renderTr(context, effects[i])),
                      selected: mode == i,
                      onSelected: (_) => change(() => mode = i),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              slider(
                'render.strength',
                strength,
                0,
                1,
                (value) => strength = value,
              ),
              slider(
                'render.radius',
                radius,
                .08,
                .7,
                (value) => radius = value,
              ),
              slider('render.mix', blend, 0, 1, (value) => blend = value),
              if (mode != 0)
                slider('render.speed', speed, .2, 2, (value) => speed = value),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      semanticFormatterCallback: (v) =>
                          'X ${v.toStringAsFixed(2)}',
                      value: center.dx,
                      onChanged: (v) =>
                          change(() => center = Offset(v, center.dy)),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      semanticFormatterCallback: (v) =>
                          'Y ${v.toStringAsFixed(2)}',
                      value: center.dy,
                      onChanged: (v) =>
                          change(() => center = Offset(center.dx, v)),
                    ),
                  ),
                ],
              ),
              if (reducedMotion && mode != 0) ...[
                Text(renderTr(context, 'render.motion')),
                Slider(
                  key: const ValueKey('shader-manual-time'),
                  value: clock.value % 10,
                  max: 10,
                  semanticFormatterCallback: (value) =>
                      value.toStringAsFixed(2),
                  onChanged: (value) => change(() => clock.value = value),
                ),
              ],
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (mode != 0)
                    FilledButton(
                      onPressed: reducedMotion
                          ? null
                          : () {
                              change(() => playing = !playing);
                              syncTicker();
                            },
                      child: Text(
                        renderTr(
                          context,
                          playing ? 'render.pause' : 'render.play',
                        ),
                      ),
                    ),
                  OutlinedButton(
                    onPressed: () => change(() {
                      center = const Offset(.5, .5);
                      strength = .7;
                      radius = .32;
                      blend = 1;
                      speed = 1;
                      clock.value = 0;
                    }),
                    child: Text(renderTr(context, 'render.reset')),
                  ),
                  TextButton(
                    onPressed: saveParameters,
                    child: Text(renderTr(context, 'render.save')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    generation++;
    WidgetsBinding.instance.removeObserver(this);
    ticker.dispose();
    clock.dispose();
    shader?.dispose();
    texture?.dispose();
    super.dispose();
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.shader,
    required this.texture,
    required this.clock,
    required this.center,
    required this.mode,
    required this.strength,
    required this.radius,
    required this.blend,
    required this.brightness,
  }) : super(repaint: clock);
  final ui.FragmentShader? shader;
  final ui.Image? texture;
  final ValueNotifier<double> clock;
  final Offset center;
  final int mode;
  final double strength, radius, blend;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final effect = shader;
    final image = texture;
    if (effect == null || image == null) {
      CuratedScenePainter(scene: 4, brightness: brightness).paint(canvas, size);
    } else {
      effect.setFloat(0, size.width);
      effect.setFloat(1, size.height);
      effect.setFloat(2, clock.value);
      effect.setFloat(3, center.dx);
      effect.setFloat(4, center.dy);
      effect.setFloat(5, strength);
      effect.setFloat(6, radius);
      effect.setFloat(7, blend);
      effect.setFloat(8, mode.toDouble());
      effect.setFloat(9, brightness == Brightness.dark ? 1 : 0);
      effect.setImageSampler(0, image);
      canvas.drawRect(Offset.zero & size, Paint()..shader = effect);
    }
    final position = Offset(center.dx * size.width, center.dy * size.height);
    canvas.drawCircle(
      position,
      11,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(position, 3, Paint()..color = const Color(0xFF1C424A));
  }

  @override
  bool shouldRepaint(_ShaderPainter old) =>
      shader != old.shader ||
      texture != old.texture ||
      center != old.center ||
      mode != old.mode ||
      strength != old.strength ||
      radius != old.radius ||
      blend != old.blend ||
      brightness != old.brightness;
}
