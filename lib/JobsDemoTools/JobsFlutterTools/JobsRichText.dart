import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() =>
    runApp(JobsMaterialRunner(_buildAmountShort(), title: 'JobsRichTextDemo'));

Widget _buildAmountShort() {
  final base = TextStyle(
    fontSize: 36.sp,
    color: const Color(0xFF63656E),
    fontWeight: FontWeight.w300,
  );

  return JobsRichText(
    baseStyle: base,
    segments: [
      seg('回归流水已经完成：'),
      seg('0', c: const Color(0xFF00C2C7)),
      seg(
        '元',
      ),
    ],
  );
}

// ===============================
// Core: 语义化分段
// ===============================
@immutable
class JR {
  final String text;
  final TextStyle? style; // 可只写差异（delta），基于 baseStyle 覆盖
  const JR(this.text, {this.style});
}

// ===============================
// Widget：富文本封装
// ===============================
class JobsRichText extends StatelessWidget {
  final List<JR> segments;
  final TextStyle baseStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final StrutStyle? strutStyle;
  final TextHeightBehavior? textHeightBehavior;
  final TextWidthBasis? textWidthBasis;
  final Locale? locale;
  final TextScaler? textScaler;

  const JobsRichText({
    super.key,
    required this.segments,
    required this.baseStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.strutStyle,
    this.textHeightBehavior,
    this.textWidthBasis,
    this.locale,
    this.textScaler,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: segments
            .map((s) => TextSpan(text: s.text, style: s.style))
            .toList(),
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      strutStyle: strutStyle,
      textHeightBehavior: textHeightBehavior,
      textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
      locale: locale,
      textScaler: textScaler ?? MediaQuery.maybeOf(context)?.textScaler,
    );
  }
}

// ===============================
// DSL：更短的写法（语法糖）
// ===============================
JR seg(
  String text, {
  double? size, // 字号（可直接传 .sp 结果）
  FontWeight? w, // 字重
  Color? c, // 颜色
  double? height, // 行高系数
  TextDecoration? deco, // 下划线等
  FontStyle? fs, // 斜体
  String? fontFamily, // 字体
  Paint? foreground, // 渐变描边等进阶
}) {
  return JR(
    text,
    style: TextStyle(
      fontSize: size,
      fontWeight: w,
      color: c,
      height: height,
      decoration: deco,
      fontStyle: fs,
      fontFamily: fontFamily,
      foreground: foreground,
    ),
  );
}

// ===============================
// TextStyle 扩展：链式改动（可选）
// ===============================
extension JobsTextStyleX on TextStyle {
  TextStyle w(FontWeight v) => copyWith(fontWeight: v);
  TextStyle c(Color v) => copyWith(color: v);
  TextStyle sz(double v) => copyWith(fontSize: v);
  TextStyle lh(double v) => copyWith(height: v);
}
