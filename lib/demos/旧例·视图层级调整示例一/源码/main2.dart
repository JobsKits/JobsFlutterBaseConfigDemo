import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: MaterialApp(
        home: const PageA(),
        routes: {
          '/pageA': (context) => const PageA(),
          '/pageB': (context) => const PageB(),
          '/pageC': (context) => const PageC(),
        },
      ),
    ),
  );
}

// PageA
class PageA extends StatelessWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Page A')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/pageB');
          },
          child: const LegacyText('Go to Page B'),
        ),
      ),
    );
  }
}

// PageB
class PageB extends StatelessWidget {
  const PageB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Page B')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/pageC');
          },
          child: const LegacyText('Go to Page C'),
        ),
      ),
    );
  }
}

// PageC
class PageC extends StatelessWidget {
  const PageC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Page C')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 将 PageA 置于顶层，并关闭所有其他页面
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/pageA',
              (route) => route.isFirst,
            );
          },
          child: const LegacyText('Go back to Page A'),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·视图层级调整示例一');
