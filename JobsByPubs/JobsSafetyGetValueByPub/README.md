# jobs_safety_get_value

安全获取 `Map` 中的值，支持泛型类型判断和默认值回退。

## 安装

```yaml
dependencies:
  jobs_safety_get_value:
    path: ../JobsSafetyGetValueByPub
```

## 使用

```dart
import 'package:jobs_safety_get_value/jobs_safety_get_value.dart';

void main() {
  final user = <String, dynamic>{
    'name': 'Jobs',
    'age': 30,
    'isVip': true,
  };

  final String? name = safeGet<String>(user, 'name');
  final String gender = safeGet<String>(user, 'gender', '男')!;
  final bool? isVip = safeGet<bool>(user, 'isVip');
  final int? wrongType = safeGet<int>(user, 'name', -1);

  print(name);      // Jobs
  print(gender);    // 男
  print(isVip);     // true
  print(wrongType); // -1
}
```
