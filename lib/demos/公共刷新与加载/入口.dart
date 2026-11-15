import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_refresh_load/jobs_refresh_load.dart';

void main() =>
    runApp(const JobsDemoApp(home: RefreshPackageDemo(), title: '公共刷新与加载'));
Widget buildLegacyDemo(BuildContext context) => const RefreshPackageDemo();

class RefreshPackageDemo extends StatefulWidget {
  const RefreshPackageDemo({super.key});
  @override
  State<RefreshPackageDemo> createState() => _RefreshPackageDemoState();
}

class _RefreshPackageDemoState extends State<RefreshPackageDemo> {
  final transport = http.Client();
  late final controller = _PageController(fetchPage: fetchPage)
    ..items.addAll(localPage(1, 12));

  List<String> localPage(int page, int size) => [
    for (
      var index = (page - 1) * size;
      index < page * size && index < 50;
      index++
    )
      'Demo ${index + 1}',
  ];
  Future<List<String>> fetchPage(int page, int size) async {
    try {
      final base = Uri.parse(
        const String.fromEnvironment(
          'JOBS_DEMO_API_BASE',
          defaultValue: 'http://127.0.0.1:18080',
        ),
      );
      final response = await transport
          .get(
            base
                .resolve('/api/demo/refresh')
                .replace(
                  queryParameters: {'page': '$page', 'pageSize': '$size'},
                ),
          )
          .timeout(
            const Duration(
              milliseconds: int.fromEnvironment(
                'JOBS_DEMO_API_TIMEOUT_MS',
                defaultValue: 900,
              ),
            ),
          );
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body is Map &&
          body['items'] is List) {
        return (body['items'] as List).map((item) => '$item').toList();
      }
    } catch (_) {}
    return localPage(page, size);
  }

  @override
  void dispose() {
    transport.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('公共刷新与加载'),
      actions: [
        IconButton(
          tooltip: tr(context, '清空'),
          icon: const Icon(Icons.clear_all),
          onPressed: () {
            controller.items.clear();
            controller.notifyListeners();
          },
        ),
        IconButton(
          tooltip: tr(context, '重新加载'),
          icon: const Icon(Icons.refresh),
          onPressed: controller.refresh,
        ),
      ],
    ),
    body: JobsRefreshLoadList<String>(
      controller: controller,
      emptyBuilder: (context) =>
          JobsEmptyState(title: '暂无数据', onReload: controller.refresh),
      itemBuilder: (_, item, index) =>
          ListTile(title: Text(item), subtitle: Text('#${index + 1}')),
    ),
  );
}

// 原包请求完成时会通知；页面退出后吞掉通知，避免异步请求访问已释放的监听器。
class _PageController extends JobsRefreshLoadController<String> {
  _PageController({required super.fetchPage}) : super(pageSize: 12);
  bool disposed = false;
  @override
  void notifyListeners() {
    if (!disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
