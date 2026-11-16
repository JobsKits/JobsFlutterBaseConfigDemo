// 独立运行：flutter run -t "lib/demos/字符串压缩/字符串压缩.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: CompressionDemo(), title: '字符串压缩'));

class CompressionDemo extends StatefulWidget {
  const CompressionDemo({super.key});
  @override
  State<CompressionDemo> createState() => _State();
}

class _State extends State<CompressionDemo> {
  final input = TextEditingController(
    text: List.filled(8, 'Jobs Flutter 中文字符 🐦').join('\n'),
  );
  final encoded = TextEditingController();
  String output = '';
  @override
  void dispose() {
    input.dispose();
    encoded.dispose();
    super.dispose();
  }

  void run(bool compress) {
    try {
      setState(() {
        if (compress) {
          encoded.text = JobsLabCodec.compress(input.text);
          output =
              'UTF-8: ${utf8.encode(input.text).length} bytes\nGZIP: ${base64Decode(encoded.text).length} bytes';
        } else {
          output = JobsLabCodec.decompress(encoded.text);
        }
      });
    } catch (error) {
      setState(() => output = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '字符串压缩',
    children: [
      TextField(
        controller: input,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(labelText: labTr(context, '内容')),
      ),
      labAction(context, '压缩', () => run(true)),
      TextField(
        controller: encoded,
        minLines: 2,
        maxLines: 5,
        decoration: const InputDecoration(labelText: 'GZIP / Base64'),
      ),
      labAction(context, '解压缩', () => run(false)),
      labOutput(context, output),
    ],
  );
}
