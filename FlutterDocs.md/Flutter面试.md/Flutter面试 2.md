# Flutter学习回顾

[toc]

## 一、场景辅助理解线程和同/异步的关系【级别：初级】

> <font color=red size=5>`async/await` 不等于多线程</font>

### 场景1、单线程 + 同步（最简单）

* 洗衣服（10分钟）
* 等洗完
* 再做饭

### 场景2、单线程 + 异步（关键点）

* 洗衣机启动（10分钟）
* 不用等 → 去做饭
* 洗完了通知你

### 场景3、多线程 + 同步

* 你（主线程）
  *  开一个人去洗衣服（子线程）
  * 然后你站着等他洗完（join） 
  * 再去做饭

### 场景4、多线程 + 异步

* 你开一个人洗衣服
* 你不等他 → 去做饭
* 洗完了他通知你

## 二、理解isolate【级别：初级】

> 让别人帮我做

* 普通 `Future` 大多数情况下还是在当前 Isolate 的事件循环中执行；真正意义上的并发隔离，要看 `Isolate`

* Flutter UI 代码默认主要跑在一个 Dart isolate 里

  * `build`

  * 状态更新

  * 事件响应

* 特点

  * 每个 isolate 有自己的内存
  * 不能直接共享对象
  * 通信靠消息传递
  
* Flutter 引擎内部本来就不是单线程。常见会有这些角色：
  
  * **UI thread**：跑 Dart 代码、处理 widget build 等
  * **Raster thread**：做栅格化、把 layer 画到屏幕
  * **Platform thread**：和 iOS/Android 平台交互
  * 还有 **IO thread** 等后台线程
  
* 为什么大家总说 Flutter **单线程**
  
  * 因为日常写业务代码时，最常接触的是：
    - 一个主 isolate
    - 一个事件循环
    - 同步代码一旦阻塞，就会卡 UI
  
* 为什么网络请求不需要 isolate
  
  * 真实流程是：Dart 发请求 → 交给操作系统 → Dart 线程空闲 → 等通知回来
  * 耗时发生在操作系统 / 网络 / 内核，不在 Dart 执行线程
  * 等待为主，不占 CPU（**如果CPU 密集，那么必须 isolate**）
  
* 执行全景图
  
  ```
  ┌───────────────────────────────┐
  │           Isolate             │   ← 你写的 Dart 代码基本都在这里跑
  │                               │
  │   ┌───────────────┐           │
  │   │  Call Stack   │ ← 当前正在执行的同步代码
  │   └───────────────┘           │
  │                               │
  │   ┌───────────────┐           │
  │   │ Microtask Queue│ ← ❤️ 高优先级（Future.then / scheduleMicrotask）
  │   └───────────────┘           │
  │                               │
  │   ┌───────────────┐           │
  │   │ Event Queue    │ ← 普通异步（Timer / IO / Future.delayed）
  │   └───────────────┘           │
  └───────────────────────────────┘
  ```
  
* 运行规则
  
  * 先跑同步代码（Call Stack）
  * 同步执行完 → 清空 **microtask** 队列
  * 再从 event queue 取一个执行
  
  ```dart
  void main() {
    print('1');
    Future(() => print('2'));
    Future.microtask(() => print('3'));
    print('4');
  }
  
  /// 输出
  1
  4
  3
  2
  ```
  
* 适用场景解析
  
  * ✅该用 isolate（一般是 **纯 CPU 密集型任务**）
    * 大量 JSON 解析
    * 图片编解码/处理
    * 大循环计算
    * 加密/压缩
    * 本地大数据转换
  * ❌不该用 isolate（因为这些很多本来就是异步 IO，未必需要新 isolate）
    * 普通网络请求
    * 数据库简单查询
    * UI 操作
    * 依赖主线程平台调用的逻辑
  
