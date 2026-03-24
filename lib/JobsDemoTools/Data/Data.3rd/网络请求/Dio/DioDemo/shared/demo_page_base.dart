import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/method_demo_item.dart';
import 'demo_helpers.dart';
import 'demo_widgets.dart';

abstract class MethodDemoPageBase extends StatefulWidget {
  const MethodDemoPageBase({
    super.key,
    required this.dio,
    required this.item,
  });

  final Dio dio;
  final MethodDemoItem item;
}

abstract class MethodDemoPageState<T extends MethodDemoPageBase>
    extends State<T> {
  bool loading = false;
  String statusText = '点击按钮发起请求';
  String requestPreview = '还没有请求内容';
  Object? renderData;
  Object? rawResponse;
  String? errorText;
  Object? errorBody;
  int? statusCode;
  Headers? responseHeaders;

  Future<Response<dynamic>> performRequest({required bool triggerError});

  String buildRequestPreview({required bool triggerError});

  Widget buildSuccessResult(BuildContext context);

  Object? buildRawResponse(Object? body, Response<dynamic> response) {
    return normalizeBody(body);
  }

  Object? buildRenderData(Object? body, Response<dynamic> response) {
    return normalizeBody(body);
  }

  String successText() {
    return '${widget.item.method.label} 请求成功';
  }

  String failureText(int? code) {
    return '${widget.item.method.label} 请求失败（$code）';
  }

  String exceptionText(Object error) {
    return '${widget.item.method.label} 请求异常：$error';
  }

  Future<void> sendRequest({required bool triggerError}) async {
    setState(() {
      loading = true;
      errorText = null;
      errorBody = null;
      renderData = null;
      rawResponse = null;
      statusCode = null;
      responseHeaders = null;
      statusText = '${widget.item.method.label} 请求中...';
      requestPreview = buildRequestPreview(triggerError: triggerError);
    });

    try {
      final response = await performRequest(triggerError: triggerError);
      final body = response.data;
      final isError = (response.statusCode ?? 500) >= 400;

      if (isError) {
        setState(() {
          statusCode = response.statusCode;
          responseHeaders = response.headers;
          errorText = failureText(response.statusCode);
          errorBody = body;
          rawResponse = body;
          statusText = errorText!;
        });
        return;
      }

      setState(() {
        statusCode = response.statusCode;
        responseHeaders = response.headers;
        renderData = buildRenderData(body, response);
        rawResponse = buildRawResponse(body, response);
        statusText = successText();
      });
    } catch (error) {
      setState(() {
        errorText = exceptionText(error);
        statusText = errorText!;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildIntroCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.description,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('接口：${widget.item.path}'),
            const SizedBox(height: 8),
            Text('状态：$statusText'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : () => sendRequest(triggerError: false),
                    child: Text(loading ? '请求中...' : '发起请求'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: loading ? null : () => sendRequest(triggerError: true),
                    child: const Text('触发错误'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRenderSection() {
    if (errorText != null) {
      return DemoErrorView(errorText: errorText!, errorBody: errorBody);
    }

    if (renderData == null) {
      return const Text('还没有结果');
    }

    return buildSuccessResult(context);
  }

  Widget buildRawSection() {
    if (errorText != null) {
      return DemoTextBox(prettyJson(errorBody ?? {'message': errorText}));
    }

    if (rawResponse == null) {
      return const Text('还没有响应');
    }

    return DemoTextBox(prettyJson(rawResponse));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.item.method.label} Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildIntroCard(),
          const SizedBox(height: 16),
          DemoBlock(title: '请求预览', child: DemoTextBox(requestPreview)),
          const SizedBox(height: 16),
          DemoBlock(title: '渲染结果', child: buildRenderSection()),
          const SizedBox(height: 16),
          DemoBlock(title: '原始响应', child: buildRawSection()),
        ],
      ),
    );
  }
}
