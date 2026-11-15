import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

import 'package:image_picker/image_picker.dart';

import '视频预览.dart';

class PostDraftDemo extends StatefulWidget {
  const PostDraftDemo({super.key});
  @override
  State<PostDraftDemo> createState() => _PostDraftState();
}

class _PostDraftState extends State<PostDraftDemo> {
  final text = TextEditingController();
  List<String> images = [];
  String? video;
  String snapshot = '';
  bool loaded = false;
  Map<String, dynamic> get draft => {
    'text': text.text,
    'images': images,
    'video': video,
  };
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final v = await UiDemoStore.read('post-draft', {
      'text': '',
      'images': <String>[],
      'video': null,
    });
    if (!mounted) return;
    setState(() {
      if (v is Map) {
        text.text = '${v['text'] ?? ''}';
        images = List<String>.from(v['images'] as List? ?? []);
        video = v['video'] as String?;
      }
      snapshot = jsonEncode(draft);
      loaded = true;
    });
  }

  Future<void> save() async {
    final result = await UiDemoStore.write('post-draft', draft);
    if (mounted && result is Map) {
      setState(() {
        text.text = '${result['text']}';
        images = List<String>.from(result['images'] as List);
        video = result['video'] as String?;
      });
    }
    if (mounted) {
      snapshot = jsonEncode(draft);
      uiNotice(context, '已保存');
    }
  }

  Future<void> pick(bool movie) async {
    try {
      if (movie) {
        final file = await ImagePicker().pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30),
        );
        if (file != null) {
          final bytes = await file.readAsBytes();
          if (!mounted) return;
          if (bytes.length > 2 * 1024 * 1024) {
            uiNotice(context, '视频最大2MB');
            return;
          }
          final mime =
              file.mimeType ??
              (file.name.toLowerCase().endsWith('.mov')
                  ? 'video/quicktime'
                  : 'video/mp4');
          final value = Uri.dataFromBytes(bytes, mimeType: mime).toString();
          setState(() => video = value);
        }
      } else {
        final files = await ImagePicker().pickMultiImage(
          maxWidth: 1200,
          imageQuality: 75,
        );
        for (final f in files.take(9 - images.length)) {
          final bytes = await f.readAsBytes();
          if (mounted) setState(() => images.add(base64Encode(bytes)));
        }
      }
    } catch (_) {
      if (mounted) uiNotice(context, '失败');
    }
  }

  Future<void> leave() async {
    if (!loaded || snapshot == jsonEncode(draft)) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final choice = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(uiTr(context, '草稿')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 0),
            child: Text(uiTr(context, '继续编辑')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 1),
            child: Text(uiTr(context, '放弃并退出')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 2),
            child: Text(uiTr(context, '保存并退出')),
          ),
        ],
      ),
    );
    if (choice == 2) await save();
    if (mounted && (choice == 1 || choice == 2)) Navigator.pop(context);
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (p, _) {
      if (!p) leave();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: leave),
        title: Text(uiTr(context, '发帖草稿')),
        actions: [
          IconButton(
            tooltip: uiTr(context, '保存'),
            onPressed: save,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: text,
            maxLength: 10,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(labelText: uiTr(context, '内容')),
          ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: images.length >= 9 ? null : () => pick(false),
                icon: const Icon(Icons.photo),
                label: Text('${uiTr(context, '图片')} ${images.length}/9'),
              ),
              OutlinedButton.icon(
                onPressed: () => pick(true),
                icon: const Icon(Icons.video_library),
                label: Text(uiTr(context, '视频')),
              ),
            ],
          ),
          for (var i = 0; i < images.length; i++)
            Dismissible(
              key: ValueKey('$i-${images[i].hashCode}'),
              onDismissed: (_) => setState(() => images.removeAt(i)),
              child: ListTile(
                leading: Image.memory(
                  base64Decode(images[i]),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
                title: Text('${uiTr(context, '图片')} ${i + 1}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: i == 0
                          ? null
                          : () {
                              setState(() {
                                final image = images.removeAt(i);
                                images.insert(i - 1, image);
                              });
                            },
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      tooltip: uiTr(context, '删除'),
                      onPressed: () => setState(() => images.removeAt(i)),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          if (video != null)
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(uiTr(context, '视频')),
              subtitle: Text(uiTr(context, '点击预览')),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => DraftVideoPreview(source: video!),
                ),
              ),
              trailing: IconButton(
                onPressed: () => setState(() => video = null),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          const SizedBox(height: 16),
          Text(uiTr(context, '本地演示')),
        ],
      ),
    ),
  );
}

void main() => runApp(const JobsDemoApp(home: PostDraftDemo(), title: '发帖草稿'));
