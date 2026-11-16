import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_helpers.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_http.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_page_base.dart';

class PatchDemoPage extends MethodDemoPageBase {
  const PatchDemoPage({super.key, required super.client, required super.item});

  @override
  State<PatchDemoPage> createState() => _PatchDemoPageState();
}

class _PatchDemoPageState extends MethodDemoPageState<PatchDemoPage> {
  @override
  Future<DemoHttpResponse> performRequest({required bool triggerError}) {
    return widget.client.patchJson(
      triggerError ? '/api/errors/patch' : '/api/patch/settings',
      body: {'theme': 'dark', 'notifications': true, 'fontScale': 1.1},
    );
  }

  @override
  String buildRequestPreview({required bool triggerError}) {
    return triggerError
        ? 'PATCH /api/errors/patch\nbody: {"demo": true}'
        : prettyJson({
            'method': 'PATCH',
            'path': '/api/patch/settings',
            'body': {'theme': 'dark', 'notifications': true, 'fontScale': 1.1},
          });
  }

  @override
  Widget buildSuccessResult(BuildContext context) {
    final root = asMap(renderData);
    final data = asMap(root['data']);
    final settings = asMap(data['settings']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegacyText('主题：${settings['theme'] ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText('消息提醒：${settings['notifications'] ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText('字体缩放：${settings['fontScale'] ?? '--'}'),
      ],
    );
  }
}
