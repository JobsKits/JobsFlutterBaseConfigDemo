import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/shared/demo_page_base.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/shared/demo_helpers.dart';

class DeleteDemoPage extends MethodDemoPageBase {
  const DeleteDemoPage({super.key, required super.dio, required super.item});

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
    return LegacyText('已删除订单：${data['deletedOrderId'] ?? '--'}');
  }
}
