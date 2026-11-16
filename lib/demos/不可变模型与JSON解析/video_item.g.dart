// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<VideoItem> _$videoItemSerializer = _$VideoItemSerializer();
Serializer<VideoList> _$videoListSerializer = _$VideoListSerializer();

class _$VideoItemSerializer implements StructuredSerializer<VideoItem> {
  @override
  final Iterable<Type> types = const [VideoItem, _$VideoItem];
  @override
  final String wireName = 'VideoItem';

  @override
  Iterable<Object?> serialize(Serializers serializers, VideoItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.nick_name;
    if (value != null) {
      result
        ..add('nick_name')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.head;
    if (value != null) {
      result
        ..add('head')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.thread_id;
    if (value != null) {
      result
        ..add('thread_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.first_post_id;
    if (value != null) {
      result
        ..add('first_post_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.create_time;
    if (value != null) {
      result
        ..add('create_time')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.play_count;
    if (value != null) {
      result
        ..add('play_count')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.post_num;
    if (value != null) {
      result
        ..add('post_num')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.agree_num;
    if (value != null) {
      result
        ..add('agree_num')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.share_num;
    if (value != null) {
      result
        ..add('share_num')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.has_agree;
    if (value != null) {
      result
        ..add('has_agree')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.freq_num;
    if (value != null) {
      result
        ..add('freq_num')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.forum_id;
    if (value != null) {
      result
        ..add('forum_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.source;
    if (value != null) {
      result
        ..add('source')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.weight;
    if (value != null) {
      result
        ..add('weight')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.extra;
    if (value != null) {
      result
        ..add('extra')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.abtest_tag;
    if (value != null) {
      result
        ..add('abtest_tag')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.thumbnail_width;
    if (value != null) {
      result
        ..add('thumbnail_width')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.thumbnail_height;
    if (value != null) {
      result
        ..add('thumbnail_height')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_md5;
    if (value != null) {
      result
        ..add('video_md5')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_url;
    if (value != null) {
      result
        ..add('video_url')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_duration;
    if (value != null) {
      result
        ..add('video_duration')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_width;
    if (value != null) {
      result
        ..add('video_width')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_height;
    if (value != null) {
      result
        ..add('video_height')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_type;
    if (value != null) {
      result
        ..add('video_type')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.thumbnail_url;
    if (value != null) {
      result
        ..add('thumbnail_url')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_format;
    if (value != null) {
      result
        ..add('video_format')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.thumbnail_picid;
    if (value != null) {
      result
        ..add('thumbnail_picid')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_from;
    if (value != null) {
      result
        ..add('video_from')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_log_id;
    if (value != null) {
      result
        ..add('video_log_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.auditing;
    if (value != null) {
      result
        ..add('auditing')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.origin_video_url;
    if (value != null) {
      result
        ..add('origin_video_url')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_length;
    if (value != null) {
      result
        ..add('video_length')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.video_size;
    if (value != null) {
      result
        ..add('video_size')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  VideoItem deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = VideoItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'nick_name':
          result.nick_name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'head':
          result.head = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'thread_id':
          result.thread_id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'first_post_id':
          result.first_post_id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'create_time':
          result.create_time = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'play_count':
          result.play_count = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'post_num':
          result.post_num = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'agree_num':
          result.agree_num = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'share_num':
          result.share_num = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'has_agree':
          result.has_agree = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'freq_num':
          result.freq_num = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'forum_id':
          result.forum_id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'source':
          result.source = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'weight':
          result.weight = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'extra':
          result.extra = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'abtest_tag':
          result.abtest_tag = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'thumbnail_width':
          result.thumbnail_width = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'thumbnail_height':
          result.thumbnail_height = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_md5':
          result.video_md5 = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_url':
          result.video_url = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_duration':
          result.video_duration = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_width':
          result.video_width = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_height':
          result.video_height = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_type':
          result.video_type = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'thumbnail_url':
          result.thumbnail_url = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_format':
          result.video_format = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'thumbnail_picid':
          result.thumbnail_picid = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_from':
          result.video_from = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_log_id':
          result.video_log_id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'auditing':
          result.auditing = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_video_url':
          result.origin_video_url = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_length':
          result.video_length = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'video_size':
          result.video_size = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$VideoListSerializer implements StructuredSerializer<VideoList> {
  @override
  final Iterable<Type> types = const [VideoList, _$VideoList];
  @override
  final String wireName = 'VideoList';

  @override
  Iterable<Object?> serialize(Serializers serializers, VideoList object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'list',
      serializers.serialize(object.list,
          specifiedType:
              const FullType(BuiltList, const [const FullType(VideoItem)])),
    ];

    return result;
  }

  @override
  VideoList deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = VideoListBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'list':
          result.list.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(VideoItem)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$VideoItem extends VideoItem {
  @override
  final String? nick_name;
  @override
  final String? head;
  @override
  final String? thread_id;
  @override
  final String? first_post_id;
  @override
  final String? create_time;
  @override
  final String? play_count;
  @override
  final String? post_num;
  @override
  final String? agree_num;
  @override
  final String? share_num;
  @override
  final String? has_agree;
  @override
  final String? freq_num;
  @override
  final String? forum_id;
  @override
  final String? title;
  @override
  final String? source;
  @override
  final String? weight;
  @override
  final String? extra;
  @override
  final String? abtest_tag;
  @override
  final String? thumbnail_width;
  @override
  final String? thumbnail_height;
  @override
  final String? video_md5;
  @override
  final String? video_url;
  @override
  final String? video_duration;
  @override
  final String? video_width;
  @override
  final String? video_height;
  @override
  final String? video_type;
  @override
  final String? thumbnail_url;
  @override
  final String? video_format;
  @override
  final String? thumbnail_picid;
  @override
  final String? video_from;
  @override
  final String? video_log_id;
  @override
  final String? auditing;
  @override
  final String? origin_video_url;
  @override
  final String? video_length;
  @override
  final String? video_size;

  factory _$VideoItem([void Function(VideoItemBuilder)? updates]) =>
      (VideoItemBuilder()..update(updates))._build();

  _$VideoItem._(
      {this.nick_name,
      this.head,
      this.thread_id,
      this.first_post_id,
      this.create_time,
      this.play_count,
      this.post_num,
      this.agree_num,
      this.share_num,
      this.has_agree,
      this.freq_num,
      this.forum_id,
      this.title,
      this.source,
      this.weight,
      this.extra,
      this.abtest_tag,
      this.thumbnail_width,
      this.thumbnail_height,
      this.video_md5,
      this.video_url,
      this.video_duration,
      this.video_width,
      this.video_height,
      this.video_type,
      this.thumbnail_url,
      this.video_format,
      this.thumbnail_picid,
      this.video_from,
      this.video_log_id,
      this.auditing,
      this.origin_video_url,
      this.video_length,
      this.video_size})
      : super._();
  @override
  VideoItem rebuild(void Function(VideoItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VideoItemBuilder toBuilder() => VideoItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VideoItem &&
        nick_name == other.nick_name &&
        head == other.head &&
        thread_id == other.thread_id &&
        first_post_id == other.first_post_id &&
        create_time == other.create_time &&
        play_count == other.play_count &&
        post_num == other.post_num &&
        agree_num == other.agree_num &&
        share_num == other.share_num &&
        has_agree == other.has_agree &&
        freq_num == other.freq_num &&
        forum_id == other.forum_id &&
        title == other.title &&
        source == other.source &&
        weight == other.weight &&
        extra == other.extra &&
        abtest_tag == other.abtest_tag &&
        thumbnail_width == other.thumbnail_width &&
        thumbnail_height == other.thumbnail_height &&
        video_md5 == other.video_md5 &&
        video_url == other.video_url &&
        video_duration == other.video_duration &&
        video_width == other.video_width &&
        video_height == other.video_height &&
        video_type == other.video_type &&
        thumbnail_url == other.thumbnail_url &&
        video_format == other.video_format &&
        thumbnail_picid == other.thumbnail_picid &&
        video_from == other.video_from &&
        video_log_id == other.video_log_id &&
        auditing == other.auditing &&
        origin_video_url == other.origin_video_url &&
        video_length == other.video_length &&
        video_size == other.video_size;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nick_name.hashCode);
    _$hash = $jc(_$hash, head.hashCode);
    _$hash = $jc(_$hash, thread_id.hashCode);
    _$hash = $jc(_$hash, first_post_id.hashCode);
    _$hash = $jc(_$hash, create_time.hashCode);
    _$hash = $jc(_$hash, play_count.hashCode);
    _$hash = $jc(_$hash, post_num.hashCode);
    _$hash = $jc(_$hash, agree_num.hashCode);
    _$hash = $jc(_$hash, share_num.hashCode);
    _$hash = $jc(_$hash, has_agree.hashCode);
    _$hash = $jc(_$hash, freq_num.hashCode);
    _$hash = $jc(_$hash, forum_id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, source.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, extra.hashCode);
    _$hash = $jc(_$hash, abtest_tag.hashCode);
    _$hash = $jc(_$hash, thumbnail_width.hashCode);
    _$hash = $jc(_$hash, thumbnail_height.hashCode);
    _$hash = $jc(_$hash, video_md5.hashCode);
    _$hash = $jc(_$hash, video_url.hashCode);
    _$hash = $jc(_$hash, video_duration.hashCode);
    _$hash = $jc(_$hash, video_width.hashCode);
    _$hash = $jc(_$hash, video_height.hashCode);
    _$hash = $jc(_$hash, video_type.hashCode);
    _$hash = $jc(_$hash, thumbnail_url.hashCode);
    _$hash = $jc(_$hash, video_format.hashCode);
    _$hash = $jc(_$hash, thumbnail_picid.hashCode);
    _$hash = $jc(_$hash, video_from.hashCode);
    _$hash = $jc(_$hash, video_log_id.hashCode);
    _$hash = $jc(_$hash, auditing.hashCode);
    _$hash = $jc(_$hash, origin_video_url.hashCode);
    _$hash = $jc(_$hash, video_length.hashCode);
    _$hash = $jc(_$hash, video_size.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VideoItem')
          ..add('nick_name', nick_name)
          ..add('head', head)
          ..add('thread_id', thread_id)
          ..add('first_post_id', first_post_id)
          ..add('create_time', create_time)
          ..add('play_count', play_count)
          ..add('post_num', post_num)
          ..add('agree_num', agree_num)
          ..add('share_num', share_num)
          ..add('has_agree', has_agree)
          ..add('freq_num', freq_num)
          ..add('forum_id', forum_id)
          ..add('title', title)
          ..add('source', source)
          ..add('weight', weight)
          ..add('extra', extra)
          ..add('abtest_tag', abtest_tag)
          ..add('thumbnail_width', thumbnail_width)
          ..add('thumbnail_height', thumbnail_height)
          ..add('video_md5', video_md5)
          ..add('video_url', video_url)
          ..add('video_duration', video_duration)
          ..add('video_width', video_width)
          ..add('video_height', video_height)
          ..add('video_type', video_type)
          ..add('thumbnail_url', thumbnail_url)
          ..add('video_format', video_format)
          ..add('thumbnail_picid', thumbnail_picid)
          ..add('video_from', video_from)
          ..add('video_log_id', video_log_id)
          ..add('auditing', auditing)
          ..add('origin_video_url', origin_video_url)
          ..add('video_length', video_length)
          ..add('video_size', video_size))
        .toString();
  }
}

class VideoItemBuilder implements Builder<VideoItem, VideoItemBuilder> {
  _$VideoItem? _$v;

  String? _nick_name;
  String? get nick_name => _$this._nick_name;
  set nick_name(String? nick_name) => _$this._nick_name = nick_name;

  String? _head;
  String? get head => _$this._head;
  set head(String? head) => _$this._head = head;

  String? _thread_id;
  String? get thread_id => _$this._thread_id;
  set thread_id(String? thread_id) => _$this._thread_id = thread_id;

  String? _first_post_id;
  String? get first_post_id => _$this._first_post_id;
  set first_post_id(String? first_post_id) =>
      _$this._first_post_id = first_post_id;

  String? _create_time;
  String? get create_time => _$this._create_time;
  set create_time(String? create_time) => _$this._create_time = create_time;

  String? _play_count;
  String? get play_count => _$this._play_count;
  set play_count(String? play_count) => _$this._play_count = play_count;

  String? _post_num;
  String? get post_num => _$this._post_num;
  set post_num(String? post_num) => _$this._post_num = post_num;

  String? _agree_num;
  String? get agree_num => _$this._agree_num;
  set agree_num(String? agree_num) => _$this._agree_num = agree_num;

  String? _share_num;
  String? get share_num => _$this._share_num;
  set share_num(String? share_num) => _$this._share_num = share_num;

  String? _has_agree;
  String? get has_agree => _$this._has_agree;
  set has_agree(String? has_agree) => _$this._has_agree = has_agree;

  String? _freq_num;
  String? get freq_num => _$this._freq_num;
  set freq_num(String? freq_num) => _$this._freq_num = freq_num;

  String? _forum_id;
  String? get forum_id => _$this._forum_id;
  set forum_id(String? forum_id) => _$this._forum_id = forum_id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _source;
  String? get source => _$this._source;
  set source(String? source) => _$this._source = source;

  String? _weight;
  String? get weight => _$this._weight;
  set weight(String? weight) => _$this._weight = weight;

  String? _extra;
  String? get extra => _$this._extra;
  set extra(String? extra) => _$this._extra = extra;

  String? _abtest_tag;
  String? get abtest_tag => _$this._abtest_tag;
  set abtest_tag(String? abtest_tag) => _$this._abtest_tag = abtest_tag;

  String? _thumbnail_width;
  String? get thumbnail_width => _$this._thumbnail_width;
  set thumbnail_width(String? thumbnail_width) =>
      _$this._thumbnail_width = thumbnail_width;

  String? _thumbnail_height;
  String? get thumbnail_height => _$this._thumbnail_height;
  set thumbnail_height(String? thumbnail_height) =>
      _$this._thumbnail_height = thumbnail_height;

  String? _video_md5;
  String? get video_md5 => _$this._video_md5;
  set video_md5(String? video_md5) => _$this._video_md5 = video_md5;

  String? _video_url;
  String? get video_url => _$this._video_url;
  set video_url(String? video_url) => _$this._video_url = video_url;

  String? _video_duration;
  String? get video_duration => _$this._video_duration;
  set video_duration(String? video_duration) =>
      _$this._video_duration = video_duration;

  String? _video_width;
  String? get video_width => _$this._video_width;
  set video_width(String? video_width) => _$this._video_width = video_width;

  String? _video_height;
  String? get video_height => _$this._video_height;
  set video_height(String? video_height) => _$this._video_height = video_height;

  String? _video_type;
  String? get video_type => _$this._video_type;
  set video_type(String? video_type) => _$this._video_type = video_type;

  String? _thumbnail_url;
  String? get thumbnail_url => _$this._thumbnail_url;
  set thumbnail_url(String? thumbnail_url) =>
      _$this._thumbnail_url = thumbnail_url;

  String? _video_format;
  String? get video_format => _$this._video_format;
  set video_format(String? video_format) => _$this._video_format = video_format;

  String? _thumbnail_picid;
  String? get thumbnail_picid => _$this._thumbnail_picid;
  set thumbnail_picid(String? thumbnail_picid) =>
      _$this._thumbnail_picid = thumbnail_picid;

  String? _video_from;
  String? get video_from => _$this._video_from;
  set video_from(String? video_from) => _$this._video_from = video_from;

  String? _video_log_id;
  String? get video_log_id => _$this._video_log_id;
  set video_log_id(String? video_log_id) => _$this._video_log_id = video_log_id;

  String? _auditing;
  String? get auditing => _$this._auditing;
  set auditing(String? auditing) => _$this._auditing = auditing;

  String? _origin_video_url;
  String? get origin_video_url => _$this._origin_video_url;
  set origin_video_url(String? origin_video_url) =>
      _$this._origin_video_url = origin_video_url;

  String? _video_length;
  String? get video_length => _$this._video_length;
  set video_length(String? video_length) => _$this._video_length = video_length;

  String? _video_size;
  String? get video_size => _$this._video_size;
  set video_size(String? video_size) => _$this._video_size = video_size;

  VideoItemBuilder();

  VideoItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nick_name = $v.nick_name;
      _head = $v.head;
      _thread_id = $v.thread_id;
      _first_post_id = $v.first_post_id;
      _create_time = $v.create_time;
      _play_count = $v.play_count;
      _post_num = $v.post_num;
      _agree_num = $v.agree_num;
      _share_num = $v.share_num;
      _has_agree = $v.has_agree;
      _freq_num = $v.freq_num;
      _forum_id = $v.forum_id;
      _title = $v.title;
      _source = $v.source;
      _weight = $v.weight;
      _extra = $v.extra;
      _abtest_tag = $v.abtest_tag;
      _thumbnail_width = $v.thumbnail_width;
      _thumbnail_height = $v.thumbnail_height;
      _video_md5 = $v.video_md5;
      _video_url = $v.video_url;
      _video_duration = $v.video_duration;
      _video_width = $v.video_width;
      _video_height = $v.video_height;
      _video_type = $v.video_type;
      _thumbnail_url = $v.thumbnail_url;
      _video_format = $v.video_format;
      _thumbnail_picid = $v.thumbnail_picid;
      _video_from = $v.video_from;
      _video_log_id = $v.video_log_id;
      _auditing = $v.auditing;
      _origin_video_url = $v.origin_video_url;
      _video_length = $v.video_length;
      _video_size = $v.video_size;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VideoItem other) {
    _$v = other as _$VideoItem;
  }

  @override
  void update(void Function(VideoItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VideoItem build() => _build();

  _$VideoItem _build() {
    final _$result = _$v ??
        _$VideoItem._(
          nick_name: nick_name,
          head: head,
          thread_id: thread_id,
          first_post_id: first_post_id,
          create_time: create_time,
          play_count: play_count,
          post_num: post_num,
          agree_num: agree_num,
          share_num: share_num,
          has_agree: has_agree,
          freq_num: freq_num,
          forum_id: forum_id,
          title: title,
          source: source,
          weight: weight,
          extra: extra,
          abtest_tag: abtest_tag,
          thumbnail_width: thumbnail_width,
          thumbnail_height: thumbnail_height,
          video_md5: video_md5,
          video_url: video_url,
          video_duration: video_duration,
          video_width: video_width,
          video_height: video_height,
          video_type: video_type,
          thumbnail_url: thumbnail_url,
          video_format: video_format,
          thumbnail_picid: thumbnail_picid,
          video_from: video_from,
          video_log_id: video_log_id,
          auditing: auditing,
          origin_video_url: origin_video_url,
          video_length: video_length,
          video_size: video_size,
        );
    replace(_$result);
    return _$result;
  }
}

class _$VideoList extends VideoList {
  @override
  final BuiltList<VideoItem> list;

  factory _$VideoList([void Function(VideoListBuilder)? updates]) =>
      (VideoListBuilder()..update(updates))._build();

  _$VideoList._({required this.list}) : super._();
  @override
  VideoList rebuild(void Function(VideoListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VideoListBuilder toBuilder() => VideoListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VideoList && list == other.list;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, list.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VideoList')..add('list', list))
        .toString();
  }
}

class VideoListBuilder implements Builder<VideoList, VideoListBuilder> {
  _$VideoList? _$v;

  ListBuilder<VideoItem>? _list;
  ListBuilder<VideoItem> get list => _$this._list ??= ListBuilder<VideoItem>();
  set list(ListBuilder<VideoItem>? list) => _$this._list = list;

  VideoListBuilder();

  VideoListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _list = $v.list.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VideoList other) {
    _$v = other as _$VideoList;
  }

  @override
  void update(void Function(VideoListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VideoList build() => _build();

  _$VideoList _build() {
    _$VideoList _$result;
    try {
      _$result = _$v ??
          _$VideoList._(
            list: list.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'list';
        list.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VideoList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
