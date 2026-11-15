import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/model/method_demo_item.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/model/method_type.dart';

import '../网络请求库教学/演示数据回退.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/pages/get_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/pages/post_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/pages/put_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/pages/patch_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/pages/delete_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/pages/upload_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/pages/download_demo_page.dart';

void main() => runApp(
  JobsDemoApp(
    title: '原生网络请求教学',
    home: Builder(builder: buildLegacyDemo),
  ),
);
Widget buildLegacyDemo(BuildContext context) => const LegacyHttpCatalog();

class LegacyHttpCatalog extends StatefulWidget {
  const LegacyHttpCatalog({super.key, this.client});
  final LegacyHttpClient? client;
  @override
  State<LegacyHttpCatalog> createState() => _LegacyHttpCatalogState();
}

class _LegacyHttpCatalogState extends State<LegacyHttpCatalog> {
  late final client =
      widget.client ?? LegacyHttpClient(LegacyFallbackHttpClient());
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
      final response = await client.getJson('/api/methods');
      final body = response.jsonBody;
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
    client.transport.close();
    super.dispose();
  }

  void open(MethodDemoItem item) {
    late final Widget page;
    switch (item.method) {
      case MethodType.get:
        page = GetDemoPage(client: client, item: item);
        break;
      case MethodType.post:
        page = PostDemoPage(client: client, item: item);
        break;
      case MethodType.put:
        page = PutDemoPage(client: client, item: item);
        break;
      case MethodType.patch:
        page = PatchDemoPage(client: client, item: item);
        break;
      case MethodType.delete:
        page = DeleteDemoPage(client: client, item: item);
        break;
      case MethodType.upload:
        page = UploadDemoPage(client: client, item: item);
        break;
      case MethodType.download:
        page = DownloadDemoPage(client: client, item: item);
        break;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('原生网络请求教学'),
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
