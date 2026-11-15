import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: GraphicCaptchaDemo()));

class GraphicCaptchaDemo extends StatefulWidget {
  const GraphicCaptchaDemo({super.key});

  @override
  State<GraphicCaptchaDemo> createState() => _GraphicCaptchaDemoState();
}

class _GraphicCaptchaDemoState extends State<GraphicCaptchaDemo> {
  static const _groups = <String, String>{
    'A–Z': 'ABCDEFGHJKLMNPQRSTUVWXYZ',
    'a–z': 'abcdefghijkmnpqrstuvwxyz',
    '0–9': '23456789',
    '简体中文': '春夏秋冬山水天地花草森林星月光明',
    '繁體中文': '風雲龍馬國學書畫門開東來長樂無窮',
  };
  final _input = TextEditingController();
  final _random = Random.secure();
  final _selected = <String>{'A–Z', 'a–z', '0–9'};
  late String _code;
  int _length = 4;
  late int _seed;
  bool _caseSensitive = true;
  bool? _valid;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _generate() {
    final groups = _selected.map((key) => _groups[key]!).toList();
    final alphabet = groups.join();
    // 每个已勾选字符组至少出现一次，长度不足时上调。
    _length = max(_length, groups.length);
    final characters = [
      for (final group in groups) group[_random.nextInt(group.length)],
      for (int index = groups.length; index < _length; index++)
        alphabet[_random.nextInt(alphabet.length)],
    ]..shuffle(_random);
    _code = characters.join();
    _seed = _random.nextInt(1 << 30);
    _valid = null;
    _input.clear();
  }

  void _validate() => setState(() {
    final input = _input.text.trim();
    _valid = _caseSensitive
        ? input == _code
        : input.toLowerCase() == _code.toLowerCase();
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, '图形验证码'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            tr(context, '本地教学验证码不用于生产认证'),
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Semantics(
                button: true,
                label: tr(context, '刷新'),
                child: InkWell(
                  onTap: () => setState(_generate),
                  borderRadius: BorderRadius.circular(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: CustomPaint(
                        key: const ValueKey('graphic-captcha'),
                        painter: _CaptchaPainter(_code, _seed, colors),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _groups.keys
                .map(
                  (group) => FilterChip(
                    label: Text(group),
                    selected: _selected.contains(group),
                    onSelected: (selected) {
                      if (!selected && _selected.length == 1) return;
                      setState(() {
                        selected
                            ? _selected.add(group)
                            : _selected.remove(group);
                        _generate();
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(tr(context, '长度')),
              Expanded(
                child: Slider(
                  value: _length.toDouble(),
                  min: 4,
                  max: 8,
                  divisions: 4,
                  label: '$_length',
                  onChanged: (value) => setState(() {
                    _length = value.round();
                    _generate();
                  }),
                ),
              ),
              Text('$_length'),
            ],
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(tr(context, '区分大小写')),
            value: _caseSensitive,
            onChanged: (value) => setState(() {
              _caseSensitive = value;
              _valid = null;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('captcha-input'),
            controller: _input,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(labelText: tr(context, '输入图形验证码')),
            onSubmitted: (_) => _validate(),
            onChanged: (_) {
              if (_valid != null) setState(() => _valid = null);
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _validate,
                child: Text(tr(context, '校验')),
              ),
              OutlinedButton(
                onPressed: () => setState(_generate),
                child: Text(tr(context, '刷新')),
              ),
            ],
          ),
          if (_valid != null) ...[
            const SizedBox(height: 20),
            Semantics(
              liveRegion: true,
              child: Text(
                tr(context, _valid! ? '验证通过' : '验证失败'),
                style: TextStyle(
                  color: _valid! ? colors.primary : colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CaptchaPainter extends CustomPainter {
  _CaptchaPainter(this.code, this.seed, this.colors);
  final String code;
  final int seed;
  final ColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = colors.surfaceContainerHighest,
    );
    final noise = Paint()
      ..color = colors.onSurfaceVariant.withValues(alpha: 0.23)
      ..strokeWidth = 1;
    for (var index = 0; index < 45; index++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        1.5,
        noise,
      );
    }
    for (var index = 0; index < 6; index++) {
      canvas.drawLine(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        noise,
      );
    }
    final cell = size.width / (code.length + 1);
    for (var index = 0; index < code.length; index++) {
      final text = TextPainter(
        text: TextSpan(
          text: code[index],
          style: TextStyle(
            color: index.isEven ? colors.onSurface : colors.primary,
            fontSize: min(42, cell * 0.85),
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(cell * (index + 1), size.height / 2);
      canvas.rotate((random.nextDouble() - 0.5) * 0.32);
      text.paint(canvas, Offset(-text.width / 2, -text.height / 2));
      canvas.restore();
      text.dispose();
    }
  }

  @override
  bool shouldRepaint(_CaptchaPainter oldDelegate) =>
      code != oldDelegate.code ||
      seed != oldDelegate.seed ||
      colors != oldDelegate.colors;
}
