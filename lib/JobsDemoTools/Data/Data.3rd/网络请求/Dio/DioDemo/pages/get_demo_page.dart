import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/method_demo_item.dart';
import '../shared/demo_helpers.dart';
import '../shared/demo_page_base.dart';

class GetDemoPage extends MethodDemoPageBase {
  const GetDemoPage({
    super.key,
    required super.dio,
    required super.item,
  });

  @override
  State<GetDemoPage> createState() => _GetDemoPageState();
}

class _GetDemoPageState extends MethodDemoPageState<GetDemoPage> {
  @override
  Future<Response<dynamic>> performRequest({required bool triggerError}) {
    return widget.dio.get(
      triggerError ? '/api/errors/get' : '/api/get/dashboard',
      queryParameters: triggerError
          ? null
          : {
              'tab': 'overview',
              'client': 'flutter-demo',
            },
    );
  }

  @override
  String buildRequestPreview({required bool triggerError}) {
    return triggerError
        ? 'GET /api/errors/get'
        : 'GET /api/get/dashboard?tab=overview&client=flutter-demo';
  }

  @override
  Widget buildSuccessResult(BuildContext context) {
    final root = asMap(renderData);
    final data = asMap(root['data']);
    final profile = asMap(data['profile']);
    final membership = asMap(profile['membership']);
    final stats = asMap(data['stats']);
    final actions = asList(data['quickActions']).map((e) => '$e').join('、');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('页面标题：${data['pageTitle'] ?? '--'}'),
        const SizedBox(height: 8),
        Text('欢迎语：${data['welcomeText'] ?? '--'}'),
        const SizedBox(height: 8),
        Text('昵称：${profile['nickname'] ?? '--'}'),
        const SizedBox(height: 8),
        Text('城市：${profile['city'] ?? '--'}'),
        const SizedBox(height: 8),
        Text('会员等级：${membership['level'] ?? '--'}'),
        const SizedBox(height: 8),
        Text(
          '统计：订单 ${stats['orderCount'] ?? '--'}，待支付 ${stats['pendingCount'] ?? '--'}，总金额 ${stats['totalAmount'] ?? '--'}',
        ),
        const SizedBox(height: 8),
        Text('快捷入口：$actions'),
      ],
    );
  }
}