* 如何新开isolate
  
  * **`Isolate.run`**一次性任务，最常用，最简单
  
    ```dart
    import 'dart:isolate';
    
    Future<int> heavyWork() async {
      return await Isolate.run(() {
        var sum = 0;
        for (var i = 0; i < 100000000; i++) {
          sum += i;
        }
        return sum;
      });
    }
    ```
    
  * **`Isolate.spawn`**适合你想要一个**常驻后台** worker，能多次收发消息**（更底层）**
  
    ```dart
    import 'dart:isolate';
    /// 这个 demo 能跑，但有几个现实问题：
    /// 不会退出：因为两个 ReceivePort 都没关
    /// 没有错误处理
    /// 主 isolate 收到多个消息时，全混在一个口子里
    void worker(SendPort mainSendPort) {
      final receivePort = ReceivePort();
      // 把 worker 自己的 SendPort 发回主 isolate
      /// 两步握手@第二步：worker -> 主
      mainSendPort.send(receivePort.sendPort);
    
      receivePort.listen((message) {
        if (message is int) {
          final result = message * 2;
          mainSendPort.send(result);
        }
      });
    }
    
    Future<void> main() async {
      final mainReceivePort = ReceivePort();
      /// spawn 不是“返回计算结果”,它只是启动 isolate
      /// 真正通信靠 ReceivePort / SendPort
      /// 两步握手@第一步：主 -> worker
      await Isolate.spawn(worker, mainReceivePort.sendPort);
    
      SendPort? workerSendPort;
    
      mainReceivePort.listen((message) {
        if (message is SendPort) {
          workerSendPort = message;
          workerSendPort!.send(21);
        } else {
          print('来自 worker 的结果: $message');
        }
      });
    }
    ```
  
  * `compute` 主要是 **Flutter 层的便捷封装**，本质上可以把它先理解成：**帮你简化了一次性 isolate 任务**
  
    ```dart
    import 'package:flutter/foundation.dart';
    
    int parseData(int value) {
      var sum = 0;
      for (var i = 0; i < value; i++) {
        sum += i;
      }
      return sum;
    }
    
    Future<void> loadData() async {
      final result = await compute(parseData, 100000000);
      print(result);
    }
    ```
  
## 三、理解Future【级别：初级】

> **让事情晚点做，不要卡我**

* Future 本质就是：一个将来会完成的结果 + 事件循环调度

* Future依赖的是：当前 isolate 的 **event loop**、**microtask queue** / **event queue**

* Future 的价值在于：

  * 不阻塞 UI（关键）网络 IO 不会卡住 UI
  * 管理异步流程
  * 事件驱动编程

* **microtask** 

  * 滥用会卡 UI
  * 需要立即执行，但要等当前同步代码结束

* **microtask** vs **event**

  | 类型      | 优先级 | 常见来源              |
  | --------- | ------ | --------------------- |
  | microtask | 高     | then / await          |
  | event     | 低     | Timer / IO / Future() |

## 四、`const` 在 Flutter 里有什么用？【级别：初级】

* 编译期常量
* 减少重复创建
* 有利于性能
* widget 复用判断

## 五、`Expanded` 和 `Flexible` 区别？【级别：初级】

- 剩余空间分配
- 紧约束 / 松约束

## 六、`ListView.builder` 为什么比直接 children 更合适长列表？【级别：初级】

- 懒加载
- 按需构建
- 降低内存占用

## 七、状态管理【级别：初级】

- `setState`
- Provider
- Bloc
- Riverpod
- GetX

## 八、Flutter 和 Dart 的关系？【级别：中级】

* Flutter 是 UI 框架
* Dart 是语言
* Flutter = Engine + Framework
* Dart 负责业务和运行时逻辑

## 五、原生调用【级别：中高级】

> channel 名必须一致
>
> method 名就是路由
>
> 参数只能是基础类型（Map / List / String / int / bool），自定义对象（要转 JSON）

### 1、Flutter → 原生（请求 → 返回结果）

> 支付
>
> 定位
>
> 相机 / 相册
>
> 打开原生页面
>
> 获取设备信息
>
> 蓝牙
>
> 调第三方的SDK

* Flutter

  ```dart
  import 'package:flutter/services.dart';
  
  class NativeBridge {
    static const _channel = MethodChannel('app/native');
  
    /// 通解：调用原生
    static Future<T?> call<T>({
      required String method,
      dynamic args,
    }) async {
      final result = await _channel.invokeMethod<T>(method, args);
      return result;
    }
  }
  ```

  ```dart
  final version = await NativeBridge.call<String>(
    method: 'getVersion',
  );
  
  await NativeBridge.call(
    method: 'openPage',
    args: {'userId': '1001'},
  );
  ```

* Android（Kotlin）

  ```kotlin
  MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/native")
      .setMethodCallHandler { call, result ->
  
          when (call.method) {
  
              "getVersion" -> {
                  result.success("Android 14")
              }
  
              "openPage" -> {
                  val userId = call.argument<String>("userId")
                  // 做你的事情
                  result.success(null)
              }
  
              else -> result.notImplemented()
          }
      }
  ```

