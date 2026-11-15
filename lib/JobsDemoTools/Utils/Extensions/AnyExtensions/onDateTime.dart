/// 对任意时间
extension DateTimeFormatExt on DateTime {
  // 辅助：两位数
  String _two(int v) => v.toString().padLeft(2, '0');

  /// yyyy-MM-dd
  String get ymd => '$year-${_two(month)}-${_two(day)}';

  /// yyyy-MM-dd HH:mm:ss
  String get ymdHms => '$ymd ${_two(hour)}:${_two(minute)}:${_two(second)}';

  /// yyyy年MM月dd日
  String get ymdCn => '$year年${_two(month)}月${_two(day)}日';

  /// yyyy年MM月dd日 HH时mm分ss秒
  String get ymdHmsCn =>
      '$year年${_two(month)}月${_two(day)}日 ${_two(hour)}时${_two(minute)}分${_two(second)}秒';
}

/// 对当前时间（返回带格式的字符串形式）
class Now {
  static String get ymd => DateTime.now().ymd;
  static String get ymdHms => DateTime.now().ymdHms;
  static String get ymdCn => DateTime.now().ymdCn;
  static String get ymdHmsCn => DateTime.now().ymdHmsCn;
}
