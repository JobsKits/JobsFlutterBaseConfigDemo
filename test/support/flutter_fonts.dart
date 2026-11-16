import 'dart:io';

// The official Flutter launcher exports its active SDK, including outside FVM.
File flutterMaterialFont(String name) {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null || flutterRoot.isEmpty) {
    throw StateError('FLUTTER_ROOT is missing; run the suite with flutter test');
  }
  final font = File.fromUri(
    Directory(flutterRoot).absolute.uri.resolve(
      'bin/cache/artifacts/material_fonts/$name',
    ),
  );
  if (!font.existsSync()) {
    throw StateError('The active Flutter SDK font is missing: ${font.path}');
  }
  return font;
}