* iOS（Swift）

  ```swift
  let channel = FlutterMethodChannel(
    name: "app/native",
    binaryMessenger: controller.binaryMessenger
  )
  
  channel.setMethodCallHandler { call, result in
    switch call.method {
  
    case "getVersion":
      result("iOS 17")
  
    case "openPage":
      let args = call.arguments as? [String: Any]
      let userId = args?["userId"] as? String
      result(nil)
  
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  ```

### 2、原生 → Flutter（回调 / 通知）

> 支付结果回调
>
> 登录成功回调
>
> 原生页面关闭后，通知 Flutter 刷新
>
> SDK 回调（比如广告加载完成）

* Flutter

  ```dart
  class NativeCallback {
    static const _channel = MethodChannel('app/callback');
  
    static void register() {
      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
  
          case 'loginSuccess':
            final userId = call.arguments['userId'];
            print('登录成功: $userId');
            break;
  
          case 'payResult':
            final success = call.arguments['success'];
            print('支付结果: $success');
            break;
        }
      });
    }
  }
  ```

  ```dart
  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    NativeCallback.register();
    runApp(MyApp());
  }
  ```

* Android（Kotlin）

  ```kotlin
  val channel = MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      "app/callback"
  )
  
  // 通解：回调 Flutter
  fun notifyFlutter(method: String, args: Any?) {
      channel.invokeMethod(method, args)
  }
  ```

  ```kotlin
  notifyFlutter("loginSuccess", mapOf("userId" to "1001"))
  ```

* iOS（Swift）

  ```swift
  let channel = FlutterMethodChannel(
    name: "app/callback",
    binaryMessenger: controller.binaryMessenger
  )
  
  func notifyFlutter(_ method: String, args: Any?) {
    /// invokeMethod 不是系统 API，是 Flutter 提供的
    channel.invokeMethod(method, arguments: args)
  }
  ```

  ```swift
  notifyFlutter("loginSuccess", args: ["userId": "1001"])
  ```

## 六、Flutter UI 调度（核心中的核心）

* Flutter 不是`随时 render`，它是 **按帧驱动**

* ```
  vsync 信号（16ms）
        ↓
  SchedulerBinding.handleBeginFrame
        ↓
  build
  layout
  paint
        ↓
  GPU
  ```

* `setState(() {});`

  * 并不会立刻 **rebuild**！

  * 实际做的事

    * 标记 **widget dirty**

    * 请求下一帧（scheduleFrame）。等下一帧统一 **rebuild**

    * ```dart
      setState();
      setState();
      setState();
      
      /// 只会 rebuild 一次（合并到下一帧）
      ```

## 七、如果从 0 到 1 设计 Flutter 项目，怎么设计目录结构？【级别：中高级】

### 1、设计原则

- 单一职责
- 分层清晰
- 单向依赖
- 可测试
- 可扩展
- 可替换
- 便于多人协作

### 2、目录结构

* 常见结构
  ```
  lib/
  ├── app/                  # App 启动、路由、全局配置
  ├── core/                 # 公共能力：网络、错误、日志、工具、主题、常量
  ├── data/                 # 数据层：model、datasource、repository impl
  ├── domain/               # 领域层：entity、repository abstract、usecase
  ├── presentation/         # 表现层：page、widget、state、controller/viewmodel
  ├── features/             # 按业务模块拆分（大型项目推荐）
  │   ├── login/
  │   ├── home/
  │   └── profile/
  └── main.dart
  ```

* 简版目录（更贴近实战）
  
  ```text
  lib/
  ├── app/
  │   ├── router/
  │   ├── di/
  │   └── bootstrap/
  ├── core/
  │   ├── network/
  │   ├── error/
  │   ├── storage/
  │   ├── theme/
  │   └── utils/
  ├── features/
  │   ├── login/
  │   │   ├── data/
  │   │   ├── domain/
  │   │   ├── presentation/
  │   │   └── login_module.dart
  │   ├── home/
  │   └── profile/
  └── shared/
      ├── widgets/
      └── extensions/
  ```
  
  



### 3、主流思路

#### 方案一：按分层拆

适合：

- 中小项目
- 团队人数少
- 先把边界理顺

#### 方案二：按 feature 拆，再在 feature 内部分层

适合：

- 中大型项目
- 业务模块多
- 多人并行开发
- 后续模块化 / 组件化

##  六、示范

* ❌错误示范

  ```dart
  /// 这个任务在 event queue、一旦开始执行 → 独占线程、UI 直接卡死
  Future(() {
    for (var i = 0; i < 1e9; i++) {}
  });
  ```

* ✅正确示范

  ```dart
  /// 真正并发执行
  await Isolate.run(() {
    for (var i = 0; i < 1e9; i++) {}
  });
  ```

  

  

  

​    
