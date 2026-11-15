import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_runners/jobs_runners.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/http_demo_page.dart';

void legacyOriginalMain() {
  legacyCaptureApp(
    JobsMaterialRunner(const HttpDemoPage(), title: 'HTTP Methods Demo'),
  );
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·HTTP网络教学启动');
