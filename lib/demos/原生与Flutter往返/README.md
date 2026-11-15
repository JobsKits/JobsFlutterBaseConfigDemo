# 原生与 Flutter 双引擎往返

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、操作流程](#flow)
- [二、源码与接入](#files)
- [三、验证范围](#checks)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

此 Demo 对齐 Swift 的 `FlutterDemoVC`：真实原生宿主打开一个独立 Flutter 引擎，传入初值，再接收 Flutter 回传内容。当前平台实现为 iOS；Android、Web 与桌面显示明确条件并禁用原生入口，不返回模拟成功。

## 一、<span id="flow">操作流程</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 在父 Flutter 页面填写初值，点击“打开原生宿主”。
- 原生 `UIViewController` 显示 `requestId` 与初值；点击原生按钮，创建第二个 `FlutterEngine`，执行保留入口 `jobsNativeBridgeEntry`。
- 第二个引擎通过独立 `MethodChannel` 的 `load` 获取参数、父页面语言与主题；编辑内容后可先验证 SharedPreferences 插件读写，再点击“回传并关闭Flutter”。
- 原生页面显示收到的 JSON。关闭原生宿主后，最初的 Flutter 页面收到最终回传对象。第二引擎取消也会返回取消状态；关闭后销毁其引擎上下文。

## 二、<span id="files">源码与接入</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 文件 | 职责 |
| --- | --- |
| [原生与Flutter往返.dart](./原生与Flutter往返.dart) | 目录可达页面与独立 main 入口 |
| [独立引擎页面.dart](./独立引擎页面.dart) | 参数握手、回传、取消与第二引擎插件验证 |
| [JobsFlutterInterop.swift](../../../JobsByPubs/JobsPlatformLabByPub/ios/Classes/JobsFlutterInterop.swift) | 原生宿主、独立引擎及回传生命周期 |
| [AppDelegate.swift](../../../ios/Runner/AppDelegate.swift) | 为第二引擎注册生成的完整插件集合 |

独立预览：

```shell
flutter run -t lib/demos/原生与Flutter往返/原生与Flutter往返.dart
```

主 App 与独立入口均保留 `jobsNativeBridgeEntry`，防止 release 树摇移除。复用原生插件时，宿主须设置 `JobsPlatformLabPlugin.registerSecondaryEngine`，由 `GeneratedPluginRegistrant.register(with:)` 为每个新引擎注册插件。此通道传递用户输入，不主动访问外网或调用业务 API。

## 三、<span id="checks">验证范围</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

[通道交互测试](../../../test/native_interop_test.dart)验证父页面本地化载荷、独立入口参数与回传、插件读写和不支持平台条件；测试替身不代表原生双引擎已经实触。原生 Swift 已通过语法及 SDK 类型检查，宿主完整编译与设备往返应单独记录。启动期缺失 handler 有短暂重试和失败退出入口，原生会校验非取消回传的请求标识；回复通道后才关闭并销毁引擎。

<a id="🔚" href="#前言">返回首页</a>
