// 独立运行：flutter run -t "lib/demos/个人资料编辑/个人资料编辑.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() => runApp(const JobsDemoApp(home: ProfileEditorDemo()));

class ProfileEditorDemo extends StatefulWidget {
  const ProfileEditorDemo({super.key});
  @override
  State<ProfileEditorDemo> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditorDemo> {
  final name = TextEditingController(text: 'Jobs');
  final bio = TextEditingController(text: 'Flutter / iOS');
  final hometown = TextEditingController();
  final profession = TextEditingController(text: 'Developer');
  final form = GlobalKey<FormState>();
  bool saving = false;
  String? avatar;
  int gender = 2, relationship = 2;
  DateTime birthday = DateTime(2000, 1, 1);
  Map<String, Object?> get profile => {
    'name': name.text.trim(),
    'bio': bio.text,
    'hometown': hometown.text,
    'profession': profession.text,
    'avatar': avatar,
    'gender': gender,
    'relationship': relationship,
    'birthday': birthday.toIso8601String(),
  };
  @override
  void initState() {
    super.initState();
    UiDemoStore.read('profile', profile).then((value) {
      if (!mounted || value is! Map) return;
      setState(() {
        name.text = '${value['name'] ?? ''}';
        bio.text = '${value['bio'] ?? ''}';
        hometown.text = '${value['hometown'] ?? ''}';
        profession.text = '${value['profession'] ?? ''}';
        avatar = value['avatar'] as String?;
        if (avatar != null) {
          try {
            base64Decode(avatar!);
          } catch (_) {
            avatar = null;
          }
        }
        gender = (value['gender'] as num?)?.toInt().clamp(0, 2) ?? 2;
        relationship =
            (value['relationship'] as num?)?.toInt().clamp(0, 2) ?? 2;
        birthday = DateTime.tryParse('${value['birthday']}') ?? birthday;
        if (birthday.isAfter(DateTime.now())) birthday = DateTime.now();
        if (birthday.isBefore(DateTime(1900))) birthday = DateTime(1900);
      });
    });
  }

  @override
  void dispose() {
    for (final c in [name, bio, hometown, profession]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickAvatar() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        imageQuality: 80,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (mounted) setState(() => avatar = base64Encode(bytes));
    } catch (_) {
      if (mounted) uiNotice(context, '失败');
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => saving = true);
    final value = await UiDemoStore.write('profile', profile);
    if (!mounted) return;
    if (value is Map) {
      name.text = '${value['name'] ?? name.text}';
      bio.text = '${value['bio'] ?? bio.text}';
    }
    setState(() => saving = false);
    uiNotice(context, '已保存');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '个人资料编辑'))),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: InkWell(
              onTap: pickAvatar,
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 42,
                backgroundImage: avatar == null
                    ? null
                    : MemoryImage(base64Decode(avatar!)),
                child: avatar == null
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
            ),
          ),
          TextButton(onPressed: pickAvatar, child: Text(uiTr(context, '头像'))),
          TextFormField(
            controller: name,
            maxLength: 24,
            decoration: InputDecoration(labelText: uiTr(context, '昵称')),
            validator: (v) =>
                v == null || v.trim().isEmpty ? uiTr(context, '必填') : null,
          ),
          DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: gender,
            decoration: InputDecoration(labelText: uiTr(context, '性别')),
            items: [
              for (var i = 0; i < 3; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(uiTr(context, ['女', '男', '不想透露'][i])),
                ),
            ],
            onChanged: (v) => setState(() => gender = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: bio,
            maxLength: 160,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: uiTr(context, '简介')),
          ),
          OutlinedButton(
            onPressed: () async {
              final value = await showDatePicker(
                context: context,
                initialDate: birthday,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (value != null && mounted) setState(() => birthday = value);
            },
            child: Text(
              '${uiTr(context, '生日')}: ${MaterialLocalizations.of(context).formatMediumDate(birthday)}',
            ),
          ),
          DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: relationship,
            decoration: InputDecoration(labelText: uiTr(context, '情感')),
            items: [
              for (var i = 0; i < 3; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(uiTr(context, ['已婚', '单身', '不想透露'][i])),
                ),
            ],
            onChanged: (v) => setState(() => relationship = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: hometown,
            decoration: InputDecoration(labelText: uiTr(context, '家乡')),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: profession,
            decoration: InputDecoration(labelText: uiTr(context, '职业')),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(uiTr(context, saving ? '运行中' : '保存')),
          ),
        ],
      ),
    ),
  );
}
