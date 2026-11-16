import 'package:timezone/data/latest_all.dart' as database;
import 'package:timezone/timezone.dart' as tz;

/// 同一瞬间的偏移可能随夏令时改变，不能缓存成固定的24个整数时区。
class WorldClockZone {
  const WorldClockZone(this.city, this.location);
  final String city;
  final tz.Location location;

  tz.TZDateTime at(DateTime instant) => tz.TZDateTime.from(instant, location);
}

class WorldClockCatalog {
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    database.initializeTimeZones();
    _initialized = true;
  }

  // 同一偏移优先采用用户熟悉的城市；稀有偏移用实际所在地区代表。
  static const representatives = <String, String>{
    'Europe/Paris': '巴黎',
    'America/New_York': '纽约',
    'Asia/Shanghai': '上海',
    'Asia/Tokyo': '东京',
    'Europe/London': '伦敦',
    'Europe/Moscow': '莫斯科',
    'Asia/Dubai': '迪拜',
    'Asia/Kolkata': '新德里',
    'Asia/Kathmandu': '加德满都',
    'Asia/Tehran': '德黑兰',
    'Asia/Kabul': '喀布尔',
    'Asia/Karachi': '卡拉奇',
    'Asia/Dhaka': '达卡',
    'Asia/Yangon': '仰光',
    'Asia/Bangkok': '曼谷',
    'Australia/Eucla': '尤克拉',
    'Australia/Darwin': '达尔文',
    'Australia/Adelaide': '阿德莱德',
    'Australia/Sydney': '悉尼',
    'Australia/Brisbane': '布里斯班',
    'Australia/Lord_Howe': '豪勋爵岛',
    'Pacific/Noumea': '努美阿',
    'Pacific/Auckland': '奥克兰',
    'Pacific/Chatham': '查塔姆群岛',
    'Pacific/Fiji': '苏瓦',
    'Pacific/Tongatapu': '努库阿洛法',
    'Pacific/Kiritimati': '圣诞岛',
    'America/Los_Angeles': '洛杉矶',
    'America/Anchorage': '安克雷奇',
    'Pacific/Honolulu': '檀香山',
    'Pacific/Marquesas': '马克萨斯群岛',
    'Pacific/Gambier': '甘比尔群岛',
    'Pacific/Pitcairn': '皮特凯恩群岛',
    'Pacific/Pago_Pago': '帕果帕果',
    'America/Phoenix': '凤凰城',
    'America/Mexico_City': '墨西哥城',
    'America/Bogota': '波哥大',
    'America/Caracas': '加拉加斯',
    'America/St_Johns': '圣约翰斯',
    'America/Argentina/Buenos_Aires': '布宜诺斯艾利斯',
    'America/Noronha': '费尔南多迪诺罗尼亚',
    'Atlantic/Cape_Verde': '普拉亚',
    'Africa/Abidjan': '阿比让',
    'Africa/Johannesburg': '约翰内斯堡',
    'Etc/GMT+12': '贝克岛',
  };

  static List<WorldClockZone> zonesAt(DateTime instant) {
    initialize();
    final byOffset = <int, WorldClockZone>{};
    void include(String id, String city) {
      final location = tz.timeZoneDatabase.locations[id];
      if (location == null) return;
      final zone = WorldClockZone(city, location);
      byOffset.putIfAbsent(
        zone.at(instant).timeZoneOffset.inSeconds,
        () => zone,
      );
    }

    representatives.forEach(include);
    final identifiers = tz.timeZoneDatabase.locations.keys.toList()..sort();
    for (final id in identifiers) {
      include(id, id.split('/').last.replaceAll('_', ' '));
    }
    final offsets = byOffset.keys.toList()..sort();
    return [for (final offset in offsets) byOffset[offset]!];
  }
}

String clockUtcOffset(Duration offset) {
  final minutes = offset.inMinutes.abs();
  final sign = offset.isNegative ? '−' : '+';
  return 'UTC$sign${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';
}

String clockTime(DateTime time, {bool use12Hour = false}) {
  final hour = use12Hour
      ? (time.hour % 12 == 0 ? 12 : time.hour % 12)
      : time.hour;
  final digits = [
    hour,
    time.minute,
    time.second,
  ].map((part) => part.toString().padLeft(2, '0')).join(':');
  return use12Hour ? '$digits ${time.hour < 12 ? 'AM' : 'PM'}' : digits;
}
