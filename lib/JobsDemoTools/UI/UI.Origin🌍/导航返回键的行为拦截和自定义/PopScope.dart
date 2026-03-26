import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/PopScope监听和自定义返回按钮行为/PopConfirmWrapper.dart';
import 'package:jobs_flutter_base_config/core/app_config.dart';
import 'package:jobs_flutter_base_config/pages/Others/Pages.dart';

// 点击按钮以后：跳转到 PageC
// 在PageC点击导航栏返回键，会出现一个弹窗，点击确定才可以真正的返回
void main() => runApp(JobsGetRunner(const MyPage(), title: '自定义 PopScope 示例'));

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopConfirmWrapper(
      child: Center(
        child: ElevatedButton(
          onPressed: () => Get.to(() => const PageC()),
          child: Text('跳转到 PageC', style: normalTextStyle()),
        ),
      ),
    );
  }
}
