import 'package:flutter/material.dart';

import 'ui_parity_strings.dart';

void uiNotice(BuildContext context, String key) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(uiTr(context, key))));
Widget uiEmpty(BuildContext context, VoidCallback reload) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.inbox_outlined, size: 48),
      const SizedBox(height: 16),
      Text(uiTr(context, '暂无数据')),
      const SizedBox(height: 16),
      FilledButton(onPressed: reload, child: Text(uiTr(context, '重新加载'))),
    ],
  ),
);
Future<String?> uiInput(
  BuildContext context,
  String title, {
  String initial = '',
}) async {
  final input = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(uiTr(context, title)),
      content: TextField(
        controller: input,
        autofocus: true,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(uiTr(context, '取消')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, input.text),
          child: Text(uiTr(context, '确认')),
        ),
      ],
    ),
  );
  // Dialog reverse transition may still own the field until the next frame.
  await Future<void>.delayed(const Duration(milliseconds: 350));
  input.dispose();
  return result;
}
