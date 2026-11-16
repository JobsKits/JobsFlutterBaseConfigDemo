// 独立运行：flutter run -t "lib/demos/身份证校验/身份证校验.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';

void main() => runApp(const JobsDemoApp(home: CNIDDemo(), title: '身份证校验'));

class CNIDDemo extends StatefulWidget {
  const CNIDDemo({super.key});
  @override
  State<CNIDDemo> createState() => _State();
}

class _State extends State<CNIDDemo> {
  final input = TextEditingController(text: '11010519491231002X');
  JobsCNIDResult? result;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '身份证校验',
    children: [
      TextField(
        controller: input,
        decoration: InputDecoration(labelText: labTr(context, '输入')),
        maxLength: 18,
      ),
      labAction(
        context,
        '校验',
        () => setState(() => result = validateCNID(input.text)),
      ),
      if (result != null) ...[
        Text(
          labTr(context, result!.valid ? '验证通过' : '验证失败'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        for (final check in result!.checks.entries)
          ListTile(
            title: Text(check.key),
            trailing: Icon(
              check.value ? Icons.check_circle : Icons.cancel,
              color: check.value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    ],
  );
}
