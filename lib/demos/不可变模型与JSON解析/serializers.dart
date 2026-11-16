library serializers; // ✅ 加上这一句非常关键！

import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/JSONs.analyze/built_value_demo✅/利用脚本自动生成的built_value序列化文件/video_item.dart';
import 'package:built_collection/built_collection.dart'; // ✅ 没有这一句就会找不到 BuiltList

part 'serializers.g.dart'; // ✅ 生成器才能识别到它，并生成对应的序列化文件

@SerializersFor([VideoItem, VideoList])
final Serializers serializers =
    (_$serializers.toBuilder()
          ..addPlugin(StandardJsonPlugin())
          ..addBuilderFactory(
            const FullType(BuiltList, [FullType(VideoItem)]),
            () => ListBuilder<VideoItem>(),
          ))
        .build();
