// 独立运行：flutter run -t "lib/demos/方法重写与继承/JobsOverrideDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '方法重写与继承');

void legacyOriginalMain() {
  SubClass().someMethod(); // Output: SubClass someMethod
  SubClass().nonExistentMethod(); // Output: SubClass nonExistentMethod
}

class JobsOverride {
  const JobsOverride();
}

const jobsOverride = JobsOverride();

class SuperClass {
  void someMethod() {
    legacyDebugPrint("SuperClass someMethod");
  }
}

class SubClass extends SuperClass {
  @override
  @jobsOverride
  void someMethod() {
    legacyDebugPrint("SubClass someMethod");
  }

  // This should ideally cause an error, but Dart does not enforce it at compile time
  @jobsOverride
  void nonExistentMethod() {
    legacyDebugPrint("SubClass nonExistentMethod");
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'JobsOverrideDemo');
