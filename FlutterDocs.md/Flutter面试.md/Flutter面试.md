# Flutter 面试题手册（扩充版）

> 目标：覆盖 **初级 / 中级 / 高级**，重点扩充你提到的几类题：**本地存储、Future、Isolate、目录结构、跨端通信**。  
> 风格：**不堆废话，只给面试关键字、答题主线、追问点、易错点、代码点拨**。

---

# 一、他日5 问（扩充版）

## 1）Flutter 的本地存储方案有哪些？【级别：中级】

### 面试官想听什么
- 你不是在背 API
- 你能 **按场景选型**
- 你知道 **轻量存储 / 文件 / 数据库 / 高性能对象存储** 的区别

### 高分答题主线
可以按 **数据复杂度、查询能力、性能要求、是否需要事务** 来分：

#### 1. `shared_preferences`
**关键字：**
- 轻量级 key-value
- 配置项
- 用户偏好
- token / 开关状态 / 首次启动标记

**适用：**
- 主题模式
- 语言设置
- 登录态辅助信息
- 小体量配置

**不适合：**
- 大对象
- 复杂查询
- 高频写入
- 强一致业务数据

---

#### 2. 文件存储
**关键字：**
- JSON 文件
- 文本缓存
- 日志
- 离线草稿
- 图片 / 二进制

**适用：**
- 页面草稿缓存
- 本地日志
- 大块文本
- 导入导出

**风险点：**
- 自己处理序列化
- 查询能力弱
- 并发写入要小心

---

#### 3. SQLite（如 `sqflite`）
**关键字：**
- 关系型数据库
- SQL 查询
- 事务
- 索引
- 多表关联

**适用：**
- 聊天记录
- 搜索历史
- 订单列表
- 复杂筛选、本地分页

**优点：**
- 查询能力强
- 可控性高
- 支持事务

**缺点：**
- 表设计成本高
- ORM / SQL 维护成本更高

---

#### 4. Hive / Isar / ObjectBox
**关键字：**
- 本地对象存储
- 高性能
- 非关系型
- 读写快
- 适合 Flutter 本地缓存

**适用：**
- 本地缓存
- 配置快读写
- 对象直接落盘
- 中小型离线数据

**答题加分点：**
- `Hive`：简单、轻量、上手快
- `Isar`：查询能力比传统轻量 KV 更强
- `ObjectBox`：对象数据库，性能好，适合本地对象模型

---

### 推荐答法
> Flutter 本地存储我一般按 4 类来选：  
> 第一类是 `shared_preferences`，适合轻量 key-value；  
> 第二类是文件存储，适合 JSON、日志、草稿；  
> 第三类是 `sqflite`，适合需要事务、复杂查询、多表关系的数据；  
> 第四类是 Hive / Isar / ObjectBox 这类高性能本地对象存储，适合做缓存层。  
> 实际项目里我不会只说“用哪个”，而是先看 **数据体量、查询复杂度、性能要求、是否需要事务**。  
> 比如设置项我会用 `shared_preferences`，列表缓存和对象缓存更偏向 Hive / Isar，复杂业务数据会用 SQLite。

### 面试追问
- `shared_preferences` 能不能存用户信息？
- Hive 和 SQLite 怎么选？
- 为什么有了接口缓存，还要做本地数据库？
- token 放哪？安全吗？

### 易错点
- 把所有本地存储都说成缓存
- 只会背 `shared_preferences`
- 不会讲选型依据
- 把安全存储和普通本地存储混为一谈

### 额外加分一句
> 如果涉及敏感数据，比如 token / 密钥，我会优先考虑 `flutter_secure_storage` 这类安全存储，而不是普通明文存储。

---

## 2）Future 是不是多线程？【级别：中级】

### 标准结论
> **不是。** `Future` 代表的是 **异步结果**，不是多线程。  
> Dart 默认执行模型还是基于 **单 Isolate + Event Loop**。

### 面试关键字
- 异步 != 多线程
- `Future` 是任务调度结果
- Event Loop
- Microtask Queue
- Event Queue
- 默认仍在主 Isolate 执行

### 高分答法
> `Future` 本质上是一个未来某个时刻会返回结果的对象，它解决的是异步编排问题，不等于多线程。  
> 在 Dart 里，普通 `Future` 大多数情况下还是在当前 Isolate 的事件循环中执行。  
> 真正意义上的并发隔离，要看 `Isolate`。  
> 所以 `Future` 更准确说是 **异步编程模型的一部分**，不是线程模型。

