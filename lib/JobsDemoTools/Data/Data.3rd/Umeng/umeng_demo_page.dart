import 'package:flutter/material.dart';

import 'umeng_demo_config.dart';
import 'umeng_demo_service.dart';

class UmengDemoPage extends StatefulWidget {
  const UmengDemoPage({super.key, required this.service});

  final UmengDemoService service;

  @override
  State<UmengDemoPage> createState() => _UmengDemoPageState();
}

class _UmengDemoPageState extends State<UmengDemoPage> {
  bool _consent = false;
  bool _isPerformingAction = false;

  @override
  void initState() {
    super.initState();
    _consent = widget.service.isInitialized;
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _isPerformingAction = true;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作未完成：$error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final service = widget.service;
        final colors = Theme.of(context).colorScheme;
        final busy = service.isInitializing || _isPerformingAction;
        final canReport = service.isSupported && service.isInitialized && !busy;
        final buttonStyle = FilledButton.styleFrom(
          disabledForegroundColor: colors.onSurface,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        );
        final outlineStyle = OutlinedButton.styleFrom(
          foregroundColor: colors.onSurface,
          disabledForegroundColor: colors.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        );

        return Scaffold(
          appBar: AppBar(
            toolbarHeight:
                MediaQuery.textScalerOf(context).scale(kToolbarHeight),
            title: const Text('友盟统计与崩溃演示'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatus(context),
                      const SizedBox(height: 16),
                      _DemoSection(
                        title: '一、隐私同意与初始化',
                        children: [
                          const _Description(
                            '本演示通过 Flutter 插件接入友盟移动统计与 U-APM。'
                            '同意后才初始化 SDK、采集并处理演示统计及异常数据。',
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('我已了解并同意本次演示的数据采集'),
                            value: _consent,
                            onChanged: busy || service.isInitialized
                                ? null
                                : (value) {
                                    setState(() {
                                      _consent = value ?? false;
                                    });
                                  },
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton(
                                style: buttonStyle,
                                onPressed: _consent &&
                                        service.isSupported &&
                                        !service.isInitialized &&
                                        !busy
                                    ? () => _runAction(
                                          () => service.initialize(
                                            consent: _consent,
                                          ),
                                        )
                                    : null,
                                child: Text(
                                  service.isInitializing
                                      ? '正在初始化…'
                                      : service.isInitialized
                                          ? '初始化已调用'
                                          : '同意并初始化 / 重试',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const _Description(
                            '初始化失败后，可保留同意勾选并点击重试。'
                            '本页仅供 SDK 接入验证，正式应用应接入自己的隐私政策与同意流程。',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DemoSection(
                        title: '二、移动统计',
                        children: [
                          const _Description(
                            '自定义事件：demo_button_click。'
                            '演示账号：test_user_001；可分别验证事件、登录和退出。',
                          ),
                          const SizedBox(height: 12),
                          Text('当前账号：${service.userId ?? '未登录'}'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton(
                                style: buttonStyle,
                                onPressed: canReport
                                    ? () => _runAction(service.trackEvent)
                                    : null,
                                child: const Text('发送自定义事件'),
                              ),
                              OutlinedButton(
                                style: outlineStyle,
                                onPressed: canReport
                                    ? () => _runAction(
                                          () => service.signIn('test_user_001'),
                                        )
                                    : null,
                                child: const Text('登录演示账号'),
                              ),
                              OutlinedButton(
                                style: outlineStyle,
                                onPressed: canReport && service.userId != null
                                    ? () => _runAction(service.signOut)
                                    : null,
                                child: const Text('退出演示账号'),
                              ),
                              OutlinedButton(
                                style: outlineStyle,
                                onPressed: () {
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      settings: const RouteSettings(
                                        name: '/umeng/detail',
                                      ),
                                      builder: (_) => const _UmengDetailPage(),
                                    ),
                                  );
                                },
                                child: const Text('打开统计子页'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DemoSection(
                        title: '三、U-APM 异常测试',
                        children: [
                          const _Description(
                            'U-APM 提供类似 Bugly 的异常监控能力。'
                            '下方分别验证主动捕获、Flutter 框架和异步异常。'
                            '这些按钮用于制造测试异常，不故意终止应用进程。',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton(
                                style: buttonStyle,
                                onPressed: canReport
                                    ? () => _runAction(
                                          service.reportCaughtException,
                                        )
                                    : null,
                                child: const Text('捕获异常上报'),
                              ),
                              OutlinedButton(
                                style: outlineStyle,
                                onPressed: canReport
                                    ? service.triggerFrameworkError
                                    : null,
                                child: const Text('Flutter 框架异常'),
                              ),
                              OutlinedButton(
                                style: outlineStyle,
                                onPressed: canReport
                                    ? service.triggerAsyncError
                                    : null,
                                child: const Text('异步异常'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const _Description(
                            '调试器可能在测试异常处暂停，继续运行后检查日志。'
                            '控制台中的测试异常输出属于预期现象。',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DemoSection(
                        title: '四、平台配置',
                        children: [
                          _AppKey(
                              label: 'Android AppKey',
                              value: UmengDemoConfig.androidAppKey),
                          _AppKey(
                              label: 'iOS AppKey',
                              value: UmengDemoConfig.iosAppKey),
                          _AppKey(
                              label: '鸿蒙 AppKey',
                              value: UmengDemoConfig.harmonyAppKey),
                          Text('渠道：${UmengDemoConfig.channel}'),
                          const SizedBox(height: 12),
                          const _Description(
                            '鸿蒙 AppKey 已配置；当前鸿蒙宿主与插件尚未适配，'
                            '不能据此认定鸿蒙已完成接入。Web 和桌面端仅展示此页，不执行原生 SDK 上报。',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLogs(context, outlineStyle),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatus(BuildContext context) {
    final service = widget.service;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: colors.onPrimaryContainer,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${service.platformLabel} · ${service.status}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              service.isSupported
                  ? '日志中的调用完成表示交给 SDK 本地队列，不等于服务端已收到。'
                      '离线重试按各 SDK 策略处理，Dart 异常不保证跨进程保留，'
                      '最终以友盟后台数据为准。'
                  : '当前平台不支持此原生 SDK，不会显示上报成功。'
                      '请在已配置的 Android 或 iOS 真机上验证。',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogs(BuildContext context, ButtonStyle outlineStyle) {
    final service = widget.service;
    final colors = Theme.of(context).colorScheme;
    return _DemoSection(
      title: '五、调用日志',
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('共 ${service.logs.length} 条'),
            OutlinedButton(
              style: outlineStyle,
              onPressed: () {
                setState(() {});
              },
              child: const Text('重新加载'),
            ),
            OutlinedButton(
              style: outlineStyle,
              onPressed: service.logs.isEmpty ? null : service.clearLogs,
              child: const Text('清空日志'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _Description('重新加载仅刷新本机日志，不查询服务端，也不重复发送事件。'),
        const SizedBox(height: 16),
        if (service.logs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('暂无调用记录', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('同意并初始化后，操作上方演示按钮即可查看本机调用记录。'),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: outlineStyle,
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('重新加载日志'),
                ),
              ],
            ),
          )
        else
          for (final log in service.logs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: log.isError ? colors.errorContainer : colors.surface,
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  '${_formatTime(log.time)}  ${log.message}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: log.isError
                            ? colors.onErrorContainer
                            : colors.onSurface,
                      ),
                ),
              ),
            ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:'
        '${twoDigits(time.second)}';
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final secondary = Color.lerp(colors.onSurface, colors.surface, 0.18)!;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: secondary,
            height: 1.6,
          ),
    );
  }
}

class _AppKey extends StatelessWidget {
  const _AppKey({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SelectableText('$label\n$value'),
    );
  }
}

class _UmengDetailPage extends StatelessWidget {
  const _UmengDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.textScalerOf(context).scale(kToolbarHeight),
        title: const Text('页面统计子页'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: _DemoSection(
                title: '页面访问统计演示',
                children: [
                  const _Description(
                    '当前路由：/umeng/detail。进入与离开由宿主路由观察器记录，'
                    '用于验证页面访问及停留统计。请先在上一页同意并初始化 SDK。'
                    '返回后可查看调用日志，统计结果以友盟后台为准。',
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('返回演示主页'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
