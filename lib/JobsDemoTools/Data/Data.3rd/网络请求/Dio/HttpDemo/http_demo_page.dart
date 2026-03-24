import 'package:flutter/material.dart';

import 'model/method_demo_item.dart';
import 'model/method_type.dart';
import 'pages/delete_demo_page.dart';
import 'pages/download_demo_page.dart';
import 'pages/get_demo_page.dart';
import 'pages/patch_demo_page.dart';
import 'pages/post_demo_page.dart';
import 'pages/put_demo_page.dart';
import 'pages/upload_demo_page.dart';
import 'shared/demo_helpers.dart';
import 'shared/demo_http.dart';

class HttpDemoPage extends StatefulWidget {
  const HttpDemoPage({super.key});

  @override
  State<HttpDemoPage> createState() => _HttpDemoPageState();
}

class _HttpDemoPageState extends State<HttpDemoPage> {
  final DemoHttpClient _client = DemoHttp.instance;

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
      final response = await _client.getJson('/api/methods');
      final root = asMap(response.jsonBody);
      final data = asMap(root['data']);
      final list = asList(data['items']);

      setState(() {
        _items = list
            .map((item) => MethodDemoItem.fromJson(asMap(item)))
            .toList(growable: false);
      });
    } catch (error) {
      setState(() {
        _errorText = '$error';
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
    }
  }

  void _openPage(MethodDemoItem item) {
    late final Widget page;
    switch (item.method) {
      case MethodType.get:
        page = GetDemoPage(client: _client, item: item);
        break;
      case MethodType.post:
        page = PostDemoPage(client: _client, item: item);
        break;
      case MethodType.put:
        page = PutDemoPage(client: _client, item: item);
        break;
      case MethodType.patch:
        page = PatchDemoPage(client: _client, item: item);
        break;
      case MethodType.delete:
        page = DeleteDemoPage(client: _client, item: item);
        break;
      case MethodType.upload:
        page = UploadDemoPage(client: _client, item: item);
        break;
      case MethodType.download:
        page = DownloadDemoPage(client: _client, item: item);
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
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
              Text('目录加载失败：$_errorText'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadCatalog,
                child: const Text('重试'),
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
            title: Text('${item.method.label} Demo'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('${item.path}\n${item.description}'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openPage(item),
          ),
        );
      },
    );
  }
}
