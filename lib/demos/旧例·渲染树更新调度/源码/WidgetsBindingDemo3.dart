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
      app: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const LegacyText('Render Tree Update')),
          body: const RenderUpdateDemo(),
        ),
      ),
    );
  }
}

class RenderUpdateDemo extends StatefulWidget {
  const RenderUpdateDemo({super.key});

  @override
  State<RenderUpdateDemo> createState() => _RenderUpdateDemoState();
}

class _RenderUpdateDemoState extends State<RenderUpdateDemo> {
  String _message = "Initial State";

  void _updateUI() {
    setState(() {
      _message = "UI Updated!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LegacyText(_message, style: const TextStyle(fontSize: 24)),
          ElevatedButton(
            onPressed: _updateUI,
            child: const LegacyText('Update UI'),
          ),
        ],
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·渲染树更新调度');
