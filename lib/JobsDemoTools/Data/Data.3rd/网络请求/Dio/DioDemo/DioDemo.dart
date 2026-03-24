import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRunners/JobsMaterialRunner.dart';

void main() =>
    runApp(JobsMaterialRunner(DioDemoPage(), title: 'HTTP Methods Demo'));

class DioDemoPage extends StatefulWidget {
  const DioDemoPage({super.key});

  @override
  State<DioDemoPage> createState() => _DioDemoPageState();
}

class _DioDemoPageState extends State<DioDemoPage> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8080',
      connectTimeout: Duration(milliseconds: 5000),
      receiveTimeout: Duration(milliseconds: 5000),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  bool _loadingGet = false;
  bool _loadingPost = false;
  String _statusText = '点击下面按钮开始请求';

  Map<String, dynamic>? _getData;
  List<Map<String, dynamic>> _postList = [];

  Future<void> _fetchGetData() async {
    setState(() {
      _loadingGet = true;
      _statusText = 'GET 请求中...';
    });

    try {
      final response = await _dio.get('/dashboard', queryParameters: {
        'tab': 'overview',
        'client': 'flutter-demo',
      });

      final data = Map<String, dynamic>.from(response.data as Map);

      setState(() {
        _getData = data;
        _statusText = 'GET 请求成功';
      });
    } catch (error) {
      setState(() {
        _statusText = 'GET 请求失败: $error';
      });
    } finally {
      setState(() {
        _loadingGet = false;
      });
    }
  }

  Future<void> _fetchPostData() async {
    setState(() {
      _loadingPost = true;
      _statusText = 'POST 请求中...';
    });

    try {
      final response = await _dio.post(
        '/orders/list',
        data: {
          'pageNo': 1,
          'pageSize': 10,
          'filters': {
            'status': ['paid', 'shipped'],
            'keyword': 'demo',
            'priceRange': {
              'min': 100,
              'max': 5000,
            },
          },
          'clientInfo': {
            'platform': 'flutter',
            'version': '1.0.0',
          },
        },
      );

      final responseMap = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(responseMap['data'] as Map);
      final records = List<Map<String, dynamic>>.from(
        (data['records'] as List).map((item) => Map<String, dynamic>.from(item as Map)),
      );

      setState(() {
        _postList = records;
        _statusText = 'POST 请求成功，共 ${records.length} 条';
      });
    } catch (error) {
      setState(() {
        _statusText = 'POST 请求失败: $error';
      });
    } finally {
      setState(() {
        _loadingPost = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: _loadingGet ? null : _fetchGetData,
                      child: Text(_loadingGet ? 'GET 加载中...' : '发起 GET 请求'),
                    ),
                    ElevatedButton(
                      onPressed: _loadingPost ? null : _fetchPostData,
                      child: Text(_loadingPost ? 'POST 加载中...' : '发起 POST 请求'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _statusText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                _buildGetSection(),
                const SizedBox(height: 16),
                _buildPostSection(),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildGetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GET 返回数据',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_getData == null)
              const Text('还没有 GET 数据')
            else ...[
              Text('页面标题：${_getData?['pageTitle'] ?? '--'}'),
              const SizedBox(height: 8),
              Text('欢迎语：${_getData?['welcomeText'] ?? '--'}'),
              const SizedBox(height: 8),
              Text('当前城市：${_getData?['profile']?['city'] ?? '--'}'),
              const SizedBox(height: 8),
              Text('会员等级：${_getData?['profile']?['membership']?['level'] ?? '--'}'),
              const SizedBox(height: 8),
              Text(
                '统计摘要：订单 ${_getData?['stats']?['orderCount'] ?? '--'}，待支付 ${_getData?['stats']?['pendingCount'] ?? '--'}，总金额 ${_getData?['stats']?['totalAmount'] ?? '--'}',
              ),
              const SizedBox(height: 12),
              const Text(
                '原始 JSON',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.black12,
                child: Text(
                  _prettyJson(_getData),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'POST 返回列表',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_postList.isEmpty)
              const Text('还没有 POST 列表数据')
            else
              ..._postList.map(_buildOrderCard),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> item) {
    final user = Map<String, dynamic>.from(item['user'] as Map? ?? {});
    final address = Map<String, dynamic>.from(user['address'] as Map? ?? {});
    final summary = Map<String, dynamic>.from(item['summary'] as Map? ?? {});
    final productList = List<Map<String, dynamic>>.from(
      ((item['products'] as List?) ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final tags = List<String>.from(item['tags'] as List? ?? []);

    return Container(
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
          Text('用户：${user['name'] ?? '--'}  (${user['phone'] ?? '--'})'),
          Text('地址：${address['province'] ?? ''}${address['city'] ?? ''}${address['detail'] ?? ''}'),
          Text('状态：${summary['statusText'] ?? '--'}'),
          Text('总价：¥${summary['finalAmount'] ?? '--'}'),
          Text('标签：${tags.join('、')}'),
          const SizedBox(height: 8),
          const Text(
            '商品列表：',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ...productList.map(
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

  String _prettyJson(Object? jsonObject) {
    return const JsonEncoder.withIndent('  ').convert(jsonObject);
  }
}
