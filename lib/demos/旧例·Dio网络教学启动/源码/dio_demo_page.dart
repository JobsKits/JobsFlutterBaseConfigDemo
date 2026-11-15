import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/model/method_demo_item.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/model/method_type.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/delete_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/download_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/get_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/patch_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/post_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/put_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/pages/upload_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/shared/demo_dio.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/shared/demo_helpers.dart';

class DioDemoPage extends StatefulWidget {
  const DioDemoPage({super.key});

  @override
  State<DioDemoPage> createState() => _DioDemoPageState();
}

class _DioDemoPageState extends State<DioDemoPage> {
  final Dio _dio = DemoDio.instance;

  bool _loading = true;
  String? _errorText;
  List<MethodDemoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final response = await _dio.get('/api/methods');
      if (!mounted) {
        return;
      }
      final root = asMap(response.data);
      final data = asMap(root['data']);
      final list = asList(data['items']);

      setState(() {
        _items = list
            .map((item) => MethodDemoItem.fromJson(asMap(item)))
            .toList(growable: false);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = '$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _openPage(MethodDemoItem item) {
    late final Widget page;
    switch (item.method) {
      case MethodType.get:
        page = GetDemoPage(dio: _dio, item: item);
        break;
      case MethodType.post:
        page = PostDemoPage(dio: _dio, item: item);
        break;
      case MethodType.put:
        page = PutDemoPage(dio: _dio, item: item);
        break;
      case MethodType.patch:
        page = PatchDemoPage(dio: _dio, item: item);
        break;
      case MethodType.delete:
        page = DeleteDemoPage(dio: _dio, item: item);
        break;
      case MethodType.upload:
        page = UploadDemoPage(dio: _dio, item: item);
        break;
      case MethodType.download:
        page = DownloadDemoPage(dio: _dio, item: item);
        break;
    }

    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LegacyText('目录加载失败：$_errorText'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadCatalog,
                child: const LegacyText('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: LegacyText('${item.method.label} Demo'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LegacyText('${item.path}\n${item.description}'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openPage(item),
          ),
        );
      },
    );
  }
}
