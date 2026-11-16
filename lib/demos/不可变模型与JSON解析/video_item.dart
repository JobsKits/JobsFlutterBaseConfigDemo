import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'video_item.g.dart'; // ✅ 正确：同目录内文件

abstract class VideoItem implements Built<VideoItem, VideoItemBuilder> {
  String? get nick_name;
  String? get head;
  String? get thread_id;
  String? get first_post_id;
  String? get create_time;
  String? get play_count;
  String? get post_num;
  String? get agree_num;
  String? get share_num;
  String? get has_agree;
  String? get freq_num;
  String? get forum_id;
  String? get title;
  String? get source;
  String? get weight;
  String? get extra;
  String? get abtest_tag;
  String? get thumbnail_width;
  String? get thumbnail_height;
  String? get video_md5;
  String? get video_url;
  String? get video_duration;
  String? get video_width;
  String? get video_height;
  String? get video_type;
  String? get thumbnail_url;
  String? get video_format;
  String? get thumbnail_picid;
  String? get video_from;
  String? get video_log_id;
  String? get auditing;
  String? get origin_video_url;
  String? get video_length;
  String? get video_size;

  VideoItem._();
  factory VideoItem([void Function(VideoItemBuilder) updates]) = _$VideoItem;

  static Serializer<VideoItem> get serializer => _$videoItemSerializer;
}

abstract class VideoList implements Built<VideoList, VideoListBuilder> {
  BuiltList<VideoItem> get list;

  VideoList._();
  factory VideoList([void Function(VideoListBuilder) updates]) = _$VideoList;

  static Serializer<VideoList> get serializer => _$videoListSerializer;
}
