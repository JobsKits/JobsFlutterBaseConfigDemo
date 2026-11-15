import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

class AuthStylesDemo extends StatefulWidget {
  const AuthStylesDemo({super.key});
  @override
  State<AuthStylesDemo> createState() => _AuthStylesState();
}

class _AuthStylesState extends State<AuthStylesDemo> {
  final account = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final phone = TextEditingController();
  final code = TextEditingController();
  int mode = 0;
  bool sliding = false;
  bool busy = false;
  String? error;
  String? user;
  void switchMode(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      mode = value;
      error = null;
    });
  }

  Future<void> submit() async {
    if (account.text.trim().isEmpty ||
        password.text.isEmpty ||
        (mode != 0 && (phone.text.isEmpty || code.text != '123456'))) {
      setState(() => error = uiTr(context, '必填') + ' · 123456');
      return;
    }
    if (mode != 0 && password.text != confirm.text) {
      setState(() => error = uiTr(context, '密码不匹配'));
      return;
    }
    setState(() => busy = true);
    await UiDemoStore.write('auth-event', {
      'account': account.text.trim(),
      'mode': mode,
      'demo': true,
    });
    if (!mounted) return;
    setState(() {
      busy = false;
      user = mode == 2 ? null : account.text.trim();
      error = null;
    });
    password.clear();
    confirm.clear();
    uiNotice(context, '本地演示');
  }

  Widget field(
    TextEditingController controller,
    String title, {
    bool secret = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: controller,
      obscureText: secret,
      decoration: InputDecoration(labelText: uiTr(context, title)),
    ),
  );
  Widget formContent() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        uiTr(
          context,
          mode == 0
              ? '登录'
              : mode == 1
              ? '注册'
              : '重置密码',
        ),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      field(account, '账号'),
      field(password, '密码', secret: true),
      if (mode != 0) ...[
        field(confirm, '确认密码', secret: true),
        field(phone, '手机号'),
        field(code, '验证码'),
        const Text('123456'),
      ],
      if (mode == 0)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => switchMode(2),
            child: Text(uiTr(context, '忘记密码')),
          ),
        ),
      if (error != null)
        Text(
          error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: busy ? null : submit,
          child: Text(
            uiTr(
              context,
              busy
                  ? '运行中'
                  : mode == 0
                  ? '登录'
                  : mode == 1
                  ? '注册'
                  : '重置密码',
            ),
          ),
        ),
      ),
      if (mode == 2)
        TextButton(
          onPressed: () => switchMode(0),
          child: Text(uiTr(context, '登录')),
        ),
    ],
  );
  Widget morph() => AnimatedSize(
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeInOut,
    child: Stack(
      children: [
        AnimatedPadding(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          padding: EdgeInsets.fromLTRB(
            mode == 0 ? 20 : 72,
            24,
            mode == 0 ? 72 : 20,
            24,
          ),
          child: formContent(),
        ),
        Positioned.fill(
          child: Align(
            alignment: mode == 0 ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () => switchMode(mode == 0 ? 1 : 0),
                child: RotatedBox(
                  quarterTurns: mode == 0 ? 1 : 3,
                  child: Text(
                    uiTr(context, mode == 0 ? '注册' : '登录'),
                    softWrap: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  @override
  void dispose() {
    for (final c in [account, password, confirm, phone, code]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '双风格认证'))),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(uiTr(context, '变形面板')),
                  selected: !sliding,
                  onSelected: (_) => setState(() => sliding = false),
                ),
                ChoiceChip(
                  label: Text(uiTr(context, '滑动卡片')),
                  selected: sliding,
                  onSelected: (_) => setState(() => sliding = true),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (user != null) ...[
              CircleAvatar(radius: 32, child: Text(user!.substring(0, 1))),
              Text(user!),
              TextButton(
                onPressed: () => setState(() => user = null),
                child: Text(uiTr(context, '重新锁定')),
              ),
            ] else
              TweenAnimationBuilder<double>(
                tween: Tween(begin: .01, end: 1),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutBack,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: sliding
                      ? AnimatedSwitcher(
                          duration: const Duration(seconds: 2),
                          switchInCurve: Curves.elasticOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) =>
                              SlideTransition(
                                position: Tween<Offset>(
                                  begin: child.key == ValueKey(mode)
                                      ? const Offset(1.2, 0)
                                      : const Offset(-1.2, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                          child: Padding(
                            key: ValueKey(mode),
                            padding: const EdgeInsets.all(24),
                            child: formContent(),
                          ),
                        )
                      : morph(),
                ),
              ),
            const SizedBox(height: 16),
            Text(uiTr(context, '本地演示')),
          ],
        ),
      ),
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: AuthStylesDemo(), title: '双风格认证'));
