import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobs_flutter_base_config/demos/系统相机拍照/源码/CameraPicDemo✅.dart'
    as old;

// 兼容入口保留原 Demo 实现；编辑原文件后可直接运行本文件预览。
void main() => runApp(
  JobsDemoApp(
    title: '系统相机拍照',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) =>
    const old.ImagePickerDemo(imageSource: ImageSource.camera);
