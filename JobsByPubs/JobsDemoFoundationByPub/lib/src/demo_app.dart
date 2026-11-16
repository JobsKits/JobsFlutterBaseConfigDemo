import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_strings.dart';
import 'refresh_strings.dart';

const jobsDemoLocales = <Locale>[
  Locale('zh'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  Locale('bo'),
  Locale('en'),
  Locale('ja'),
  Locale('fr'),
  Locale('es'),
  Locale('de'),
  Locale('ru'),
  Locale('ko'),
];

const jobsDemoLanguageNames = <String>[
  '简体中文',
  '繁體中文',
  'བོད་ཡིག',
  'English',
  '日本語',
  'Français',
  'Español',
  'Deutsch',
  'Русский',
  '한국어',
];

const jobsDemoLocalizationDelegates = <LocalizationsDelegate<dynamic>>[
  _MaterialDelegate(),
  _CupertinoDelegate(),
  GlobalWidgetsLocalizations.delegate,
];

// Flutter 没有内置藏文控件词典，平台控件回退英语，业务词典仍按藏文显示。
class _MaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(
        GlobalMaterialLocalizations.delegate.isSupported(locale)
            ? locale
            : const Locale('en'),
      );
  @override
  bool shouldReload(_MaterialDelegate old) => false;
}

class _CupertinoDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(
        GlobalCupertinoLocalizations.delegate.isSupported(locale)
            ? locale
            : const Locale('en'),
      );
  @override
  bool shouldReload(_CupertinoDelegate old) => false;
}

enum JobsRefreshStyle { flutter, jobs }

class JobsDemoSettings extends ChangeNotifier {
  JobsDemoSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('zh'),
    this.refreshStyle = JobsRefreshStyle.flutter,
    this.refreshHaptics = true,
    this.refreshSound = true,
  }) {
    JobsDemoStrings.registerTranslations(jobsRefreshTranslations);
  }

  ThemeMode themeMode;
  Locale locale;
  JobsRefreshStyle refreshStyle;
  bool refreshHaptics;
  bool refreshSound;
  SharedPreferences? _prefs;
  bool _disposed = false;

  Future<void> init() async {
    if (_disposed) return;
    final prefs = await SharedPreferences.getInstance();
    // 独立预览可能在原生偏好读取返回前已经关闭。
    if (_disposed) return;
    _prefs = prefs;
    final mode = _prefs!.getInt('jobs_demo_theme');
    if (mode != null && mode >= 0 && mode < ThemeMode.values.length) {
      themeMode = ThemeMode.values[mode];
    }
    final language = _prefs!.getString('jobs_demo_locale');
    if (language != null) {
      locale = jobsDemoLocales.firstWhere(
        (value) => value.toLanguageTag() == language,
        orElse: () => const Locale('zh'),
      );
    }
    final refresh = prefs.getString('jobs_demo_refresh_style');
    if (refresh != null) {
      refreshStyle = JobsRefreshStyle.values.firstWhere(
        (value) => value.name == refresh,
        orElse: () => JobsRefreshStyle.flutter,
      );
    }
    refreshHaptics = prefs.getBool('jobs_demo_refresh_haptics') ?? true;
    refreshSound = prefs.getBool('jobs_demo_refresh_sound') ?? true;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _prefs?.setInt('jobs_demo_theme', mode.index);
    notifyListeners();
  }

  void setLocale(Locale value) {
    locale = value;
    _prefs?.setString('jobs_demo_locale', value.toLanguageTag());
    notifyListeners();
  }

  void setRefreshStyle(JobsRefreshStyle value) {
    refreshStyle = value;
    _prefs?.setString('jobs_demo_refresh_style', value.name);
    notifyListeners();
  }

  void setRefreshHaptics(bool value) {
    refreshHaptics = value;
    _prefs?.setBool('jobs_demo_refresh_haptics', value);
    notifyListeners();
  }

  void setRefreshSound(bool value) {
    refreshSound = value;
    _prefs?.setBool('jobs_demo_refresh_sound', value);
    notifyListeners();
  }
}

