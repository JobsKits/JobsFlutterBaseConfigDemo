// 独立运行：flutter run -t "lib/demos/Markdown文档/Markdown文档.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(
  const JobsDemoApp(home: MarkdownDocumentsDemo(), title: 'Markdown文档'),
);

class MarkdownDocumentsDemo extends StatefulWidget {
  const MarkdownDocumentsDemo({super.key});
  @override
  State<MarkdownDocumentsDemo> createState() => _MarkdownDocumentsState();
}

class _MarkdownDocumentsState extends State<MarkdownDocumentsDemo> {
  final source = TextEditingController(
    text: '# Jobs Flutter\n\n**Flutter** / *Dart*\n\n- [x] Widget\n- [ ] Animation\n\n| API | Result |\n| --- | --- |\n| Future | async |\n\n```dart\nvoid main() {}\n```\n\n> Jobs Feature Lab\n\n[Flutter](https://flutter.dev)',
  );
  bool editing = false;
  @override
  void initState() {
    super.initState();
    UiDemoStore.read('markdown', null).then((v) {
      if (mounted && v is String) setState(() => source.text = v);
    });
  }

  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  Future<void> open() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'txt'],
      withData: true,
    );
    final Uint8List? bytes = result?.files.single.bytes;
    if (!mounted || bytes == null) return;
    try {
      setState(() => source.text = utf8.decode(bytes));
    } catch (_) {
      uiNotice(context, '失败');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, 'Markdown文档')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '读取'),
          onPressed: open,
          icon: const Icon(Icons.folder_open),
        ),
        IconButton(
          tooltip: uiTr(context, '保存'),
          onPressed: () async {
            final result = await UiDemoStore.write('markdown', source.text);
            if (mounted && result is String)
              setState(() => source.text = result);
            if (mounted) uiNotice(context, '已保存');
          },
          icon: const Icon(Icons.save_outlined),
        ),
        IconButton(
          tooltip: uiTr(context, '继续编辑'),
          onPressed: () => setState(() => editing = !editing),
          icon: Icon(editing ? Icons.visibility : Icons.edit_outlined),
        ),
      ],
    ),
    body: editing
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: source,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          )
        : Markdown(
            data: source.text,
            selectable: true,
            onTapLink: (text, href, title) async {
              final uri = Uri.tryParse(href ?? '');
              if (uri != null &&
                  ['https', 'http', 'mailto'].contains(uri.scheme))
                await launchUrl(uri);
            },
            imageBuilder: (uri, title, alt) => uri.path.startsWith('assets/')
                ? Image.asset(uri.path)
                : const Icon(Icons.image_not_supported),
          ),
  );
}
