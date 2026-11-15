import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MicroWebView extends StatefulWidget {
  const MicroWebView({
    super.key,
    required this.html,
    required this.onRequest,
    this.remoteUrl,
  });
  final String html;
  final Future<Map<String, Object?>> Function(Object?) onRequest;
  final Uri? remoteUrl;
  @override
  State<MicroWebView> createState() => _State();
}

class _State extends State<MicroWebView> {
  WebViewController? controller;
  Timer? timeout;
  bool trusted = true;
  @override
  void initState() {
    super.initState();
    if (WebViewPlatform.instance == null ||
        !{
          TargetPlatform.iOS,
          TargetPlatform.android,
          TargetPlatform.macOS,
        }.contains(defaultTargetPlatform))
      return;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'JobsBridge',
        onMessageReceived: (message) async {
          if (!trusted) return;
          final reply = await widget.onRequest(message.message);
          if (mounted)
            await controller?.runJavaScript(
              'window.jobsReply(${jsonEncode(reply)})',
            );
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (request.url == 'about:blank')
              return NavigationDecision.navigate;
            if (uri?.scheme == 'https') {
              trusted = false;
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageFinished: (url) {
            if (widget.remoteUrl == null || url == widget.remoteUrl.toString())
              timeout?.cancel();
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != false) loadLocal();
          },
        ),
      );
    load();
  }

  void loadLocal() {
    timeout?.cancel();
    trusted = true;
    controller?.loadHtmlString(widget.html);
  }

  void load() {
    if (widget.remoteUrl == null) {
      loadLocal();
      return;
    }
    trusted = false;
    controller?.loadRequest(widget.remoteUrl!);
    timeout = Timer(const Duration(milliseconds: 900), () {
      loadLocal();
    });
  }

  @override
  void didUpdateWidget(MicroWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html ||
        oldWidget.remoteUrl != widget.remoteUrl)
      load();
  }

  @override
  void dispose() {
    timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => controller == null
      ? const Center(child: Text('WebView unavailable on this host'))
      : WebViewWidget(controller: controller!);
}
