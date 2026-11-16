// 独立运行：flutter run -t "lib/demos/PWA离线容器/PWA离线容器.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/lab_support.dart';
import '../../demo_hub/micro_web_view.dart';

void main() => runApp(const JobsDemoApp(home: PWALabDemo(), title: 'PWA离线容器'));

class PWALabDemo extends StatefulWidget {
  const PWALabDemo({super.key});
  @override
  State<PWALabDemo> createState() => _State();
}

class _State extends State<PWALabDemo> {
  final address = TextEditingController();
  Uri? remote;
  String html = '';
  String error = '';
  int generation = 0;
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/HTML/micro_lab/index.html').then((value) {
      if (mounted) setState(() => html = value);
    });
  }

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  void open() {
    try {
      final url = Uri.parse(address.text.trim());
      if (url.scheme != 'https' || url.host.isEmpty || url.userInfo.isNotEmpty)
        throw const FormatException('HTTPS URL required');
      setState(() {
        remote = url;
        error = '';
        generation++;
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).toLanguageTag();
    final local = kIsWeb
        ? Uri.base.resolve(
            'assets/assets/HTML/micro_lab/index.html?lang=$language',
          )
        : null;
    return LabFrame(
      title: 'PWA离线容器',
      children: [
        TextField(
          controller: address,
          decoration: const InputDecoration(labelText: 'HTTPS PWA URL'),
        ),
        Wrap(
          spacing: 8,
          children: [
            labAction(context, '打开', open),
            labAction(
              context,
              '恢复默认',
              () => setState(() {
                remote = null;
                generation++;
              }),
            ),
          ],
        ),
        if (error.isNotEmpty) labOutput(context, error),
        SizedBox(
          height: 460,
          child: MicroWebView(
            key: ValueKey(generation),
            html: html.replaceFirst("||'en'", "||'$language'"),
            remoteUrl: remote ?? local,
            onRequest: (_) async => {
              'ok': false,
              'error': 'Capabilities not granted to remote PWA',
            },
          ),
        ),
      ],
    );
  }
}
