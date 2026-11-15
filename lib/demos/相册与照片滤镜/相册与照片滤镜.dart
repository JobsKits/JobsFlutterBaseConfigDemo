import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/extra_support.dart';

void main() => runApp(const JobsDemoApp(home: PhotoFiltersLabDemo()));

class PhotoFiltersLabDemo extends StatefulWidget {
  const PhotoFiltersLabDemo({super.key});
  @override
  State<PhotoFiltersLabDemo> createState() => _State();
}

class _State extends State<PhotoFiltersLabDemo> {
  final preview = GlobalKey();
  Uint8List? bytes;
  String? error;
  int mode = 0;
  double brightness = 0;
  bool busy = false;
  static const matrices = <List<double>>[
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
    [
      .2126,
      .7152,
      .0722,
      0,
      0,
      .2126,
      .7152,
      .0722,
      0,
      0,
      .2126,
      .7152,
      .0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
    [
      .393,
      .769,
      .189,
      0,
      0,
      .349,
      .686,
      .168,
      0,
      0,
      .272,
      .534,
      .131,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
    [-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0],
    [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0],
    [
      1.5,
      -.25,
      -.25,
      0,
      0,
      -.25,
      1.5,
      -.25,
      0,
      0,
      -.25,
      -.25,
      1.5,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
  ];
  @override
  void initState() {
    super.initState();
    restore();
  }

  Future<void> restore() async {
    try {
      final data = await rootBundle.load('assets/flower.png');
      if (mounted)
        setState(() {
          bytes = data.buffer.asUint8List();
          error = null;
        });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  Future<void> pick(ImageSource source) async {
    setState(() => busy = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (file != null) {
        final data = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(data);
        codec.dispose();
        if (mounted)
          setState(() {
            bytes = data;
            error = null;
          });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          preview.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: extraTr(context, '保存滤镜图片'),
        fileName: 'Jobs-filter.png',
        type: FileType.custom,
        allowedExtensions: ['png'],
        bytes: data!.buffer.asUint8List(),
      );
      if (mounted && path != null)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(extraTr(context, '保存成功'))));
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrix = [...matrices[mode]];
    for (final i in [4, 9, 14]) {
      matrix[i] += brightness * 255;
    }
    return ExtraFrame(
      title: '相册与照片滤镜',
      children: [
        if (error != null)
          JobsEmptyState(title: '加载失败', message: error, onReload: restore),
        if (bytes != null)
          RepaintBoundary(
            key: preview,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(matrix),
              child: Image.memory(
                bytes!,
                height: 280,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < matrices.length; i++)
              ChoiceChip(
                label: Text(
                  extraTr(context, ['原图', '黑白', '怀旧', '反色', '通道交换', '高饱和'][i]),
                ),
                selected: mode == i,
                onSelected: (_) => setState(() => mode = i),
              ),
          ],
        ),
        Text(extraTr(context, '亮度')),
        Slider(
          min: -.5,
          max: .5,
          value: brightness,
          onChanged: (v) => setState(() => brightness = v),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: busy ? null : () => pick(ImageSource.gallery),
              child: Text(extraTr(context, '选择相册')),
            ),
            FilledButton(
              onPressed: busy ? null : () => pick(ImageSource.camera),
              child: Text(extraTr(context, '相机拍照')),
            ),
            OutlinedButton(
              onPressed: busy || bytes == null ? null : save,
              child: Text(extraTr(context, '保存滤镜图片')),
            ),
          ],
        ),
      ],
    );
  }
}
