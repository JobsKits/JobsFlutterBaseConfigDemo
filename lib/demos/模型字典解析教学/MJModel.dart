import 'dart:convert';

// ignore: unintended_html_in_doc_comment
/// 所有 model 需要继承 MJModel<T>
/// 工厂函数类型定义
typedef MJModelFactory<T> = T Function();

/// 通用模型基类，仿 MJExtension 风格，支持字段映射、默认值、嵌套解析、list 解析等
abstract class MJModel<T extends MJModel<T>> {
  /// 注册的模型工厂列表
  static final Map<Type, MJModelFactory> _factories = {};

  /// 子类应实现字段映射（jsonKey -> modelField）
  Map<String, String> keyMapping() => {};

  /// 子类应实现字段默认值
  Map<String, dynamic> defaultValues() => {};

  /// 注册模型工厂
  static void register<T extends MJModel<T>>(MJModelFactory<T> factory) {
    _factories[T] = factory;
  }

  /// 通过类型创建模型实例
  static MJModel? createByType(Type type) {
    final factory = _factories[type];
    return factory != null ? factory() : null;
  }

  /// 泛型创建模型（仅用于 MJModel.from）
  static T? create<T extends MJModel<T>>() {
    final factory = _factories[T];
    return factory != null ? factory() as T : null;
  }

  /// 自动 fromJson（使用字段映射和默认值）
  T fromJson(Map<String, dynamic> json) {
    final mapping = keyMapping();
    final defaults = defaultValues();
    for (var fieldName in getFieldNames()) {
      final jsonKey = mapping[fieldName] ?? fieldName;
      final value = json[jsonKey];

      final fieldType = getFieldType(fieldName);

      dynamic parsedValue = _convert(value, fieldType);

      if (parsedValue == null && defaults.containsKey(fieldName)) {
        parsedValue = defaults[fieldName];
      }

      setField(fieldName, parsedValue);
    }
    return this as T;
  }

  /// 解析 `List<Model>`
  List<T> fromJsonList(List<dynamic> list) =>
      list.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();

  /// 快捷解析：单个对象
  static T from<T extends MJModel<T>>(Map<String, dynamic> json) =>
      create<T>()!.fromJson(json);

  /// 快捷解析：列表
  static List<T> listFrom<T extends MJModel<T>>(List<dynamic> list) =>
      list.map((e) => from<T>(Map<String, dynamic>.from(e))).toList();

  /// 子类需实现：将对象转 Map（支持调试输出）
  Map<String, dynamic> toJson();

  /// 调试输出
  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());
  // ========== 私有工具函数 ==========
  /// 自动识别并转换嵌套对象、`List<Model>`、基本类型
  dynamic _convert(dynamic value, Type? type) {
    if (value == null) return null;
    if (type != null && _factories.containsKey(type)) {
      if (value is Map) {
        final model = createByType(type)!;
        return model.fromJson(Map<String, dynamic>.from(value));
      } else if (value is List) {
        return value
            .map(
              (e) => createByType(type)!.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
    }
    // 自动类型转换
    if (type == String && value is! String) return value.toString();
    if (type == int && value is String) return int.tryParse(value);
    if (type == bool && value is String) return value == 'true';
    return value;
  }

  /// 获取所有字段名称（子类实现）
  List<String> getFieldNames();

  /// 获取字段类型（子类实现）
  Type? getFieldType(String field);

  /// 设置字段值（子类实现）
  void setField(String field, dynamic value);
}
