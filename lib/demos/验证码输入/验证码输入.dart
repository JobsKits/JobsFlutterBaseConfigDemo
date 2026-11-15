import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: CodeInputDemo()));

class CodeInputDemo extends StatefulWidget {
  const CodeInputDemo({super.key});
  @override
  State<CodeInputDemo> createState() => _CodeInputDemoState();
}

class _CodeInputDemoState extends State<CodeInputDemo> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '验证码输入'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          tr(context, '输入六位数字'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _input,
          focusNode: _focus,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            labelText: tr(context, '验证码输入'),
            counterText: '${_input.text.length}/6',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (i) => Semantics(
                label: '${i + 1}',
                child: Container(
                  width: (constraints.maxWidth / 6 - 6).clamp(12, 56),
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: i == _input.text.length
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    i < _input.text.length ? _input.text[i] : '·',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_input.text.length == 6)
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(tr(context, '验证成功')),
          ),
        OutlinedButton(
          onPressed: () {
            setState(_input.clear);
            _focus.requestFocus();
          },
          child: Text(tr(context, '恢复默认')),
        ),
      ],
    ),
  );
}
