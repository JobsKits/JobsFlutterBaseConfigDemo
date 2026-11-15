import 'package:flutter/foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(HomePage(), title: 'InAppWebView Demo'),
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('InAppWebView Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const WebViewExample(),
              isScrollControlled: true,
            );
          },
          child: const LegacyText('Open WebView'),
        ),
      ),
    );
  }
}

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? webViewController;
  bool canPopWebView = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LegacyText('InAppWebView'),
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
          initialUrlRequest: URLRequest(
            url: WebUri.uri(Uri.parse("https://www.google.com")),
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) {
            legacyDebugPrint("Page started loading: $url");
          },
          onLoadStop: (controller, url) {
            legacyDebugPrint("Page finished loading: $url");
          },
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(
  legacyOriginalMain,
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  title: '旧例·嵌入网页混合滚动',
);
