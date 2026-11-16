import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'world_clock.dart';
import 'world_clock_strings.dart';

/// 从首页浮钟进入的骨架路由，不登记为Demo，也不写最近使用。
class WorldClockPage extends StatefulWidget {
  const WorldClockPage({super.key, this.now, this.onFormatChanged});
  final DateTime Function()? now;
  final ValueChanged<bool>? onFormatChanged;

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage>
    with WidgetsBindingObserver {
  Timer? ticker;
  late DateTime instant;
  List<WorldClockZone> zones = [];
  bool foreground = true;
  bool use12Hour = false;
  bool formatEdited = false;

  @override
  void initState() {
    super.initState();
    JobsDemoStrings.registerTranslations(worldClockTranslations);
    WidgetsBinding.instance.addObserver(this);
    foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    refresh();
    unawaited(loadFormat());
  }

  Future<void> loadFormat() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted && !formatEdited) {
      setState(
        () => use12Hour = preferences.getBool('hub.worldClock12Hour') ?? false,
      );
    }
  }

  void changeFormat(bool value) {
    setState(() {
      formatEdited = true;
      use12Hour = value;
      refresh();
    });
    unawaited(
      SharedPreferences.getInstance().then(
        (preferences) => preferences.setBool('hub.worldClock12Hour', value),
      ),
    );
    widget.onFormatChanged?.call(value);
  }

  void refresh() {
    instant = (widget.now ?? DateTime.now)().toUtc();
    try {
      zones = WorldClockCatalog.zonesAt(instant);
    } catch (_) {
      zones = [];
    }
  }

  void syncActivity() {
    final active = foreground && (ModalRoute.isCurrentOf(context) ?? true);
    if (active) {
      refresh();
      ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(refresh);
      });
    } else {
      ticker?.cancel();
      ticker = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncActivity();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    syncActivity();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = instant.toLocal();
    final locale = Localizations.localeOf(context).toString();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      key: const ValueKey('world-clock-page'),
      appBar: AppBar(title: Text(tr(context, '世界时钟'))),
      body: SafeArea(
        child: Column(
          children: [
            SwitchListTile.adaptive(
              key: const ValueKey('world-clock-12-hour'),
              title: Text(tr(context, '12小时制')),
              value: use12Hour,
              onChanged: changeFormat,
            ),
            const Divider(height: 1),
            Expanded(
              child: zones.isEmpty
                  ? JobsEmptyState(
                      title: '暂无时区数据',
                      message: '世界时钟',
                      onReload: () => setState(refresh),
                    )
                  : ListView.separated(
                      key: const PageStorageKey('world-clock-list'),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      itemCount: zones.length + 2,
                      separatorBuilder: (_, index) => index < 2
                          ? const SizedBox(height: 20)
                          : const Divider(height: 32),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            key: const ValueKey('world-clock-current'),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DefaultTextStyle.merge(
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                              ),
                              child: clockRow(
                                context,
                                city: tr(context, '当前时区'),
                                identifier: local.timeZoneName,
                                time: local,
                                locale: locale,
                                prominent: true,
                              ),
                            ),
                          );
                        }
                        if (index == 1) {
                          return Text(
                            tr(context, '其他时区'),
                            style: Theme.of(context).textTheme.titleMedium,
                          );
                        }
                        final zone = zones[index - 2];
                        return clockRow(
                          context,
                          city: tr(context, zone.city),
                          identifier: zone.location.name,
                          time: zone.at(instant),
                          locale: locale,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget clockRow(
    BuildContext context, {
    required String city,
    required String identifier,
    required DateTime time,
    required String locale,
    bool prominent = false,
  }) {
    final theme = Theme.of(context);
    final foreground = prominent
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    final secondary = prominent
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          city,
          style: theme.textTheme.titleLarge?.copyWith(color: foreground),
        ),
        const SizedBox(height: 4),
        Text(
          '${clockUtcOffset(time.timeZoneOffset)} · $identifier',
          style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
        ),
        const SizedBox(height: 10),
        Text(
          clockTime(time, use12Hour: use12Hour),
          style:
              (prominent
                      ? theme.textTheme.displaySmall
                      : theme.textTheme.headlineMedium)
                  ?.copyWith(
                    color: foreground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
        ),
        const SizedBox(height: 4),
        Text(
          dateText(time, locale),
          style: theme.textTheme.bodyLarge?.copyWith(color: secondary),
        ),
      ],
    );
  }

  String dateText(DateTime time, String locale) {
    if (locale != 'bo') return DateFormat.yMMMMEEEEd(locale).format(time);
    // intl 未内置藏文日期符号；本地化公历字段，保留当地星期而非英语回退。
    const weekdays = [
      'གཟའ་ཟླ་བ།',
      'གཟའ་མིག་དམར།',
      'གཟའ་ལྷག་པ།',
      'གཟའ་ཕུར་བུ།',
      'གཟའ་པ་སངས།',
      'གཟའ་སྤེན་པ།',
      'གཟའ་ཉི་མ།',
    ];
    return '${time.year} ལོ། ${time.month} ཟླ། ${time.day} ཚེས། '
        '${weekdays[time.weekday - 1]}';
  }
}
