// 独立运行：flutter run -t "lib/demos/不可变模型与JSON解析/built_value.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/JSONs.analyze/built_value_demo✅/利用脚本自动生成的built_value序列化文件/video_item.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/JSONs.analyze/built_value_demo✅/利用脚本自动生成的built_value序列化文件/serializers.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '不可变模型与JSON解析');

// dependencies:
// # 数据处理
//   built_value: # 用于序列化/反序列化数据
//   built_value_generator: # 用于生成序列化/反序列化代码

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        title: 'Built Value JSON Parsing Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<VideoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/Jsons/data.json');
      final parsed = json.decode(jsonString);
      final videoList = serializers.deserializeWith(
        VideoList.serializer,
        parsed,
      );
      if (!mounted) return;
      setState(() {
        _items = videoList?.list.toList() ?? [];
      });
    } catch (e) {
      legacyDebugPrint('Error loading local JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(
        title: const LegacyText('Built Value JSON Parsing Demo'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: const AssetImage('assets/Images/flower.png'),
              foregroundImage: NetworkImage(item.head ?? ''),
              onForegroundImageError: (_, _) {},
            ),
            title: LegacyText(item.title ?? 'No Title'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LegacyText('昵称: ${item.nick_name ?? 'Unknown'}'),
                LegacyText('播放次数: ${item.play_count ?? '0'}'),
                LegacyText('点赞次数: ${item.agree_num ?? '0'}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_fill),
              onPressed: () {
                // 播放视频的逻辑，例如跳转到视频播放页面
              },
            ),
          );
        },
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'built_value');
