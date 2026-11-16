// 独立运行：flutter run -t "lib/demos/段落富文本与交互/sample_data.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/富文本/一般的富文本/attributed_model.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/富文本/一般的富文本/attributed_text_view.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '段落富文本与交互');

void legacyOriginalMain() => legacyCaptureApp(
  JobsMaterialRunner(
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: AttributedTextParagraphView(paragraphs: sampleParagraphs),
    ),
    title: '富文本统一组件示例',
  ),
);

final List<List<AttributedBlock>> sampleParagraphs = [
  AttributedBlock.fromPlainText("🧪 行1：你好，[smile] 欢迎来到富文本世界！"),
  AttributedBlock.fromPlainText("🧪 行2：@张三 [thumbs_up] [wave]"),
  AttributedBlock.fromPlainText("🧪 行3：请阅读《使用说明》 [book]"),
  AttributedBlock.fromPlainText(
    "🧪 行4：Hi [smile], welcome [rocket] Flutter [unknown]",
  ),
  AttributedBlock.fromPlainText("🧪 行5：感谢你！🎉 [party]"),
  AttributedBlock.fromPlainText("🧪 行6：这是一个表情： [smile] 👏🏻 测试结束"),
];

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: '一般的富文本');
