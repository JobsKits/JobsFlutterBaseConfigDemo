import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

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

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·方法重写与继承');
