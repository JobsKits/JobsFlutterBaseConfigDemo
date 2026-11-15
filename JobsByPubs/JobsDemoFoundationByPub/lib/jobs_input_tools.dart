import 'dart:math' as math;
import 'package:flutter/services.dart';

/// 保留输入法组合区；格式化只处理已确认的文本与对应光标。
class JobsTransformInputFormatter extends TextInputFormatter {
  JobsTransformInputFormatter(this.transform);
  final String Function(String) transform;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;
    final text = transform(newValue.text);
    final prefix = newValue.text.substring(
      0,
      newValue.selection.baseOffset.clamp(0, newValue.text.length),
    );
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: math.min(transform(prefix).length, text.length),
      ),
    );
  }
}

class JobsMoneyInputFormatter extends JobsTransformInputFormatter {
  JobsMoneyInputFormatter({int scale = 2})
    : super((text) {
        final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
        final dot = cleaned.indexOf('.');
        if (dot < 0) return cleaned;
        final decimal = cleaned.substring(dot + 1).replaceAll('.', '');
        return '${cleaned.substring(0, dot)}.${decimal.substring(0, math.min(scale, decimal.length))}';
      });
}

class JobsPhoneInputFormatter extends JobsTransformInputFormatter {
  JobsPhoneInputFormatter()
    : super((text) {
        final digits = text.replaceAll(RegExp(r'\D'), '');
        final limited = digits.substring(0, math.min(11, digits.length));
        return [
          limited.substring(0, math.min(3, limited.length)),
          if (limited.length > 3)
            limited.substring(3, math.min(7, limited.length)),
          if (limited.length > 7) limited.substring(7),
        ].join(' ');
      });
}

bool jobsValidMoney(String value) {
  final parsed = double.tryParse(value);
  return parsed != null && parsed.isFinite && parsed >= 0 && parsed <= 999999;
}

bool jobsValidPhone(String value) =>
    RegExp(r'^1\d{10}$').hasMatch(value.replaceAll(' ', ''));
String jobsInputMode(String previous, String next) =>
    next.length < previous.length
    ? 'delete'
    : next.contains('\n') && !previous.contains('\n')
    ? 'return'
    : next.endsWith(' ')
    ? 'space'
    : 'normal';