class JobsDemoScope extends InheritedNotifier<JobsDemoSettings> {
  const JobsDemoScope({
    super.key,
    required JobsDemoSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static JobsDemoSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<JobsDemoScope>()?.notifier;

  static JobsDemoSettings of(BuildContext context) => maybeOf(context)!;
}

ThemeData jobsDemoTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colors = ColorScheme.fromSeed(
    seedColor: const Color(0xFF176653),
    brightness: brightness,
    surface: dark ? const Color(0xFF151B19) : const Color(0xFFF6F8F5),
  );
  return ThemeData(
    useMaterial3: true,
    fontFamilyFallback: const ['packages/jobs_demo_foundation/NotoTibetan'],
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: const CardThemeData(margin: EdgeInsets.zero),
  );
}

/// 独立文件预览壳；页面嵌入宿主时直接使用页面 Widget，避免嵌套 MaterialApp。
class JobsDemoApp extends StatefulWidget {
  const JobsDemoApp({
    super.key,
    required this.home,
    this.title = 'Jobs Demo',
    this.settings,
    this.showSettings = true,
  });
  final Widget home;
  final String title;
  final JobsDemoSettings? settings;
  final bool showSettings;
  @override
  State<JobsDemoApp> createState() => _JobsDemoAppState();
}

class _JobsDemoAppState extends State<JobsDemoApp> {
  late final JobsDemoSettings settings = widget.settings ?? JobsDemoSettings();
  @override
  void initState() {
    super.initState();
    if (widget.settings == null) settings.init();
  }

  @override
  void dispose() {
    if (widget.settings == null) settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => JobsDemoScope(
    settings: settings,
    child: ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: widget.title,
        locale: settings.locale,
        theme: jobsDemoTheme(Brightness.light),
        darkTheme: jobsDemoTheme(Brightness.dark),
        themeMode: settings.themeMode,
        supportedLocales: jobsDemoLocales,
        localizationsDelegates: jobsDemoLocalizationDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: widget.home,
            bottomNavigationBar: widget.showSettings
                ? SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: TextButton.icon(
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => JobsDemoScope(
                            settings: settings,
                            child: const JobsDemoSettingsPanel(),
                          ),
                        ),
                        icon: const Icon(Icons.tune),
                        label: Text(tr(context, '演示设置')),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    ),
  );
}

class JobsDemoSettingsPanel extends StatelessWidget {
  const JobsDemoSettingsPanel({super.key, this.scrollable = true});
  final bool scrollable;
  @override
  Widget build(BuildContext context) {
    final settings = JobsDemoScope.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        physics: scrollable ? null : const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            tr(context, '主题'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ThemeMode.values
                .map(
                  (mode) => ChoiceChip(
                    label: Text(tr(context, ['跟随系统', '白天', '黑夜'][mode.index])),
                    selected: settings.themeMode == mode,
                    onSelected: (_) => settings.setThemeMode(mode),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(
            tr(context, '语言'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              jobsDemoLocales.length,
              (index) => ChoiceChip(
                label: Text(jobsDemoLanguageNames[index]),
                selected: settings.locale == jobsDemoLocales[index],
                onSelected: (_) => settings.setLocale(jobsDemoLocales[index]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const JobsControlStyleSettings(),
        ],
      ),
    );
  }
}

/// 主工程与独立 Demo 共用同一组选项，切换立即作用于已有页面。
class JobsControlStyleSettings extends StatelessWidget {
  const JobsControlStyleSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = JobsDemoScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, '全局控件样式'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(tr(context, '下拉刷新')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final style in JobsRefreshStyle.values)
              ChoiceChip(
                label: Text(
                  tr(
                    context,
                    style == JobsRefreshStyle.flutter
                        ? 'Flutter 默认'
                        : 'Jobs 封装',
                  ),
                ),
                selected: settings.refreshStyle == style,
                onSelected: (_) => settings.setRefreshStyle(style),
              ),
          ],
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(tr(context, '刷新触觉反馈')),
          value: settings.refreshHaptics,
          onChanged: settings.setRefreshHaptics,
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(tr(context, '刷新提示音')),
          value: settings.refreshSound,
          onChanged: settings.setRefreshSound,
        ),
      ],
    );
  }
}
