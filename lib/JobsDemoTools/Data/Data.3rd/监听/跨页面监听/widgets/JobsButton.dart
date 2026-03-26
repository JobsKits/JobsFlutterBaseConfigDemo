import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() => runApp(JobsMaterialRunner(
    JobsButton(
      onPressed: () {
        print('s');
      },
      isButtonEnabled: true.obs,
    ),
    title: 'JobsButton'));

class JobsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final RxBool isButtonEnabled;
  const JobsButton({
    super.key,
    required this.onPressed,
    required this.isButtonEnabled,
  });
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ElevatedButton(
        onPressed: isButtonEnabled.value ? onPressed : null,
        child: const Text('Submit'),
      );
    });
  }
}
