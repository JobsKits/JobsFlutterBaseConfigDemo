import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/shared/demo_helpers.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/shared/demo_page_base.dart';

class PostDemoPage extends MethodDemoPageBase {
  const PostDemoPage({super.key, required super.dio, required super.item});

  @override
  State<PostDemoPage> createState() => _PostDemoPageState();
}

class _PostDemoPageState extends MethodDemoPageState<PostDemoPage> {
  @override
  Future<Response<dynamic>> performRequest({required bool triggerError}) {
    return widget.dio.post(
      triggerError ? '/api/errors/post' : '/api/post/orders',
      data: {
        'pageNo': 1,
        'pageSize': 10,
        'filters': {
          'status': ['paid', 'shipped'],
          'keyword': 'demo',
          'priceRange': {'min': 100, 'max': 5000},
        },
        'clientInfo': {'platform': 'flutter', 'version': '1.0.0'},
      },
    );
  }

  @override
  String buildRequestPreview({required bool triggerError}) {
    return triggerError
        ? 'POST /api/errors/post\nbody: {"demo": true}'
        : prettyJson({
            'method': 'POST',
            'path': '/api/post/orders',
            'body': {
              'pageNo': 1,
              'pageSize': 10,
              'filters': {
                'status': ['paid', 'shipped'],
                'keyword': 'demo',
                'priceRange': {'min': 100, 'max': 5000},
              },
            },
          });
  }

  @override
  Widget buildSuccessResult(BuildContext context) {
    final root = asMap(renderData);
    final data = asMap(root['data']);
    final records = asList(data['records']);

    return Column(
      children: records
          .map((item) => _buildOrderCard(asMap(item)))
          .toList(growable: false),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> item) {
    final user = asMap(item['user']);
    final address = asMap(user['address']);
    final summary = asMap(item['summary']);
    final products = asList(item['products'])
        .map((e) => asMap(e))
        .toList(growable: false);
    final tags = asList(item['tags']).map((e) => '$e').join('、');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LegacyText(
            '订单号：${item['orderNo'] ?? '--'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          LegacyText('用户：${user['name'] ?? '--'}（${user['phone'] ?? '--'}）'),
          LegacyText(
            '地址：${address['province'] ?? ''}${address['city'] ?? ''}${address['detail'] ?? ''}',
          ),
          LegacyText('状态：${summary['statusText'] ?? '--'}'),
          LegacyText('总价：¥${summary['finalAmount'] ?? '--'}'),
          LegacyText('标签：$tags'),
          const SizedBox(height: 8),
          const LegacyText(
            '商品列表：',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: LegacyText(
                '- ${product['name']} x${product['count']} / SKU: ${product['sku']} / ¥${product['price']}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
