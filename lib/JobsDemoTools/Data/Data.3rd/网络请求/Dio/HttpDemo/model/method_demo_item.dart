import 'method_type.dart';

class MethodDemoItem {
  MethodDemoItem({
    required this.method,
    required this.path,
    required this.description,
  });

  final MethodType method;
  final String path;
  final String description;

  factory MethodDemoItem.fromJson(Map<String, dynamic> json) {
    return MethodDemoItem(
      method: MethodType.from('${json['method'] ?? 'GET'}'),
      path: '${json['path'] ?? ''}',
      description: '${json['description'] ?? ''}',
    );
  }
}
