# <span id="前言">Jobs 原生平台实验室</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

[**Flutter**](https://flutter.dev/) 与原生 OC／[**Swift**](https://www.swift.org/) Demo 共用语义的系统能力适配层。自有 [**Dart**](https://dart.dev/)／Swift／[**Kotlin**](https://kotlinlang.org/) 代码与第三方引擎分开维护，应用宿主通过公开 MethodChannel 调用。

## 一、能力与入口 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 能力 | 公开方法 / 事件 | 实际实现 |
| --- | --- | --- |
| AR 空间 | `ar.command`、`ar`事件 | iOS `ARSCNView`，预览、世界追踪、水平／垂直平面、射线放置、缩放、旋转、清空；真 AR 需支持的硬件 |
| BLE | `ble.*`、`ble`事件 | CoreBluetooth／Android BluetoothGatt，扫描、过滤、连接、服务特征、Read／Write／Notify、描述符、RSSI、MTU及重连 |
| BLE 协议工具 | `JobsBleCommandQueue`、`JobsBleCodec`、`JobsBleTrace` | 串行队列、取消排队、超时重试、MTU拆包、示例长度帧／CRC16、录制与回放；显式 Mock 设备单独标注 |
| 传感器 | `motion.start/stop`、`motion`事件 | CoreMotion／Android SensorManager，姿态、加速度、陀螺仪、磁力计 |
| 录音管理 | `audio.*`、`audio`事件 | 原生 AAC/M4A 文件、短按住／长录音、暂停／继续、播放、删除；Android 前台麦克风服务支持后台持续录制 |
| 截图与录屏保护 | `screen.*`、`screen`事件 | iOS 截图通知与录屏时遮罩；Android 截图回调及 FLAG_SECURE。iOS没有阻止系统截图的公开 API |
| 系统操作 | `clipboard.*`、`url.open`、`device.risk` | 系统剪贴板、受限外部 URL scheme、安全信号只读检测；风险信号不是完整安全鉴定 |
| 动态图标 | `icon.status/set` | 读取宿主真实备用图标并切换；Android launcher aliases；未知名称拒绝 |
| 多窗口 | `scenes.list/open` | iOS UIScene、Android独立文档任务；宿主和设备需支持多窗口 |
| 桌面组件 | `widget.write/read` | iOS App Group＋WidgetKit timeline；Android AppWidgetProvider＋本地偏好更新广播 |
| 视频 | `video.record/import/list/saveToPhotos` | 系统相机及自有长按录制，摄像头连续预览、松手结束／上滑取消、录后浮窗预览与相册保存；导入仅接收本App沙盒源文件或视频字节并验证视频轨 |
| 视频滤镜 | `video.import(filter: ...)` | iOS录后以Core Image＋AVVideoComposition真实渲染新MP4并保留音轨：原片／黑白／高反差／怀旧／鲜明／胶片／褪色；Android仅原片，拒绝伪造滤镜成功 |
| RTMP 推流 | `rtmp.start/stop`、`video`事件 | iOS HaishinKit 2.0.9、Android RootEncoder 2.8.1，相机 H.264＋麦克风 AAC，真实服务器确认后才返回成功 |
| PDF | `pdf.open/page/close` | iOS PDFKit、Android PdfRenderer，密码打开（iOS）、页数、分页栅格化与缩放 |
| 播放器 | `player.command`、`player`事件 | iOS AVPlayerLayer＋AVPlayerViewController＋系统PiP，Android VideoView＋原生全屏／PiP Activity；iOS真实AVPlayerItem流量与码率，Android显式标记为App作用域流量 |
| 动态运行时 | `runtime.inspect/define/patch/rollback` | iOS Objective-C真实动态类、方法、属性元数据、IMP替换与恢复；限定本Lab创建的JobsLabRuntime类。Android真实Class方法／字段检查 |
| Unity | `unity.status/open/message/close` | iOS 真机 `UnityFramework` 动态嵌入及消息，Android已嵌入 UnityPlayer 的公开消息接口 |

业务页面在宿主的中文功能目录，注册表为 `../../lib/demo_hub/platform_catalog.dart`；主 App 和每个文件的 `main()` 使用同一页面。

## 二、接入与调用 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

```yaml
dependencies:
  jobs_platform_lab:
    path: ./JobsByPubs/JobsPlatformLabByPub
```

```dart
final capabilities = await JobsPlatformLab.invoke<Map>('capabilities');
final subscription = JobsPlatformLab.events('motion').listen(print);
await JobsPlatformLab.invoke('motion.start', {'kind': 'device'});
await JobsPlatformLab.invoke('motion.stop');
await subscription.cancel();
```

方法通道 `jobs_platform_lab/methods`，事件通道 `jobs_platform_lab/events`，AR PlatformView 类型 `jobs_platform_lab/ar`。事件结构为 `topic / time / data`。Web／桌面不会返回伪造的硬件成功数据；调用方应显示不支持并提供返回／重新加载。

宿主 iOS 权限声明包括相机、麦克风、蓝牙、体感和相册写入。权限仅在用户发起对应动作时请求；录音后台需要宿主 `UIBackgroundModes` 包含 `audio`。Android manifest 的能力权限和录音服务由本包合并，拒绝权限会明确返回错误。

RTMP 输入为完整 `rtmp(s)://host/app/stream-key`，需要用户可用的真实服务地址。不要把推流密钥写进源码、README或共享日志。本包保留的 `video.streamStart` 是单独的 iOS WebSocket-JPEG 帧演示，不代替 RTMP，也不声称包含音频。

长按视频场景位于宿主 `lib/demos/视频录制直播/长按视频录制.dart`，沿用`platform-video`入口，不增加重复目录条目。录前选择滤镜，松手后`video.import`才渲染成片；返回真实文件的`name/path/duration/bytes/filter`后预览及保存。`player.command(load,path)`仅接受本App沙盒视频，可避免通过通道复制整段视频；`video.discard(path)`仅清理临时／cache录制，已导入文件用`video.delete(name)`清理。

## 三、Widget 与 Unity 宿主资源 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

iOS Widget extension 源模板在 `./host_integration/JobsFlutterWidget.swift`。Runner与extension的 `JobsWidgetAppGroup` 和 entitlement 使用相同 App Group，默认 `group.com.example.jobsFlutterBaseConfigDemo`；共享键 `jobs.widget.text`、`jobs.widget.updated`，timeline kind 为 `JobsFlutterLabWidget`。App Group与实际签名团队的配置由宿主维护。Android provider和布局随插件合并，明暗资源跟随系统。

Unity真机引擎实体位于 `./ios/Frameworks/UnityFramework.framework`，来自原生参考工程完整导出并用当前 Xcode 重新构建，匹配 Data 位于 framework 内。它仅有 iphoneos arm64，保持原生参考工程的真机条件语义，禁止伪造／混用模拟器切片。宿主只在 `PLATFORM_NAME=iphoneos` 时嵌入该 framework，并在签名开启时按宿主签名身份签名整个 bundle；无需把开发机源码绝对路径固化为运行依赖。动态加载设置主 Mach-O header、Data Bundle ID，提供 UnitySendMessage 和返回 Flutter 窗口控件。

Android UnityPlayer 适配需要相应 Unity Android 导出库。当前参考工程只提供 iOS导出；禁止把 iOS原生二进制当Android库或用占位页面声称引擎运行。

## 四、依赖与验证 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

HaishinKit依据原生锁定版本 `2.0.9`，依赖 Logboard；RootEncoder依据官方 `2.8.1` API，来自官方项目的 JitPack坐标。第三方源码保持上游所有权，不为消除编译警告修改供应商文件。

Android宿主的依赖解析仓库需包含 `https://jitpack.io`，供 `com.github.pedroSG94.RootEncoder:library:2.8.1` 及同组模块解析。播放器Activity与PiP声明随本包Manifest合并。UIKit分享只展示系统目标选择器；是否实际发出由用户后续操作决定。

- [HaishinKit](https://github.com/HaishinKit/HaishinKit.swift/tree/2.0.9)：BSD许可，Pod锁定版本。
- [RootEncoder](https://github.com/pedroSG94/RootEncoder/tree/2.8.1)：Apache-2.0，Gradle固定坐标。
- [Apple ARKit](https://developer.apple.com/documentation/arkit)、[CoreBluetooth](https://developer.apple.com/documentation/corebluetooth)、[WidgetKit](https://developer.apple.com/documentation/widgetkit)：系统框架。

本工程的通道／协议／页面测试位于 `../../test/platform_lab_test.dart`。硬件调用的测试替身不能代替蓝牙外设、真实AR、麦克风、RTMP服务器及Unity真机运行验收。编译、测试与设备观察分别记录在宿主验证证据中。

<a id="🔚" href="#前言">返回首页</a>
