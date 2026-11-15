import 'dart:convert';
import 'dart:io';
Future<void> main()async{final file=File.fromUri(Platform.script.resolve('../assets/catalog.json'));final data=jsonDecode(await file.readAsString()) as Map<String,dynamic>;stdout.writeln(const JsonEncoder.withIndent('  ').convert(data));}
