// 独立运行：flutter run -t "lib/demos/表单全局键/GlobalKeyDemo1.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '表单全局键');

/// 直接用Key取UI的值（状态），而不关心UI的具体实现。
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
          appBar: JobsDemoAppBar(title: const LegacyText('GlobalKey Demo')),
          body: const GlobalKeyDemo(),
        ),
      ),
    );
  }
}

class GlobalKeyDemo extends StatefulWidget {
  const GlobalKeyDemo({super.key});

  @override
  State<GlobalKeyDemo> createState() => _GlobalKeyDemoState();
}

class _GlobalKeyDemoState extends State<GlobalKeyDemo> {
  // 类似于Future。GlobalKey这个大类型里面包裹的是FormState这样的小的具体的类型。
  // 和iOS的key不同（iOS需要手动创建全剧唯一的static字符串），存取铆定这个字符串
  // Flutter创建这个全局的Key类似，只不过不一定是字符串类型，你也不需要管他具体是什么
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  void _changeTextFieldText() {
    // Change the text in the TextField using the controller
    _controller.text = 'Updated Text';
  }

  void _validateAndSave() {
    // 使用这个名为_formKey的GlobalKey
    if (_formKey.currentState!.validate()) {
      legacyDebugPrint('Form is valid');
    } else {
      legacyDebugPrint('Form is invalid');
    }
  }

  void _resetForm() {
    // 使用这个名为_formKey的GlobalKey
    _formKey.currentState!.reset();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            // 创建完了以后，铆定UI。没有设定就是原始的super.key
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: legacyInputDecoration(
                context,
                InputDecoration(
                  labelText: 'Enter Text',
                  border: OutlineInputBorder(),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return legacyUiText(context, 'Please enter some text');
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _changeTextFieldText,
                child: const LegacyText('Change Text'),
              ),
              ElevatedButton(
                onPressed: _validateAndSave,
                child: const LegacyText('Validate'),
              ),
              ElevatedButton(
                onPressed: _resetForm,
                child: const LegacyText('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('表单全局键')),
    body: SafeArea(child: const GlobalKeyDemo()),
  ),
);