### 你最好再补一句
> 比如网络请求、定时器、IO 操作会以异步方式返回 `Future`，但这不代表我开启了一个线程去跑 Dart 代码。

### 面试追问
- `Future.then` 进哪个队列？
- `scheduleMicrotask` 和 `Future(() {})` 谁先执行？
- `async/await` 本质是什么？
- 为什么 UI 会卡顿，明明用了 `Future`？

### 易错点
- 说“Future 就是开子线程”
- 说“async/await 就是多线程封装”
- 完全讲不清事件循环

### 快速点拨代码
```dart
void main() {
  print('A');

  Future(() => print('B'));
  scheduleMicrotask(() => print('C'));

  print('D');
}
```

**输出：**
```dart
A
D
C
B
```

**关键字：**
- 同步先执行
- microtask 优先于 event
- `Future(() {})` 通常进入 event queue

---

## 3）介绍下 Isolate【级别：中高级】

### 一句话定义
> `Isolate` 是 Dart 的并发模型单位，每个 Isolate 都有 **独立内存空间和事件循环**，彼此之间通过 **消息传递** 通信，不共享内存。

### 面试关键字
- 独立内存
- message passing
- 不共享堆内存
- 并发隔离
- CPU 密集型任务
- 避免阻塞主 Isolate

### 高分答法
> Dart 没有传统意义上共享内存的多线程模型，核心并发单位是 `Isolate`。  
> 每个 `Isolate` 都有独立的内存和事件循环，所以天然避免了很多锁竞争问题。  
> 代价是通信不能直接共享对象，只能通过消息传递。  
> 在 Flutter 里，UI 渲染主要跑在主 Isolate，如果有 JSON 大解析、图片压缩、加解密、复杂计算这类 CPU 密集型任务，我会考虑放到 Isolate，避免主线程掉帧。

### 典型使用场景
- 大 JSON 解析
- 图片处理
- 压缩 / 解压
- 加密 / 解密
- 大批量本地数据转换

### 不适合滥用的场景
- 很轻的小任务
- 高频、短时、小计算
- 强依赖 BuildContext / UI 的逻辑

### 面试追问
- 为什么 Isolate 不能共享内存？
- `compute` 是什么？
- 创建 Isolate 有成本吗？
- Isolate 和线程的关系？
- Flutter 为啥不用共享内存多线程？

### 易错点
- 直接说 “Isolate 就是线程”
- 不知道消息传递
- 不知道创建成本
- 什么事都说丢给 Isolate

### 代码点拨：`compute`
```dart
final result = await compute(parseJson, jsonString);

Map<String, dynamic> parseJson(String source) {
  return jsonDecode(source) as Map<String, dynamic>;
}
```

**关键字：**
- `compute`：Flutter 对简单后台计算的封装
- 适合单次重任务
- 参数和返回值要可传递

### 再高级一点的说法
> `Isolate` 不是越多越好。因为创建、销毁、消息序列化本身有成本，所以更适合“重任务”，不适合“碎任务”。

---

## 4）如果你从 0 到 1 设计 Flutter 项目，你会怎么设计目录结构？【级别：中高级】

### 面试官想看什么
- 你是否具备工程化能力
- 你不是只会按页面堆代码
- 你知道如何控制依赖方向、模块边界、公共抽象

### 不推荐的回答
> 我一般按页面分目录：home、mine、detail……

这太浅。

---

### 推荐答法：先讲原则，再讲目录
### 设计原则
- 单一职责
- 分层清晰
- 单向依赖
- 可测试
- 可扩展
- 可替换
- 便于多人协作

