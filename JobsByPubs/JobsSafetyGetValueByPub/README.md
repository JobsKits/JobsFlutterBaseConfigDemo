# <span id="前言">jobs_safety_get_value</span>

安全获取 `Map` 中的值，支持泛型类型判断和默认值回退。

## 安装 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```yaml
dependencies:
  jobs_safety_get_value:
    path: ../JobsSafetyGetValueByPub
```

## 使用 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

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

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
