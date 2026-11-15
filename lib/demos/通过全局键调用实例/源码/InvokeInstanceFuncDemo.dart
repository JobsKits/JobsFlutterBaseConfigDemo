import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(title: 'Flutter Demo', home: HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  // 定义GlobalKey
  final GlobalKey<_AState> _aKey = GlobalKey<_AState>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //其他地方用这个aKey
    // Get.put(_aKey);
    // final GlobalKey<_AState> _aKey = Get.find();
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Home Page')),
      body: Column(
        children: [
          A(key: _aKey),
          ElevatedButton(
            onPressed: () {
              // 通过GlobalKey调用实例方法
              _aKey.currentState?.dd();
            },
            child: const LegacyText('Call Instance Method'),
          ),
        ],
      ),
    );
  }
}

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  void dd() {
    legacyDebugPrint("sss");
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: LegacyText('Main Page Content'));
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '通过全局键调用实例');
