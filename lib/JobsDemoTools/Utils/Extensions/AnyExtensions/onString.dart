import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';

extension StringX on String {
  /// 判断一个字符串是不是 图片链接或图片路径
  bool isImageUrl() {
    final RegExp imagePattern =
        RegExp(r'\.(jpg|jpeg|png|gif|bmp|webp|svg)$', caseSensitive: false);
    return imagePattern.hasMatch(this);
  }

  String append(String suffix) => this + suffix;
  String operator &(String suffix) => this + suffix; // 运算符重载

  Color color() {
    String colorCode = toUpperCase().replaceAll('#', '');
    if (colorCode.length == 6) {
      colorCode = 'FF$colorCode';
    }
    return Color(int.parse(colorCode, radix: 16));
  }

  Map<String, dynamic> toJson() => jsonDecode(this);

  String removeFirst(Pattern pattern, [int startIndex = 0]) =>
      replaceFirst(pattern, '', startIndex);
  String removeAll(Pattern pattern) => replaceAll(pattern, '');

  String encode() {
    return jsonEncode(this);
  }

  T decode<T>() {
    return jsonDecode(this);
  }

  String nowrap() {
    return (Characters(this).join('\u{200B}'));
  }

  bool containsHtmlTags() {
    final htmlTagPattern = RegExp(r"<[^>]+>");
    return htmlTagPattern.hasMatch(this);
  }

  String hideUsername() {
    // return this;
    if (length <= 3) {
      return "${this[0]}****${this[1]}";
    }
    return "${substring(0, min(2, length))}****${this[length - 1]}";
  }

  String show99() {
    return (int.tryParse(this) ?? 0) > 99 ? '...' : this;
  }
}
