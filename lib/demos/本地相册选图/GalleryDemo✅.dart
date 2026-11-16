// 独立运行：flutter run -t "lib/demos/本地相册选图/GalleryDemo✅.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '本地相册选图');

// 仅调取相册进行照片选取显示
// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID
// flutter run lib/调用本地相册+调用本机摄像头拍照（全部验证通过）/GalleryDemo.dart -d 00008110-000625583EE3801E

// 权限问题：Flutter代码不配置设备权限。配置权限需要进入特定的代码里面，按照设备所属的代码规范进行配置。比如：
// iOS进入`info.plist`里面进行配置
// Android通常只涉及两个主要文件：`AndroidManifest.xml` 和 `build.gradle`
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(
    ImagePickerDemo(imageSource: ImageSource.gallery),
    title: 'Image Picker Demo - Gallery',
  ),
);

class ImagePickerDemo extends StatefulWidget {
  final ImageSource imageSource;

  const ImagePickerDemo({super.key, required this.imageSource});

  @override
  State<ImagePickerDemo> createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: widget.imageSource);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        legacyDebugPrint('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(
        title: const LegacyText('Image Picker Demo - Gallery'),
      ),
      body: Center(
        child: _image == null
            ? const LegacyText('No image selected.')
            : Image.file(_image!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: legacyControlLabel(context, 'Pick Image from gallery'),
        child: const Icon(Icons.photo_library),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    const ImagePickerDemo(imageSource: ImageSource.gallery);
