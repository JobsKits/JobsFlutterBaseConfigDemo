import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebview extends StatefulWidget {
  final String? webUri;
  final Function(double)? onProgress;
  const CustomWebview({super.key, this.webUri, this.onProgress});

  @override
  State<CustomWebview> createState() => _CustomWebviewState();
}

class _CustomWebviewState extends State<CustomWebview> {
  double currentProgress = 0;

  late final WebViewController controller;

  @override
  void initState() {
    debugPrint("webUri___ ${widget.webUri}");

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..getUserAgent().then((String? userAgent) {
        controller.setUserAgent('FlutterApp $userAgent'); // 必要
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            setState(() {
              currentProgress = progress / 100;
            });
          },
          onPageStarted: (String url) async {
            // 在页面开始加载时启用缓存设置
            await controller.runJavaScript('''
              (function() {
                if ('serviceWorker' in navigator) {
                  navigator.serviceWorker.register('/cacheServiceWorker.js');
                }
              })();
            ''');
          },
          onPageFinished: (String url) async {
            debugPrint("Page loading finished: $url");
            // 验证是否从缓存加载
            var isCached = await controller.runJavaScriptReturningResult('''
                caches.has('$url')
              ''');
            debugPrint("Is page cached: $isCached");
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.webUri ?? ""), headers: {
        'Cache-Control': 'public, max-age=604800',
      })
      ..setBackgroundColor(Colors.transparent);

    super.initState();
    // 确保缓存模式启用
    _enableCaching();
  }

  void _enableCaching() async {
    await controller.runJavaScript('''
      (function() {
        // 使用 Cache-Control 来确保缓存可用
        document.querySelectorAll('link[rel="stylesheet"], script, img').forEach((resource) => {
          resource.setAttribute('Cache-Control', 'public, max-age=604800'); // 缓存一周
        });
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 1,
          child: WebViewWidget(
            controller: controller,
          ),
        ),
        if (currentProgress < 1)
          const Center(
            child: CupertinoActivityIndicator(),
          ),
      ],
    );
  }
}
