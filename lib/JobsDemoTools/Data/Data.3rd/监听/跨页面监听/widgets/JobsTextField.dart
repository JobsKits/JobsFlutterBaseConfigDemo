import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() => runApp(JobsMaterialRunner(
    JobsTextField(
      controller: TextEditingController(),
      hintText: 'Enter first value',
    ),
    title: 'XXX'));

class JobsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const JobsTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
