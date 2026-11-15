import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_demo_foundation/jobs_input_tools.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../demo_hub/legacy_strings.dart';

void main() {
  registerLegacyTranslations();
  runApp(const JobsDemoApp(title: '输入框与多行文本组合', home: InputCombinationDemo()));
}

Widget buildLegacyDemo(BuildContext context) => const InputCombinationDemo();

class InputCombinationDemo extends StatefulWidget {
  const InputCombinationDemo({super.key});
  @override
  State<InputCombinationDemo> createState() => _InputCombinationDemoState();
}

class _InputCombinationDemoState extends State<InputCombinationDemo> {
  final email = TextEditingController(), password = TextEditingController();
  final note = TextEditingController(),
      money = TextEditingController(text: '123.45');
  final phone = TextEditingController(text: '138 0013 8000');
  final bindingA = TextEditingController(text: 'Hello Value'),
      bindingB = TextEditingController(text: 'Hello Value');
  final deletion = TextEditingController(text: 'Delete me');
  final passwordFocus = FocusNode();
  final events = <String>[];
  final previous = <String, String>{};
  late final List<TapGestureRecognizer> links;
  bool syncing = false;

  @override
  void initState() {
    super.initState();
    for (final entry in {
      'email': email,
      'password': password,
      'note': note,
      'money': money,
      'phone': phone,
      'delete': deletion,
    }.entries) {
      previous[entry.key] = entry.value.text;
      entry.value.addListener(() => record(entry.key, entry.value.text));
    }
    bindingA.addListener(() => sync(bindingA, bindingB));
    bindingB.addListener(() => sync(bindingB, bindingA));
    links = [
      for (final uri in [
        'https://www.apple.com',
        'https://www.google.com',
        'tel:4001234567',
      ])
        TapGestureRecognizer()..onTap = () => open(uri),
    ];
  }

  void record(String field, String value) {
    final old = previous[field] ?? '';
    if (old == value) return;
    previous[field] = value;
    final mode = jobsInputMode(old, value);
    setState(() {
      events.insert(0, '$field · $mode · ${value.characters.length}');
      if (events.length > 8) events.removeLast();
    });
    if (field == 'delete' && mode == 'delete') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: LegacyText('检测到删除键')));
    }
  }

  void sync(TextEditingController source, TextEditingController target) {
    if (syncing) return;
    syncing = true;
    if (target.text != source.text) target.value = source.value;
    syncing = false;
    setState(() {});
  }

  Future<void> open(String value) async {
    try {
      if (await launchUrl(Uri.parse(value))) return;
    } catch (_) {}
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: LegacyText('无法打开链接')));
  }

  @override
  void dispose() {
    for (final c in [
      email,
      password,
      note,
      money,
      phone,
      bindingA,
      bindingB,
      deletion,
    ]) {
      c.dispose();
    }
    for (final link in links) {
      link.dispose();
    }
    passwordFocus.dispose();
    super.dispose();
  }

  InputDecoration decoration(
    String label, {
    TextEditingController? clear,
    bool? valid,
  }) => legacyInputDecoration(
    context,
    InputDecoration(
      labelText: label,
      suffixIcon: clear == null
          ? null
          : IconButton(
              tooltip: legacyUiText(context, '清空'),
              onPressed: clear.clear,
              icon: const Icon(Icons.clear),
            ),
      enabledBorder: valid == null
          ? null
          : OutlineInputBorder(
              borderSide: BorderSide(
                color: valid
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
            ),
    ),
  );
  Widget field(
    String key,
    TextEditingController controller,
    String label, {
    int lines = 1,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    bool? valid,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      key: ValueKey(key),
      controller: controller,
      maxLines: lines,
      keyboardType: keyboard,
      inputFormatters: formatters,
      maxLength: maxLength,
      decoration: decoration(label, clear: controller, valid: valid),
    ),
  );
  Widget heading(String value) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: LegacyText(value, style: Theme.of(context).textTheme.titleMedium),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const LegacyText('输入框与多行文本组合')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        heading('单行输入、长度限制与焦点切换'),
        TextField(
          key: const ValueKey('input-email'),
          controller: email,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(8),
          ],
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => passwordFocus.requestFocus(),
          decoration: decoration(
            '邮箱：去空格，最长8位',
            clear: email,
            valid: email.text.length >= 3 && email.text.contains('@'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('input-password'),
          controller: password,
          focusNode: passwordFocus,
          obscureText: true,
          inputFormatters: [LengthLimitingTextInputFormatter(5)],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: decoration('密码：最长5位', clear: password),
        ),
        heading('多行输入监听与提示计数'),
        field('input-note', note, '输入内容', lines: 3),
        LegacyText(
          '${note.text.characters.length} / 12',
          style: TextStyle(
            color: note.text.characters.length > 12
                ? Theme.of(context).colorScheme.error
                : null,
          ),
        ),
        heading('金额格式化与范围校验'),
        field(
          'input-money',
          money,
          '金额：两位小数，0到999999',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          formatters: [
            JobsMoneyInputFormatter(),
            LengthLimitingTextInputFormatter(10),
          ],
          valid: jobsValidMoney(money.text),
        ),
        heading('手机号分组与11位校验'),
        field(
          'input-phone',
          phone,
          '手机号：3-4-4分组',
          keyboard: TextInputType.phone,
          formatters: [JobsPhoneInputFormatter()],
          valid: jobsValidPhone(phone.text),
        ),
        heading('富文本链接与电话号码识别'),
        SelectableText.rich(
          TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: [
              TextSpan(
                text: 'Apple',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: links[0],
              ),
              const TextSpan(text: '  ·  '),
              TextSpan(
                text: 'Google',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  decoration: TextDecoration.underline,
                ),
                recognizer: links[1],
              ),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '400-123-4567',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                recognizer: links[2],
              ),
            ],
          ),
        ),
        heading('双向绑定：A ⇄ B ⇄ Value'),
        field('input-binding-a', bindingA, '文本 A', lines: 2),
        field('input-binding-b', bindingB, '文本 B', lines: 2),
        LegacyText('Value: ${bindingA.text}'),
        heading('删除键监听'),
        field('input-delete', deletion, '删除文字以查看事件', lines: 2),
        heading('输入事件记录'),
        if (events.isEmpty)
          JobsEmptyState(
            title: legacyUiText(context, '暂无输入事件'),
            onReload: () => setState(() => events.clear()),
          )
        else
          ...events.map(
            (e) => Padding(padding: const EdgeInsets.all(4), child: Text(e)),
          ),
      ],
    ),
  );
}
