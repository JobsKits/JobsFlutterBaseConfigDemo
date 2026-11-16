# [**Flutter**](https://flutter.dev/) iOS 帧时间错误排查

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、原始现场与版本](#environment)
- [二、已证实的引擎行为](#verified-mechanism)
- [三、当前版本是否有可用配置开关](#supported-settings)
- [四、隔离 A/B 尝试与实际结果](#ab-results)
  - [4.1、正式首页限定触控补充](#jobs-toc-heading-6)
- [五、下一步与验收门槛](#next-validation)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

2026-11-15 排查。用户提供的三条 `Reported frame time is older than the last one; clamping` 来自引擎，发生在应用已成功启动之后。已查明日志语义及当前引擎可能触发该日志的路径；本轮最小基线未稳定复现，不能宣布问题已修复，也不能默认启用未经真实 A/B 验证的规避代码。业务源码及 `lib/main.dart` 未因本排查改变。

## 一、<span id="environment">原始现场与版本</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 项目 | 现场记录 |
| --- | --- |
| 运行模式 | debug，Impeller / Metal，`lib/main.dart` |
| 工程 FVM 选择 | `stable`，实际 Flutter 3.50.0 / Dart 3.14.0 |
| Framework | `ab2912035e160d9cad6306df307576da6128ebdb` |
| Engine | `371f77202a73e8dff57a8b3bff75bca55c090aee` |
| 目标 | iPhone 18 Pro 模拟器，iOS 27.2 |
| 目标 UDID | `88AD269D-2D0B-4A34-A49D-B121B74527DC` |
| 宿主 | [**MacOS**](https://www.apple.com/macos/) 27.2.1，arm64 |
| 应用配置 | `ios/Runner/Info.plist` 中 `CADisableMinimumFrameDurationOnPhone = true` |
| 原运行结果 | Xcode 构建成功、应用启动成功、调试连接成功；随后出现下列三条错误日志 |

```text
[ERROR:flutter/lib/ui/window/platform_configuration.cc(475)] Reported frame time is older than the last one; clamping. 104700103622 < 104700105728 ~= 2106
[ERROR:flutter/lib/ui/window/platform_configuration.cc(475)] Reported frame time is older than the last one; clamping. 105015453622 < 105015455205 ~= 1583
[ERROR:flutter/lib/ui/window/platform_configuration.cc(475)] Reported frame time is older than the last one; clamping. 105063803622 < 105063804527 ~= 905
```

三次倒退幅度分别为 2.106 ms、1.583 ms、0.905 ms。此处的数字是单调时钟帧时间戳，不能将它解释为业务计时器时间或系统日期倒退。原日志没有同时提供具体触控动作、帧追踪或 Dart 异常堆栈，因此尚不能把某个首页控件定为根因。

## 二、<span id="verified-mechanism">已证实的引擎行为</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 当前版本的 [`PlatformConfiguration::BeginFrame`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/lib/ui/window/platform_configuration.cc#L455-L495) 在向 Dart 调用帧回调之前，先比较本次时间戳与上次时间戳；遇到倒退则记录 ERROR，并把本次值夹紧到上次值。该日志已在引擎层发出，`FlutterError.onError`、Dart 日志过滤或调整业务时钟都不能修复上游输入。
- 当前 iOS 引擎的 [`VsyncWaiterIOS::AwaitVSync`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/shell/platform/darwin/ios/framework/Source/vsync_waiter_ios.mm#L70-L95) 在 DisplayLink 已暂停且正分发 UIKit 指针事件时，可以立即使用 `fml::TimePoint::Now()` 发出首帧；后续帧则来自 DisplayLink 的时间戳换算。
- [`FlutterEngine::dispatchPointerDataPacket`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterEngine.mm#L432-L445) 在分发指针包前后设置 `dispatching_event_`。官方 [PR #191444](https://github.com/flutter/flutter/pull/191444) 说明该版本将 UIKit 指针处理到帧请求的路径改为同步，以减少一帧触控延迟；本机当前源码已包含此变更。
- [`VSyncClient`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/shell/platform/darwin/ios/framework/Source/VSyncClient.swift) 使用 `CADisplayLink.timestamp` 与 `targetTimestamp`；iOS 显示链路与 C++ 单调时钟之间还存在时钟基准换算。

由这些源码推断：同步合成首帧的时间晚于同周期后继 DisplayLink 时间戳，是当前值得验证的触发机制。**这仍是待复现验证的假设，并未凭三条日志证明其为用户现场的唯一根因。**

官方 [Issue #106277](https://github.com/flutter/flutter/issues/106277) 记录过高刷新率设备上的时间倒退及动画断言，引擎夹紧分支也引用该 Issue；但原 Issue 最初针对另一设备／平台，不能据此认定本机 iOS 模拟器有完全相同的根因。关闭 ProMotion、切换渲染后端或降级 SDK 均未在本轮获得对照证据，未修改这些配置。

## 三、<span id="supported-settings">当前版本是否有可用配置开关</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

**核查结论：Flutter 3.50.0 的标准 iOS 宿主没有受支持的配置入口关闭上述同步首帧路径。不能通过添加旧版线程开关来修复。**

| 候选配置 | 当前源码证据与适用性 |
| --- | --- |
| `FLTEnableMergedPlatformUIThread=false` | [`FlutterDartProject.mm:228–233`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterDartProject.mm#L228-L233) 对 false 执行 `FML_CHECK`，会终止引擎初始化，不能使用。 |
| `--disable-merged-platform-ui-thread`、`--merged-platform-ui-thread=disabled` | iOS 调用 `SettingsFromCommandLine(command_line, true)`，其中第二参数强制合并；[`switches.cc:528–559`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/shell/common/switches.cc#L528-L559) 对禁用参数执行检查并终止，不是可用回退。 |
| `--merged-platform-ui-thread=mergeAfterLaunch` | [`FlutterDartProject.mm:68–72`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterDartProject.mm#L68-L72) 同样明确拒绝。 |
| `FLTEnableIOSEmbedderAPI=true` | 当前 [`FlutterEngine.mm:257–262`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterEngine.mm#L257-L262) 只取得 Embedder API 函数表；[`PlatformViewIOS::CreateVSyncWaiter`](https://github.com/flutter/flutter/blob/ab2912035e160d9cad6306df307576da6128ebdb/engine/src/flutter/shell/platform/darwin/ios/platform_view_ios.mm#L179-L181) 仍无条件创建 `VsyncWaiterIOS`，没有切换到另一帧时序实现。 |
| `CADisableMinimumFrameDurationOnPhone=false` | 影响 ProMotion 的刷新率请求，不关闭 `AwaitVSync` 的同步短路逻辑；本轮没有证明降刷新率能消除现场错误，未改变原设置。 |
| 切换 Impeller / Skia | 目标分支位于 iOS 的帧调度层，与光栅后端独立；不能仅换后端就宣称该路径被移除。 |

官方 [Flutter 3.38 发布说明](https://docs.flutter.dev/release/release-notes/release-notes-3.38.0) 已登记移除 Android / iOS 的线程合并退出选项（PR #174408）。因此针对更早版本的 `Info.plist` 关闭合并建议不适用于本工程的 3.50.0。

PR #191444 的同步指针派发只在 UI / Platform 任务运行于同一线程且当前没有 Dart isolate 重入时直接执行，否则投递任务；当前 iOS 已要求合并线程，普通 UIKit 触控会进入其同步路径。不能把支持旧式双线程宿主的其它平台当作当前 iOS 可选配置。

## 四、<span id="ab-results">隔离 A/B 尝试与实际结果</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

实验场景为只有一个计数按钮的最小 Flutter 页面。A 保持原始帧请求；B 仅在 iOS 指针处理调用栈内，将普通 `scheduleFrame()` 的请求延后一轮事件循环，尝试避开引擎同步首帧路径。实验不改引擎、不屏蔽日志、不关闭动画、不修改 ProMotion，也没有接入主入口或第二引擎入口。

| 核验项 | A：原始请求 | B：实验性延后 |
| --- | --- | --- |
| Debug iOS Simulator 编译 | 成功，86.5 秒 | 成功，36.0 秒 |
| 安装到用户同一模拟器 | 是，使用隔离 Bundle ID `com.jobs.frameprobe.baseline` | 未安装 |
| 实际页面 | 已看到最小页面，确认一次按钮计数 `Tap 0 → Tap 1` | 未启动 |
| 有效输入计数 | 至少一次；后续批量输入工具失败，无法可靠计数 | 无 |
| 捕获的 clamping 日志 | 0 条 | 无运行日志，不能写成 0 条 |
| 有效 A/B 结论 | 基线未复现 | 没有足够证据评价 |

原始基线日志保存在 [2026-11-15-基线原始日志.txt](./帧时间验证/2026-11-15-基线原始日志.txt)。使用 `.txt` 保证证据不被工程通用 `.log` 忽略规则排除。它还包含模拟器系统可访问性组件的重复类提示，与本次目标日志分开处理；本轮没有改动系统库。

批量点击工具返回 `input_required did not complete within 10 MRTR rounds`；随后会话失去变量，不能将预定的点击次数当作实际完成次数。单元测试也未形成可靠证明：测试中按下阶段先排帧、抬起阶段再检查，导致延后分支的预期不成立；没有把这项失败测试留在主工程或当作通过项。

为便于后续复现，候选方案只以不可编译的文本附件保留：[未启用的帧请求延后实验](./帧时间验证/未启用的帧请求延后实验.dart.txt)、[最小复现入口](./帧时间验证/最小复现入口.dart.txt)。两份附件均是实验材料，**不是已验收实现**；后续重建时须恢复正确相对位置和包导入，并先修正验证方式。实验业务 `.dart` 和测试文件已撤除，`lib/main.dart` 未改变。

### <span id="jobs-toc-heading-6" data-jobs-toc="v2">4.1、正式首页限定触控补充 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

2026-11-16正式主应用最终包增加实际原生触控及原进程stdout／stderr记录，没有加入生产探针、帧调度实验或日志过滤。浮钟长按拖动／短按世界页／格式切换／返回测试1项、0失败、14.506秒；默认刷新样式的长拉持有／释放两次各1项、0失败，15.520秒与42.226秒。刷新自动归位断言对象为首个Demo行，录像另实看收起组头持有时随列表下移、松手归位。它们只覆盖这些明确动作，未遍历静置首触、搜索、侧栏、前后台及其它完整组合。

三份原始进程日志各自目标错误计数为0，已保留[调试服务URI脱敏副本](./帧时间验证/2026-11-16-主应用限定触控日志.txt)。原始日志和触控录像留在本机任务产物`adaptive-clock/flutter-physical/`，具体动作与测试边界见[当日验收记录](./验收记录/2026-11-16.json)。**有限场景没有复现，不构成修复，也没有形成有效A／B结论。** 用户随后清理了旧模拟器并明确要求重建，现有共享iPhone18Pro／iOS27.2已重新建立；设备变化不能倒推为错误根因或解决方案。

## 五、<span id="next-validation">下一步与验收门槛</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 先在隔离应用中记录真实原生触控，覆盖静置后首次点击、短促连续点击、侧栏开合、搜索页面进入／退出及前后台切换；保留原始引擎日志及每一段的有效动作数。能够可靠复现 A 后，再进行 B。
- 对照需保持 SDK、设备、刷新配置、渲染后端与动作序列一致。B 若消除错误，仍须复测 A 再现、B 消失，并检查交互延迟、帧请求合并、生命周期、页面切换与二引擎隔离。
- 如只在完整首页复现，则用具体操作和追踪缩小触发范围，不能用最小页暂未报错证明首页已修复。
- 若最终证实为当前引擎缺陷，整理可运行最小复现和时间线，再依据上游已合入修复选择 SDK；本轮不提交 Issue、不升级／降级或修改第三方源码。

实验清理时，隔离测试应用已卸载，已重新展示原应用并核对首页仍为 281 项；原应用进程未被覆盖安装。实验生成配置已恢复为 `lib/main.dart`，未改变业务入口。主流程随后重新构建主应用，主应用验收以对应的正式目标构建与运行记录为准，不能使用最小测试页的编译结果代替。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
