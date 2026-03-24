import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/method_demo_item.dart';
import '../shared/demo_page_base.dart';
import '../shared/demo_helpers.dart';

class DeleteDemoPage extends MethodDemoPageBase {
  const DeleteDemoPage({
    super.key,
    required super.dio,
    required super.item,
  });

  @override
  State<DeleteDemoPage> createState() => _DeleteDemoPageState();
}

class _DeleteDemoPageState extends MethodDemoPageState<DeleteDemoPage> {
  @override
  Future<Response<dynamic>> performRequest({required bool triggerError}) {
    return widget.dio.delete(
      triggerError
          ? '/api/errors/delete'
          : '/api/delete/order/ORD-20260324-0001',
    );
  }

  @override
  String buildRequestPreview({required bool triggerError}) {
    return triggerError
        ? 'DELETE /api/errors/delete'
        : 'DELETE /api/delete/order/ORD-20260324-0001';
  }

  @override
  Widget buildSuccessResult(BuildContext context) {
    final root = asMap(renderData);
    final data = asMap(root['data']);
    return Text('已删除订单：${data['deletedOrderId'] ?? '--'}');
  }
}
