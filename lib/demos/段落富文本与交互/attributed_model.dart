// 📁 model/attributed_model.dart
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:jobs_flutter_base_config/resource/emoji_char_map.dart'
    show emojiMap, emojiCharMap;

enum AttributedActionType { url, mention, none }

/// 将带表情标签的纯文本字符串转为富文本数据结构
List<AttributedBlock> fromPlainText(String text) {
  final RegExp tagExp = RegExp(r'\[.+?\]');
  final List<AttributedBlock> result = [];

  int lastIndex = 0;

  for (final match in tagExp.allMatches(text)) {
    final String beforeText = text.substring(lastIndex, match.start);
    if (beforeText.isNotEmpty) {
      result.add(
        AttributedBlock(text: beforeText, style: const AttributedStyle()),
      );
    }

    final String tag = match.group(0)!;
    if (emojiCharMap.containsKey(tag)) {
      result.add(
        AttributedBlock(
          text: emojiCharMap[tag],
          style: const AttributedStyle(),
        ),
      );
    } else {
      // 非法标签当普通文本处理
      result.add(
        AttributedBlock(
          text: tag,
          style: const AttributedStyle(color: '#FF0000'), // 高亮未识别标签
        ),
      );
    }

    lastIndex = match.end;
  }

  // 处理最后一段纯文本
  if (lastIndex < text.length) {
    result.add(
      AttributedBlock(
        text: text.substring(lastIndex),
        style: const AttributedStyle(),
      ),
    );
  }

  return result;
}

AttributedActionType parseActionType(String? type) {
  switch (type) {
    case 'url':
      return AttributedActionType.url;
    case 'mention':
      return AttributedActionType.mention;
    default:
      return AttributedActionType.none;
  }
}

String stringifyActionType(AttributedActionType type) {
  switch (type) {
    case AttributedActionType.url:
      return 'url';
    case AttributedActionType.mention:
      return 'mention';
    default:
      return 'none';
  }
}

class AttributedAction {
  final AttributedActionType type;
  final String value;

  AttributedAction({required this.type, required this.value});

  Map<String, dynamic> toMap() => {
    'type': stringifyActionType(type),
    'value': value,
  };

  factory AttributedAction.fromMap(Map<String, dynamic> map) {
    return AttributedAction(
      type: parseActionType(map['type']),
      value: map['value'] ?? '',
    );
  }
}

class AttributedStyle {
  final String? color;
  final bool bold;
  final bool italic;
  final bool underline;
  final double fontSize;

  const AttributedStyle({
    this.color,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.fontSize = 14,
  });

  TextStyle toTextStyle(BuildContext context) {
    return TextStyle(
      color: _parseColor(color ?? '#000000'), // 强制设定黑色默认
      fontWeight: bold ? FontWeight.bold : null,
      fontStyle: italic ? FontStyle.italic : null,
      fontSize: fontSize,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Map<String, dynamic> toMap() => {
    'color': color,
    'bold': bold,
    'italic': italic,
    'underline': underline,
    'fontSize': fontSize,
  };

  factory AttributedStyle.fromMap(Map<String, dynamic> map) {
    return AttributedStyle(
      color: map['color'],
      bold: map['bold'] ?? false,
      italic: map['italic'] ?? false,
      underline: map['underline'] ?? false,
      fontSize: (map['fontSize'] ?? 14).toDouble(),
    );
  }
}

class AttributedBlock {
  final String? text;
  final bool isImage;
  final String? imageUrl;
  final AttributedStyle? style;
  final AttributedAction? action;

  const AttributedBlock({
    this.text,
    this.style,
    this.action,
    this.isImage = false,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
    'text': text,
    'isImage': isImage,
    'imageUrl': imageUrl,
    'style': style?.toMap(),
    'action': action?.toMap(),
  };

  static String encodeToJson(List<AttributedBlock> blocks) =>
      jsonEncode(blocks.map((e) => e.toMap()).toList());

  static List<AttributedBlock> decodeFromJson(String jsonStr) {
    final list = jsonDecode(jsonStr);
    return List<AttributedBlock>.from(
      list.map((e) => AttributedBlock.fromMap(e)),
    );
  }

  /// 将纯文本（含表情标记）转换为富文本结构
  static List<AttributedBlock> fromPlainText(
    String text, {
    AttributedStyle? defaultStyle,
  }) {
    final RegExp exp = RegExp(r'\[.*?\]');
    final matches = exp.allMatches(text);
    List<AttributedBlock> result = [];

    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        result.add(
          AttributedBlock(
            text: text.substring(lastEnd, match.start),
            style: defaultStyle,
          ),
        );
      }
      final tag = text.substring(match.start, match.end);
      if (emojiMap.containsKey(tag)) {
        result.add(AttributedBlock(isImage: true, imageUrl: emojiMap[tag]));
      } else {
        result.add(AttributedBlock(text: tag, style: defaultStyle));
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      result.add(
        AttributedBlock(text: text.substring(lastEnd), style: defaultStyle),
      );
    }
    return result;
  }

  /// 导出为 HTML（简单示例）
  static String toHtml(List<AttributedBlock> blocks) {
    return blocks.map((block) {
      if (block.isImage && block.imageUrl != null) {
        return '<img src="${block.imageUrl}" height="20">';
      } else {
        final style = block.style;
        String open = '', close = '';
        if (style != null) {
          if (style.bold) {
            open += '<b>';
            close = '</b>$close';
          }
          if (style.italic) {
            open += '<i>';
            close = '</i>$close';
          }
          if (style.underline) {
            open += '<u>';
            close = '</u>$close';
          }
          open +=
              '<span style="color:${style.color ?? '#000'}; font-size:${style.fontSize}px">';
          close = '</span>$close';
        }
        final content = block.text ?? '';
        if (block.action?.type == AttributedActionType.url) {
          return '<a href="${block.action!.value}">$open$content$close</a>';
        }
        return '$open$content$close';
      }
    }).join();
  }

  /// ✅ 快速构建纯文本块
  factory AttributedBlock.plain(String text, {AttributedStyle? style}) {
    return AttributedBlock(text: text, style: style ?? const AttributedStyle());
  }

  /// ✅ 快速构建表情图片块
  factory AttributedBlock.emoji(String tag) {
    return AttributedBlock(isImage: true, imageUrl: emojiMap[tag] ?? '');
  }

  factory AttributedBlock.fromMap(Map<String, dynamic> map) {
    return AttributedBlock(
      text: map['text'],
      isImage: map['isImage'] ?? false,
      imageUrl: map['imageUrl'],
      style: map['style'] != null
          ? AttributedStyle.fromMap(map['style'])
          : null,
      action: map['action'] != null
          ? AttributedAction.fromMap(map['action'])
          : null,
    );
  }
}