### 常见目录结构
```text
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

### 两种主流思路
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

### 更推荐的表达
> 如果是从 0 到 1，我会先判断项目规模。  
> 中小项目我会用“全局分层结构”，比如 `data / domain / presentation / core`。  
> 如果项目会持续迭代、多人协作、业务线多，我会用 **feature-first + feature 内部分层** 的结构。  
> 这样做的目标不是为了目录好看，而是为了让依赖方向清晰、模块边界清晰，后续方便测试、复用和拆包。

### 面试追问
- 为什么需要 `domain` 层？
- 为什么不直接页面调 repository？
- 怎么避免循环依赖？
- 公共 widget 放哪？
- 路由、网络、状态管理怎么接进去？

### 易错点
- 只会说目录名，不会说设计原因
- 所有东西都扔 `utils`
- 所有页面共用一个 provider / bloc
- `model/entity/vo/dto` 概念混乱

### 简版目录（更贴近实战）
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

---

## 5）你有没有做过跨端的，比如 Flutter 调原生、原生调 Flutter？【级别：中高级】

> 这个题你必须准备。现在很多 Flutter 面试官都会问。  
> 重点不是 API 名字，而是你是否理解 **调用链、边界、异步回调、生命周期、数据格式、异常处理**。

### 先给面试标准回答
> 做过。Flutter 和原生互调我通常按场景分三类：  
> 1. **Flutter 调原生**：比如获取设备信息、调用相机、蓝牙、定位、支付、第三方 SDK；  
> 2. **原生调 Flutter**：比如原生页面跳转到 Flutter 页面、给 Flutter 传初始化参数、通知 Flutter 刷新；  
> 3. **双向事件通信**：比如登录状态同步、推送点击、支付结果回传、埋点桥接。  
> 常见实现我会用 `MethodChannel`、`EventChannel`，必要时还有 `BasicMessageChannel`。  
> 设计上我会重点关注：**通道命名规范、参数结构统一、错误码、线程切换、生命周期和回调时机**。

---

### 5.1 Flutter 调原生
### 关键字
- `MethodChannel`
- invokeMethod
- async result
- 平台能力下沉
- 参数 Map
- 错误码约定

### Flutter 端代码点拨
```dart
static const channel = MethodChannel('com.demo/device');

final version = await channel.invokeMethod<String>('getAppVersion');
```

### Android 端代码点拨（Kotlin）
```kotlin
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.demo/device")
    .setMethodCallHandler { call, result ->
        when (call.method) {
            "getAppVersion" -> {
                result.success("1.0.0")
            }
            else -> result.notImplemented()
        }
    }
```

### iOS 端代码点拨（Swift）
```swift
let channel = FlutterMethodChannel(
    name: "com.demo/device",
    binaryMessenger: controller.binaryMessenger
)

channel.setMethodCallHandler { call, result in
    switch call.method {
    case "getAppVersion":
        result("1.0.0")
    default:
        result(FlutterMethodNotImplemented)
    }
}
```

### 回答时要补的点
- Flutter 发起调用
- 原生执行能力
- 原生通过 `result.success / error / notImplemented` 回传
- 建议统一参数结构和错误码

---

### 5.2 原生调 Flutter
### 面试关键字
- 路由跳转
- 初始参数注入
- channel 反向调用
- FlutterEngine 复用
- 页面生命周期

### 场景
- 原生首页某个入口进入 Flutter 页面
- 原生拿到登录态后通知 Flutter 刷新
- 推送点击进入 Flutter 指定页面

### 代码点拨：原生调用 Flutter 方法
#### Android（Kotlin）
```kotlin
val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.demo/event")
channel.invokeMethod("onLogin", mapOf("uid" to "1001"))
```

#### Flutter 端接收
```dart
static const channel = MethodChannel('com.demo/event');

void registerHandler() {
  channel.setMethodCallHandler((call) async {
    if (call.method == 'onLogin') {
      final args = Map<String, dynamic>.from(call.arguments);
      // 刷新用户态
    }
  });
}
```

### 这时你要说的关键点
- 原生主动通知 Flutter，本质也是 channel 通信
- Flutter 页面是否已初始化，要考虑时机
- 多引擎 / 单引擎复用时，通道注册要统一管理

---

### 5.3 持续事件流：`EventChannel`
### 适用场景
- 电量变化
- 网络状态变化
- 传感器
- 定位持续更新
- 下载进度
- 播放进度

### Flutter 端代码点拨
```dart
static const eventChannel = EventChannel('com.demo/network');

