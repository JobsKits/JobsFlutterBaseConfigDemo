import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
  web.HTMLIFrameElement? frame;
  Timer? timeout;
  late final JSFunction listener;
  @override
  void initState() {
    super.initState();
    listener = ((web.Event event) async {
      final message = event as web.MessageEvent;
      if (frame == null ||
          message.source != frame!.contentWindow ||
          message.origin != web.window.location.origin)
        return;
      final reply = await widget.onRequest(message.data.dartify());
      if (mounted)
        frame?.contentWindow?.postMessage(
          jsonEncode(reply).toJS,
          web.window.location.origin.toJS,
        );
    }).toJS;
    web.window.addEventListener('message', listener);
  }

  void update() {
    final target = frame;
    if (target == null) return;
    timeout?.cancel();
    if (widget.remoteUrl != null) {
      target.removeAttribute('srcdoc');
      target.src = widget.remoteUrl.toString();
      timeout = Timer(const Duration(milliseconds: 900), () {
        if (mounted) {
          target.removeAttribute('src');
          target.srcdoc = widget.html.toJS;
        }
      });
    } else {
      target.srcdoc = widget.html.toJS;
    }
  }

  @override
  void didUpdateWidget(MicroWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html ||
        oldWidget.remoteUrl != widget.remoteUrl)
      update();
  }

  @override
  void dispose() {
    timeout?.cancel();
    web.window.removeEventListener('message', listener);
    frame = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView.fromTagName(
    tagName: 'iframe',
    onElementCreated: (element) {
      frame = element as web.HTMLIFrameElement;
      frame!.title = 'Jobs micro application';
      frame!.addEventListener(
        'load',
        ((web.Event _) {
          timeout?.cancel();
        }).toJS,
      );
      frame!.addEventListener(
        'error',
        ((web.Event _) {
          timeout?.cancel();
          frame?.removeAttribute('src');
          frame?.srcdoc = widget.html.toJS;
        }).toJS,
      );
      frame!.sandbox.add('allow-scripts');
      frame!.sandbox.add('allow-same-origin');
      frame!.style
        ..width = '100%'
        ..height = '100%'
        ..border = '0';
      update();
    },
  );
}
