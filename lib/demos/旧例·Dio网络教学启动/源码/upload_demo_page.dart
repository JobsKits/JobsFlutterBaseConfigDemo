import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/shared/demo_helpers.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/DioDemo/shared/demo_page_base.dart';

class UploadDemoPage extends MethodDemoPageBase {
  const UploadDemoPage({super.key, required super.dio, required super.item});

  @override
  State<UploadDemoPage> createState() => _UploadDemoPageState();
}

class _UploadDemoPageState extends MethodDemoPageState<UploadDemoPage> {
  @override
  Future<Response<dynamic>> performRequest({required bool triggerError}) {
    final formData = FormData.fromMap({
      'description': triggerError ? '触发错误' : 'Flutter 上传示例文件',
      'category': 'demo',
      if (!triggerError)
        'file': MultipartFile.fromString(
          'This is a demo upload from Flutter.',
          filename: 'flutter_upload_demo.txt',
          contentType: DioMediaType.parse('text/plain'),
        ),
    });

    return widget.dio.post(
      '/api/upload/file',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  @override
  String buildRequestPreview({required bool triggerError}) {
    return triggerError
        ? 'POST /api/upload/file\nform-data: {description: "触发错误"}'
        : 'POST /api/upload/file\nform-data: {file: flutter_upload_demo.txt, description: "Flutter 上传示例文件", category: "demo"}';
  }

  @override
  Widget buildSuccessResult(BuildContext context) {
    final root = asMap(renderData);
    final data = asMap(root['data']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegacyText('文件名：${data['fileName'] ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText('大小：${data['size'] ?? '--'} bytes'),
        const SizedBox(height: 8),
        LegacyText('类型：${data['contentType'] ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText('说明：${data['description'] ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText('预览：${data['preview'] ?? '--'}'),
      ],
    );
  }
}
