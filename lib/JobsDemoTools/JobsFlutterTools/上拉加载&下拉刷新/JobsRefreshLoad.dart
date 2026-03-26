import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRefreshLoad/JobsRefreshLoadController.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRefreshLoad/JobsRefreshLoadList.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRunners/JobsGetXRunner.dart';

void main() =>
    runApp(JobsGetRunner(const DemoPage(), title: 'JobsRefreshLoad'));

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late JobsRefreshLoadController<String> controller;

  @override
  void initState() {
    super.initState();
    // 初始化控制器：模拟分页加载
    controller = JobsRefreshLoadController<String>(
      pageSize: 20,
      fetchPage: (page, size) async {
        await Future.delayed(const Duration(milliseconds: 800)); // 模拟网络延迟
        if (page > 3) return []; // 模拟最多三页
        return List.generate(size, (i) => "Item ${(page - 1) * size + i + 1}");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobsRefreshLoadList<String>(
      controller: controller,
      zebra: true, // ✅ 开启斑马纹
      itemBuilder: (ctx, item, index) {
        return ListTile(
          title: Text(item),
        );
      },
    );
  }
}
