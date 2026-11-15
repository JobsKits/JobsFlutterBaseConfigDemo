import 'package:flutter/material.dart';

/// 数字段可独立样式化，前后缀不会参与插值；复用到标签、按钮主标题或副标题。
class JobsFormattedNumber extends StatelessWidget {
  const JobsFormattedNumber({
    super.key,
    required this.value,
    this.decimals = 0,
    this.grouping = false,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.fractionStyle,
  });
  final double value;
  final int decimals;
  final bool grouping;
  final String prefix, suffix;
  final TextStyle? style, fractionStyle;
  static String format(
    double value, {
    int decimals = 0,
    bool grouping = false,
  }) {
    final parts = (value.isFinite ? value : 0)
        .toStringAsFixed(decimals.clamp(0, 8))
        .split('.');
    if (grouping)
      parts[0] = parts[0].replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
    return parts.join('.');
  }

  @override
  Widget build(BuildContext context) {
    final number = format(value, decimals: decimals, grouping: grouping);
    final dot = number.indexOf('.');
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: prefix),
          TextSpan(text: dot < 0 ? number : number.substring(0, dot)),
          if (dot >= 0)
            TextSpan(text: number.substring(dot), style: fractionStyle),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}
