import 'dart:typed_data';
import 'dart:async';

import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: PDFDocumentLabDemo()));

class PDFDocumentLabDemo extends StatefulWidget {
  const PDFDocumentLabDemo({super.key});
  @override
  State<PDFDocumentLabDemo> createState() => _PDFDocumentLabDemoState();
}

class _PDFDocumentLabDemoState extends State<PDFDocumentLabDemo> {
  final state = NativeLabState();
  final password = TextEditingController();
  int pages = 0;
  int index = 0;
  Uint8List? raster;
  Future<void> open() async {
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    final bytes = selection?.files.first.bytes;
    if (bytes == null) return;
    final value = await state.run('pdf.open', {
      'bytes': bytes,
      'password': password.text,
    });
    if (value is Map && mounted) {
      setState(() {
        pages = value['pages'] as int;
        index = 0;
      });
      await render();
    }
  }

  Future<void> render() async {
    final value = await state.run('pdf.page', {'index': index, 'width': 1200});
    if (value is Uint8List && mounted) setState(() => raster = value);
  }

  @override
  void dispose() {
    if (JobsPlatformLab.hasNativeBridge) {
      unawaited(JobsPlatformLab.invoke<void>('pdf.close').catchError((_) {}));
    }
    state.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: 'PDF文档浏览',
    state: state,
    children: [
      TextField(
        controller: password,
        obscureText: true,
        decoration: InputDecoration(labelText: platformText(context, '密码')),
      ),
      FilledButton(
        onPressed: open,
        child: Text(platformText(context, '打开PDF')),
      ),
      if (raster != null)
        SizedBox(
          height: 420,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Image.memory(raster!),
          ),
        ),
      Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${index + 1} / $pages'),
          FilledButton.tonal(
            onPressed: index > 0
                ? () async {
                    setState(() => index--);
                    await render();
                  }
                : null,
            child: Text(platformText(context, '上一页')),
          ),
          FilledButton.tonal(
            onPressed: index + 1 < pages
                ? () async {
                    setState(() => index++);
                    await render();
                  }
                : null,
            child: Text(platformText(context, '下一页')),
          ),
        ],
      ),
    ],
  );
}
