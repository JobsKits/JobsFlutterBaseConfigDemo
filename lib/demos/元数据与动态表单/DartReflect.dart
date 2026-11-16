// 独立运行：flutter run -t "lib/demos/元数据与动态表单/DartReflect.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.Origin🌍/Dart反射（全部验证通过）/DynamicForm.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '元数据与动态表单');

// 在 Dart 中，你可以使用 dart:mirrors 库进行反射。
// 然而，请注意，dart:mirrors 并不适用于 Flutter。
// 这个示例展示了如何使用 Dart 的 json 库和 Flutter 动态生成表单，而不是依赖于反射。
// 虽然这不是传统意义上的反射，但它提供了类似的灵活性和动态性。

// dependencies:
//   flutter:
//     sdk: flutter
//   json_annotation:

// dev_dependencies:
//   build_runner:
//   json_serializable:

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const jsonString = '''
    {
      "name": "",
      "email": "",
      "age": ""
    }
    ''';

    return LegacyAppBoundary(
      app: const MaterialApp(home: DynamicForm(jsonString: jsonString)),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'DartReflect');
