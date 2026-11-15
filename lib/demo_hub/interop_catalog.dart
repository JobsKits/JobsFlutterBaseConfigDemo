import '../demos/原生与Flutter往返/原生与Flutter往返.dart';
import 'legacy_catalog.dart';

final interopDemos = <LegacyDemoEntry>[
  LegacyDemoEntry(
    id: 'interop-native-flutter',
    title: '原生与Flutter往返',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/原生与Flutter往返/原生与Flutter往返.dart',
    tags: const [
      'FlutterDemoVC',
      'Native',
      'FlutterEngine',
      'MethodChannel',
      '双向传值',
    ],
    builder: (_) => const NativeFlutterRoundTripDemo(),
  ),
];
