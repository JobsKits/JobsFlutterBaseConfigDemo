import 'dart:io';

import 'package:jobs_safety_get_value/jobs_safety_get_value.dart';

void main() {
  final user = <String, dynamic>{
    'name': 'Jobs',
    'age': 30,
    'isVip': true,
  };

  final String? name = safeGet<String>(user, 'name');
  stdout.writeln(name);

  final String? gender = safeGet<String>(user, 'gender');
  stdout.writeln(gender);

  final String gender2 = safeGet<String>(user, 'gender', '男')!;
  stdout.writeln(gender2);

  final bool? vip = safeGet<bool>(user, 'isVip');
  stdout.writeln(vip);

  final int? wrongType = safeGet<int>(user, 'name', -1);
  stdout.writeln(wrongType);
}
