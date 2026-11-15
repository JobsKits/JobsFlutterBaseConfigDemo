import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_helpers.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_http.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_page_base.dart';

class DownloadDemoPage extends MethodDemoPageBase {
  const DownloadDemoPage({
    super.key,
    required super.client,
    required super.item,
  });

  @override
  State<DownloadDemoPage> createState() => _DownloadDemoPageState();
}

class _DownloadDemoPageState extends MethodDemoPageState<DownloadDemoPage> {
  @override
  Future<DemoHttpResponse> performRequest({required bool triggerError}) {
    return widget.client.downloadBytes(
      '/api/download/file',
      queryParameters: {
        'fileName': triggerError ? 'not-found.txt' : 'download-demo.txt',
      },
    );
  }

  @override
  String buildRequestPreview({required bool triggerError}) {
    return triggerError
        ? 'GET /api/download/file?fileName=not-found.txt\nresponseType: bytes'
        : 'GET /api/download/file?fileName=download-demo.txt\nresponseType: bytes';
  }

  @override
  Object? buildRenderData(Object? body, DemoHttpResponse response) {
    return response.bodyBytes;
  }

  @override
  Object? buildRawResponse(Object? body, DemoHttpResponse response) {
    final bytes = response.bodyBytes;
    return {
      'statusCode': response.statusCode,
      'headers': response.headers,
      'byteLength': bytes.length,
      'preview': utf8.decode(bytes, allowMalformed: true),
    };
  }

  @override
  Widget buildSuccessResult(BuildContext context) {
    final bytes = asBytes(renderData);
    final textPreview = utf8.decode(bytes, allowMalformed: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegacyText('状态码：${statusCode ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText('文件大小：${bytes.length} bytes'),
        const SizedBox(height: 8),
        LegacyText('content-type：${responseHeaders?['content-type'] ?? '--'}'),
        const SizedBox(height: 8),
        LegacyText(
          'content-disposition：${responseHeaders?['content-disposition'] ?? '--'}',
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.black12,
          child: LegacyText(textPreview),
        ),
      ],
    );
  }
}
