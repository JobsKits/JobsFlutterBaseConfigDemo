import 'package:flutter/material.dart';

import '../model/method_demo_item.dart';
import '../shared/demo_helpers.dart';
import '../shared/demo_http.dart';
import '../shared/demo_page_base.dart';

class PostDemoPage extends MethodDemoPageBase {
  const PostDemoPage({
    super.key,
    required super.client,
    required super.item,
  });

  @override
  State<PostDemoPage> createState() => _PostDemoPageState();
}

class _PostDemoPageState extends MethodDemoPageState<PostDemoPage> {
  @override
  Future<DemoHttpResponse> performRequest({required bool triggerError}) {
    return widget.client.postJson(
      triggerError ? '/api/errors/post' : '/api/post/orders',
      body: {
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
              'clientInfo': {'platform': 'flutter', 'version': '1.0.0'},
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
          Text(
            '订单号：${item['orderNo'] ?? '--'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('用户：${user['name'] ?? '--'}（${user['phone'] ?? '--'}）'),
          Text(
            '地址：${address['province'] ?? ''}${address['city'] ?? ''}${address['detail'] ?? ''}',
          ),
          Text('状态：${summary['statusText'] ?? '--'}'),
          Text('总价：¥${summary['finalAmount'] ?? '--'}'),
          Text('标签：$tags'),
          const SizedBox(height: 8),
          const Text(
            '商品列表：',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '- ${product['name']} x${product['count']} / SKU: ${product['sku']} / ¥${product['price']}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
