import 'dart:io';
import 'package:flutter/material.dart';
// image_picker 插件只能分别调用拍照或录像功能，但不能直接调用系统相机应用的完整界面
import 'package:image_picker/image_picker.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
// 仅调取相机进行拍照和回调显示
// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID。比如
// flutter run lib/调用本地相册+调用本机摄像头拍照（全部验证通过）/CameraDemo2.dart -d 00008110-000625583EE3801E

// 权限问题：Flutter代码不配置设备权限。配置权限需要进入特定的代码里面，按照设备所属的代码规范进行配置。比如：
// iOS进入`info.plist`里面进行配置
// Android通常只涉及两个主要文件：`AndroidManifest.xml` 和 `build.gradle`

void main() => runApp(const JobsMaterialRunner(
    ImagePickerDemo(imageSource: ImageSource.camera),
    title: 'Image Picker Demo - Camera'));

class ImagePickerDemo extends StatefulWidget {
  final ImageSource imageSource;
  const ImagePickerDemo({super.key, required this.imageSource});
  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
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
        debugPrint('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker Demo - Camera'),
      ),
      body: Center(
        child: _image == null
            ? const Text('No image selected.')
            : Image.file(_image!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Take a Photo',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
