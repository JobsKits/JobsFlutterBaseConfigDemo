// 独立运行：flutter run -t "lib/demos/图片加盐存储/图片加盐存储.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: SaltedImageDemo(), title: '图片加盐存储'));

class SaltedImageDemo extends StatefulWidget {
  const SaltedImageDemo({super.key});
  @override
  State<SaltedImageDemo> createState() => _State();
}

class _State extends State<SaltedImageDemo> {
  final password = TextEditingController(text: 'Jobs-demo-only');
  final encoded = TextEditingController();
  Uint8List? image;
  String status = '';
  final store = JobsLabSandbox('salted_image');
  @override
  void dispose() {
    password.dispose();
    encoded.dispose();
    super.dispose();
  }

  Future<void> save() async {
    try {
      final bytes = (await rootBundle.load('assets/Images/flower.png')).buffer
          .asUint8List();
      final value = JobsLabCodec.sealImage(bytes, password.text);
      await store.write('image.json', value);
      if (mounted)
        setState(() {
          encoded.text = value;
          image = null;
          status = 'AES-GCM / ${bytes.length} bytes';
        });
    } catch (error) {
      if (mounted) setState(() => status = error.toString());
    }
  }

  Future<void> load() async {
    try {
      final value = encoded.text.isEmpty
          ? await store.read('image.json')
          : encoded.text;
      final bytes = JobsLabCodec.openImage(value!, password.text);
      if (mounted)
        setState(() {
          image = bytes;
          status = '${bytes.length} bytes';
        });
    } catch (error) {
      if (mounted) setState(() => status = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '图片加盐存储',
    children: [
      TextField(
        controller: password,
        obscureText: true,
        decoration: InputDecoration(labelText: labTr(context, '密码')),
      ),
      Wrap(
        spacing: 8,
        children: [
          labAction(context, '保存', save),
          labAction(context, '读取', load),
        ],
      ),
      TextField(
        controller: encoded,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'AES-GCM / JSON'),
      ),
      if (image != null) Image.memory(image!, height: 220, fit: BoxFit.contain),
      labOutput(context, status),
    ],
  );
}