eventChannel.receiveBroadcastStream().listen((event) {
  // 处理持续事件
});
```

### 关键字
- 广播流
- 持续推送
- 监听取消
- 生命周期解绑

---

### 5.4 你答这个题时，最好主动补的工程化点
- 通道命名规范：`com.company.module/action`
- 参数统一用 `Map`
- 错误统一：`code / message / details`
- 敏感调用要鉴权
- 回调线程要明确
- 不要把业务逻辑全塞进 channel handler
- 桥接层只做协议转换，业务下沉到 service

### 一句高级表达
> 我一般会把平台通道封装成一层 `platform service`，上层业务只依赖 Dart 接口，不直接到处写 `MethodChannel`，这样便于测试和替换实现。

---

# 二、Flutter 完整面试题（按级别整理）

---

# A. 初级题

## 1）StatelessWidget 和 StatefulWidget 区别？【级别：初级】
**关键字：**
- 是否可变
- `build`
- `State`
- 生命周期

**答题点：**
- `StatelessWidget`：数据不可变，依赖外部输入
- `StatefulWidget`：有独立 `State`，适合需要状态变化的页面

**追问：**
- `setState` 做了什么？
- 为什么 `StatefulWidget` 本身也是不可变的？

---

## 2）`setState` 原理是什么？【级别：初级】
**关键字：**
- 标记 dirty
- 触发 rebuild
- 不是立刻重绘
- 框架调度

---

## 3）Flutter 常见生命周期有哪些？【级别：初级】
**关键字：**
- `initState`
- `didChangeDependencies`
- `build`
- `didUpdateWidget`
- `dispose`

**易错点：**
- 在 `initState` 里直接依赖 `context` 做继承监听
- 忘记 `dispose`

---

## 4）`const` 在 Flutter 里有什么用？【级别：初级】
**关键字：**
- 编译期常量
- 减少重复创建
- 有利于性能
- widget 复用判断

---

## 5）Flutter 里常见布局组件？【级别：初级】
**关键字：**
- `Row`
- `Column`
- `Stack`
- `Expanded`
- `Flexible`
- `Wrap`
- `ListView`

---

## 6）`Expanded` 和 `Flexible` 区别？【级别：初级】
**关键字：**
- 剩余空间分配
- 紧约束 / 松约束

---

## 7）`ListView.builder` 为什么比直接 children 更合适长列表？【级别：初级】
**关键字：**
- 懒加载
- 按需构建
- 降低内存占用

---

## 8）Flutter 里如何做页面跳转？【级别：初级】
**关键字：**
- `Navigator.push`
- `pop`
- 命名路由
- 路由参数

---

## 9）Flutter 网络请求你怎么做？【级别：初级】
**关键字：**
- `dio`
- 封装
- 拦截器
- 错误处理
- token 注入

---

## 10）Flutter 怎么做状态管理？你用过什么？【级别：初级】
**关键字：**
- `setState`
- Provider
- Bloc
- Riverpod
- GetX

**答题建议：**
- 先讲你实际用过的
- 再讲适用场景
- 别贪多

---

# B. 中级题

## 11）Flutter 的本地存储方案有哪些？【级别：中级】
见上文扩充版。

---

## 12）Future 是不是多线程？【级别：中级】
见上文扩充版。

---

## 13）Flutter 中 `async/await` 本质是什么？【级别：中级】
**关键字：**
- 语法糖
- 基于 `Future`
- 挂起当前函数后续逻辑
- 不阻塞主线程同步代码

---

## 14）microtask 和 event queue 区别？【级别：中级】
**关键字：**
- microtask 优先级更高
- event 存放普通异步任务
- 小心 microtask 饥饿

---

## 15）为什么用了异步，页面还是会卡？【级别：中级】
**关键字：**
- CPU 密集型任务仍占主 Isolate
- `Future` 不等于后台线程
- JSON 大解析 / 大循环仍会卡

---

## 16）介绍下 Isolate【级别：中高级】
见上文扩充版。

---

## 17）Flutter 和 Dart 的关系？【级别：中级】
**关键字：**
- Flutter 是 UI 框架
- Dart 是语言
- Flutter engine + framework
- Dart 负责业务和运行时逻辑

---

## 18）Widget / Element / RenderObject 的关系？【级别：中高级】
**关键字：**
- Widget：配置
- Element：实例化桥梁
- RenderObject：布局和绘制

**这一题如果能答清楚，明显加分。**

---

## 19）`BuildContext` 是什么？【级别：中级】
**关键字：**
- Element 的抽象引用
- 用于定位树中位置
- 访问依赖和祖先节点

**易错点：**
- 把它理解成页面对象
- 生命周期错位使用

---

## 20）你怎么做网络层封装？【级别：中级】
**关键字：**
- `dio` 二次封装
- 统一 baseUrl
- 拦截器
- token 刷新
- 错误映射
- 泛型解析
- 取消请求

---

## 21）你怎么设计缓存策略？【级别：中级】
**关键字：**
- 内存缓存
- 磁盘缓存
- 过期时间
- 读缓存 -> 请求网络 -> 回写
- 离线优先 / 网络优先

---

## 22）Flutter 常见性能问题有哪些？【级别：中级】
**关键字：**
- 不必要 rebuild
- 长列表卡顿
- 图片过大
- 过度嵌套
- 主线程重计算
- 动画掉帧

---

## 23）如何减少不必要的 rebuild？【级别：中级】
**关键字：**
- `const`
- 拆小 widget
- 精细状态订阅
- `Selector`
- `Consumer`
- keys 合理使用

---

## 24）为什么要做 Repository 抽象？【级别：中高级】
**关键字：**
- 解耦数据来源
- 便于测试
- 可切换远端 / 本地
- 统一业务入口

---

## 25）你怎么处理异常和错误提示？【级别：中级】
**关键字：**
- 网络异常分层
- 业务错误码
- UI 友好提示
- 日志 / 上报
- 重试机制

---

## 26）如果让你从 0 到 1 搭 Flutter 项目，你怎么设计目录结构？【级别：中高级】
见上文扩充版。

---

## 27）你有没有做过 Flutter 调原生、原生调 Flutter？【级别：中高级】
见上文扩充版。

---

# C. 高级题

## 28）大型 Flutter 项目怎么做模块化？【级别：高级】
**关键字：**
- feature module
- 业务边界
- 共享能力下沉
- 模块依赖治理
- 路由解耦
- 按域拆分

**高分表达：**
> 模块化不是拆文件夹，是控制依赖方向和演进成本。

---

## 29）状态管理你怎么选型？【级别：高级】
**关键字：**
- 团队认知成本
- 可测试性
- 可维护性
- 粒度控制
- 异步状态表达
- Riverpod / Bloc 取舍

**答题建议：**
- 别说“哪个好用就用哪个”
- 要讲项目规模、团队协作、调试成本

---

## 30）你怎么做 Flutter 性能优化？【级别：高级】
**关键字：**
- 首帧优化
- 列表优化
- 图片缓存
- 重建控制
- isolate 拆重任务
- DevTools 分析
- shader / jank / memory

### 推荐答法框架
- 先定位：DevTools / Timeline / Memory
- 再分类：build、layout、paint、IO、CPU
- 最后落方案：拆 widget、懒加载、缓存、异步计算

---

## 31）Flutter 页面很复杂，如何控制状态膨胀？【级别：高级】
**关键字：**
- 页面状态 vs 业务状态分离
- 单向数据流
- 局部状态下沉
- viewmodel / notifier / bloc 分层

---

## 32）你如何做主题系统 / 设计系统？【级别：高级】
**关键字：**
- design token
- 颜色 / 字体 / 间距统一
- 深色模式
- 业务组件库
- 主题扩展

---

## 33）Flutter 混编时，你最关注什么？【级别：高级】
**关键字：**
- 引擎初始化成本
- FlutterEngine 复用
- 页面栈管理
- 生命周期同步
- 通道协议稳定性
- 包体积
- 崩溃定位

---

## 34）原生和 Flutter 共存项目，路由怎么设计？【级别：高级】
**关键字：**
- 原生路由表
- Flutter 路由映射
- 参数协议
- 页面返回结果
- 页面栈一致性

---

## 35）Flutter 包体积怎么优化？【级别：高级】
**关键字：**
- 资源压缩
- 删除无用依赖
- abi 拆分
- 按需资源
- 图片格式优化
- 字体裁剪

---

## 36）如何做埋点、日志、崩溃监控？【级别：高级】
**关键字：**
- 页面埋点
- 行为埋点
- 错误上报
- FlutterError
- Zone
- 平台侧补充日志

---

## 37）Flutter 启动慢，你怎么排查？【级别：高级】
**关键字：**
- 首屏链路
- 同步初始化过多
- 资源加载
- 引擎预热
- 延迟初始化
- 分阶段加载

---

## 38）Flutter 中你怎么做 CI/CD？【级别：高级】
**关键字：**
- 自动打包
- flavor
- 环境配置
- 自动测试
- 代码检查
- 发版流程
- 符号表管理

---

## 39）如果团队里初中级 Flutter 较多，你怎么推进工程规范？【级别：高级】
**关键字：**
- 脚手架
- lint
- code review
- 模板化
- 组件规范
- 通道规范
- 文档沉淀

---

## 40）如果让你带一个 Flutter 项目，你最先做什么？【级别：高级】
**关键字：**
- 先定边界
- 先定规范
- 先定目录和模块
- 先定状态管理
- 先定网络 / 存储 / 路由基建
- 先建可观测体系

**高分表达：**
> 我不会一上来就写业务页面，我会先搭最小可演进骨架，保证项目不是 3 个月后变成泥球。

---

# 三、跨端互调题的速记模板（面试时可直接背）

## 题：你有没有做过跨端的，比如 Flutter 调原生、原生调 Flutter？【级别：中高级】

### 30 秒版本
> 做过。Flutter 和原生互调我主要用 `MethodChannel` 和 `EventChannel`。  
> Flutter 调原生常见于设备能力、支付、定位、第三方 SDK；  
> 原生调 Flutter常见于页面跳转、登录态同步、推送回传；  
> 设计上我会关注通道协议、参数结构、错误码、生命周期和线程切换。  
> 如果项目复杂，我会把平台通道封装成统一的 `platform service`，上层业务不直接依赖 channel。

### 60 秒版本
> 做过，而且我一般不把它当成简单 API 调用，而是当成一层桥接协议。  
> Flutter 调原生，我通常用 `MethodChannel` 调设备信息、相机、蓝牙、支付这类平台能力；  
> 原生调 Flutter，一般是原生入口跳 Flutter 页、推送点击通知 Flutter、登录态同步；  
> 持续事件我会用 `EventChannel`。  
> 工程上我会统一通道命名、参数结构和错误码，避免多个页面各自乱写 channel。  
> 如果是混编项目，我还会考虑 `FlutterEngine` 复用、页面栈和生命周期同步问题。

---

# 四、你这场面试的定位判断

## 这 5 个题说明什么？
你昨天遇到的题，整体不是初级面。

### 偏中级
- 本地存储方案
- Future 是否多线程

### 偏中高级
- Isolate
- 从 0 到 1 设计目录结构
- 跨端互调

## 结论
> 这更像 **中级偏上 / 中高级** 面试。  
> 面试官在看你是不是“能独立负责项目”，不是只看你会不会写页面。

---

# 五、临场答题原则

## 原则 1：先给结论，再展开
别绕。

错误示范：
> 我觉得这个吧，应该要看情况……

正确示范：
> 结论先说：Future 不是多线程，它是异步结果模型。

---

## 原则 2：先讲场景，再讲技术
面试官更爱听“你怎么用”，不爱听百科。

---

## 原则 3：关键词要硬
比如：
- 单 Isolate
- Event Loop
- message passing
- 单向依赖
- Repository 抽象
- FlutterEngine 复用

这些词说出来，层级马上不一样。

---

## 原则 4：别装懂
尤其是：
- 渲染原理
- Isolate
- Widget/Element/RenderObject
- 混编引擎管理

不确定就说到你能兜住的层级。

---

# 六、最后给你的冲刺建议

## 你必须重点背熟的 10 个题
1. 本地存储方案  
2. Future 是不是多线程  
3. async/await 本质  
4. microtask 和 event queue  
5. Isolate  
6. Widget / Element / RenderObject  
7. BuildContext  
8. 状态管理选型  
9. 从 0 到 1 的目录结构  
10. Flutter 调原生 / 原生调 Flutter

## 如果只剩 1 天准备
优先顺序：
1. Future / Isolate / 事件循环
2. 项目架构 / 目录结构
3. 跨端互调
4. 性能优化
5. 状态管理选型

---

# 七、代码点拨总表（只记关键骨架）

## Flutter 调原生
```dart
static const channel = MethodChannel('com.demo/device');
final result = await channel.invokeMethod('getAppVersion');
```

## 原生回 Flutter
```dart
channel.setMethodCallHandler((call) async {
  if (call.method == 'onLogin') {
    final args = Map<String, dynamic>.from(call.arguments);
  }
});
```

## 持续事件
```dart
const eventChannel = EventChannel('com.demo/network');
eventChannel.receiveBroadcastStream().listen((event) {});
```

## Isolate / compute
```dart
final data = await compute(parseJson, jsonString);
```

## microtask 优先级
```dart
Future(() => print('event'));
scheduleMicrotask(() => print('microtask'));
```

---

# 八、一句话总评

> 你昨天这套题，不算纯高级面，但明显已经不是“只会写 UI”能混过去的级别。  
> 你要拿下这类面试，核心不是背题，而是把 **异步模型、工程结构、跨端互调** 这三块讲出“我能独立扛项目”的味道。
