import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/富文本/一般的富文本/attributed_model.dart';

class AttributedTextView extends StatelessWidget {
  final List<AttributedBlock> blocks;

  const AttributedTextView({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(children: _buildSpans(context)));
  }

  List<InlineSpan> _buildSpans(BuildContext context) {
    return blocks.map<InlineSpan>((block) {
      if (block.isImage && block.imageUrl != null) {
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Image.network(
            block.imageUrl!,
            height: 20,
            errorBuilder: (_, __, ___) => const LegacyText('❓'),
          ),
        );
      }

      final recognizer = block.action != null
          ? (TapGestureRecognizer()
              ..onTap = () => _handleAction(context, block.action!))
          : null;

      return TextSpan(
        text: block.text,
        style:
            block.style?.toTextStyle(context) ??
            Theme.of(context).textTheme.bodyMedium,
        recognizer: recognizer,
      );
    }).toList();
  }

  void _handleAction(BuildContext context, AttributedAction action) {
    switch (action.type) {
      case AttributedActionType.url:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: LegacyText('打开链接：${action.value}')));
        break;
      case AttributedActionType.mention:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: LegacyText('点击用户：${action.value}')));
        break;
      case AttributedActionType.none:
        break;
    }
  }
}

/// 支持多行富文本（外层封装 List）
class AttributedTextParagraphView extends StatelessWidget {
  final List<List<AttributedBlock>> paragraphs;
  const AttributedTextParagraphView({super.key, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((para) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            color: Colors.grey.shade100, // ✅ 背景避免白字白底
            padding: const EdgeInsets.all(8),
            child: AttributedTextView(blocks: para),
          ),
        );
      }).toList(),
    );
  }
}
