import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/method_demo_item.dart';
import '../shared/demo_page_base.dart';
import '../shared/demo_helpers.dart';

class PutDemoPage extends MethodDemoPageBase {
  const PutDemoPage({
    super.key,
    required super.dio,
    required super.item,
  });

  @override
  State<PutDemoPage> createState() => _PutDemoPageState();
}

class _PutDemoPageState extends MethodDemoPageState<PutDemoPage> {
  @override
  Future<Response<dynamic>> performRequest({required bool triggerError}) {
    return widget.dio.put(
      triggerError ? '/api/errors/put' : '/api/put/profile',
      data: {
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
        Text('昵称：${profile['nickname'] ?? '--'}'),
        const SizedBox(height: 8),
        Text('城市：${profile['city'] ?? '--'}'),
        const SizedBox(height: 8),
        Text('邮箱：${profile['email'] ?? '--'}'),
      ],
    );
  }
}
