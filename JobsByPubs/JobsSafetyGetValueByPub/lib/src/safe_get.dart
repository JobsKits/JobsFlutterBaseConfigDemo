/// 安全获取 [Map] 中的值，支持类型推断与默认值。
///
/// - 当 key 不存在时，返回 [defaultValue]
/// - 当 value 类型不匹配时，返回 [defaultValue]
/// - 当 value 类型匹配时，返回对应值
T? safeGet<T>(Map map, dynamic key, [T? defaultValue]) {
  final value = map[key];
  if (value is T) return value;
  return defaultValue;
}
