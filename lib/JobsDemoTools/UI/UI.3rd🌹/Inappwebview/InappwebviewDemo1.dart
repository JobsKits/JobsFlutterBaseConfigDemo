import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() =>
    runApp(const JobsMaterialRunner(HomePage(), title: 'InAppWebView Demo'));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InAppWebView Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const WebViewExample(),
              isScrollControlled: true,
            );
          },
          child: const Text('Open WebView'),
        ),
      ),
    );
  }
}

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? webViewController;
  bool canPopWebView = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InAppWebView'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: PopScope(
        canPop: canPopWebView, // Determines whether back navigation is allowed
        onPopInvokedWithResult: (didPop, result) async {
          // Called when back navigation is triggered
          if (webViewController != null &&
              await webViewController!.canGoBack()) {
            webViewController!.goBack();
            setState(() {
              canPopWebView = true;
            });
          } else {
            setState(() {
              canPopWebView = false;
            });
          }
        },
        child: InAppWebView(
          initialUrlRequest:
              URLRequest(url: WebUri.uri(Uri.parse("https://www.google.com"))),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) {
            debugPrint("Page started loading: $url");
          },
          onLoadStop: (controller, url) {
            debugPrint("Page finished loading: $url");
          },
        ),
      ),
    );
  }
}
