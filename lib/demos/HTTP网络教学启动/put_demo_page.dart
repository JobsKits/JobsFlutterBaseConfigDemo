import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_helpers.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_http.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_page_base.dart';

class PutDemoPage extends MethodDemoPageBase {
  const PutDemoPage({super.key, required super.client, required super.item});

  @override
  State<PutDemoPage> createState() => _PutDemoPageState();
}

class _PutDemoPageState extends MethodDemoPageState<PutDemoPage> {
  @override
  Future<DemoHttpResponse> performRequest({required bool triggerError}) {
    return widget.client.putJson(
      triggerError ? '/api/errors/put' : '/api/put/profile',
      body: {
        'nickname': 'Jobs',
        'city': 'Bangkok',
        'email': 'jobs@example.com',
      },
    );
  }

  @override
  String buildRequestPreview({required bool triggerError}) {
    return triggerError
        ? 'PUT /api/errors/put\nbody: {"demo": true}'
        : prettyJson({
            'method': 'PUT',
            'path': '/api/put/profile',
            'body': {
              'nickname': 'Jobs',
              'city': 'Bangkok',
              'email': 'jobs@example.com',
            },
          });
  }

  @override
  Widget buildSuccessResult(BuildContext context) {
    final root = asMap(renderData);
    final data = asMap(root['data']);
    final profile = asMap(data['profile']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegacyText('昵称：${profile['nickname'] ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText('城市：${profile['city'] ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText('邮箱：${profile['email'] ?? '--'}'),
      ],
    );
  }
}
