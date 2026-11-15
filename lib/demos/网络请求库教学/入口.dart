import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/model/method_demo_item.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/model/method_type.dart';
import 'package:dio/dio.dart';

import '演示数据回退.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/get_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/post_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/put_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/patch_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/delete_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/upload_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/download_demo_page.dart';

void main() => runApp(
  JobsDemoApp(
    title: '网络请求库教学',
    home: Builder(builder: buildLegacyDemo),
  ),
);
Widget buildLegacyDemo(BuildContext context) => const LegacyDioCatalog();

class LegacyDioCatalog extends StatefulWidget {
  const LegacyDioCatalog({super.key, this.client});
  final Dio? client;
  @override
  State<LegacyDioCatalog> createState() => _LegacyDioCatalogState();
}

class _LegacyDioCatalogState extends State<LegacyDioCatalog> {
  late final Dio client = widget.client ?? createLegacyDio();
  List<MethodDemoItem> items = localMethodCatalog
      .map(MethodDemoItem.fromJson)
      .toList();
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    try {
      final response = await client.get('/api/methods');
      final body = response.data;
      final value = body is String ? jsonDecode(body) : body;
      if (value is Map &&
          value['data'] is Map &&
          value['data']['items'] is List) {
        final parsed = (value['data']['items'] as List)
            .map(
              (item) => MethodDemoItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        if (mounted) setState(() => items = parsed);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    client.close(force: true);
    super.dispose();
  }

  void open(MethodDemoItem item) {
    late final Widget page;
    switch (item.method) {
      case MethodType.get:
        page = GetDemoPage(dio: client, item: item);
        break;
      case MethodType.post:
        page = PostDemoPage(dio: client, item: item);
        break;
      case MethodType.put:
        page = PutDemoPage(dio: client, item: item);
        break;
      case MethodType.patch:
        page = PatchDemoPage(dio: client, item: item);
        break;
      case MethodType.delete:
        page = DeleteDemoPage(dio: client, item: item);
        break;
      case MethodType.upload:
        page = UploadDemoPage(dio: client, item: item);
        break;
      case MethodType.download:
        page = DownloadDemoPage(dio: client, item: item);
        break;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('网络请求库教学'),
      actions: [
        IconButton(
          tooltip: tr(context, '重新加载'),
          onPressed: reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: items.isEmpty
        ? JobsEmptyState(title: '暂无数据', onReload: reload)
        : RefreshIndicator(
            onRefresh: reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.method.label),
                    subtitle: Text('${item.description}\n${item.path}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => open(item),
                  ),
                );
              },
            ),
          ),
  );
}
