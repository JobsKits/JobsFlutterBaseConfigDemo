import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

void legacyOriginalMain() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(MyAppLifecycleObserver());
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const LegacyText('Lifecycle Management')),
          body: const Center(
            child: LegacyText('Check the console for lifecycle events'),
          ),
        ),
      ),
    );
  }
}

class MyAppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    legacyDebugPrint('App lifecycle state changed to $state');
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·应用生命周期调度');
