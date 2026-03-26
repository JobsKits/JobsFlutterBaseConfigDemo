import 'package:jobs_safety_get_value/jobs_safety_get_value.dart';

void main() {
  final user = <String, dynamic>{
    'name': 'Jobs',
    'age': 30,
    'isVip': true,
  };

  final String? name = safeGet<String>(user, 'name');
  print(name);

  final String? gender = safeGet<String>(user, 'gender');
  print(gender);

  final String gender2 = safeGet<String>(user, 'gender', '男')!;
  print(gender2);

  final bool? vip = safeGet<bool>(user, 'isVip');
  print(vip);

  final int? wrongType = safeGet<int>(user, 'name', -1);
  print(wrongType);
}
