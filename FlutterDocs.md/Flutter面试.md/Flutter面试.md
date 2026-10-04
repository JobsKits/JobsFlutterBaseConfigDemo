# Flutter 面试题手册（扩充版）

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

> 目标：覆盖 **初级 / 中级 / 高级**，重点扩充你提到的几类题：**本地存储、Future、Isolate、目录结构、跨端通信**。
>
> 风格：**问题和可直接说出口的回答优先，重点保留干货拆解、追问答案、易错点和代码骨架；面试官视角只作辅助，不抢答题主线**。

## 一、重点 5 问（扩充版） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> **重点题阅读顺序：问题 → 30 秒核心回答 → 干货拆解 → 面试追问与答案。**
>
> `核心回答` 和 `干货拆解` 是复习主线；`辅助视角` 只帮助理解面试官意图，默认收起，不作为背诵重点。

### 1.1、Flutter 的本地存储方案有哪些？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 1.1.1、核心回答（30 秒直接说） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> Flutter 本地存储不能只背库名，我会按 **数据体量、查询复杂度、性能要求和是否需要事务** 选型：轻量配置用 `shared_preferences`，JSON、日志或草稿用文件，需要关系查询和事务用 SQLite，对象缓存可选 Hive / Isar / ObjectBox。敏感 token 不放普通存储，而是使用平台安全存储并配合服务端过期、轮换和撤销。

<details>
<summary><b>辅助视角｜面试官想听什么（默认收起）</b></summary>

- 你不是在背 API
- 你能 **按场景选型**
- 你知道 **轻量存储 / 文件 / 数据库 / 高性能对象存储** 的区别

</details>

#### 1.1.2、干货拆解：按场景选存储方案 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
可以按 **数据复杂度、查询能力、性能要求、是否需要事务** 来分：

##### 1.1.2.1、`shared_preferences` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

##### 1.1.2.2、文件存储 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

##### 1.1.2.3、SQLite（如 `sqflite`） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

##### 1.1.2.4、Hive / Isar / ObjectBox <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

#### 1.1.3、完整回答（60 秒展开） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> Flutter 本地存储我一般按 4 类来选：  
> 第一类是 `shared_preferences`，适合轻量 key-value；  
> 第二类是文件存储，适合 JSON、日志、草稿；  
> 第三类是 `sqflite`，适合需要事务、复杂查询、多表关系的数据；  
> 第四类是 Hive / Isar / ObjectBox 这类高性能本地对象存储，适合做缓存层。  
> 实际项目里我不会只说“用哪个”，而是先看 **数据体量、查询复杂度、性能要求、是否需要事务**。  
> 比如设置项我会用 `shared_preferences`，列表缓存和对象缓存更偏向 Hive / Isar，复杂业务数据会用 SQLite。

#### 1.1.4、面试追问与答案 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- **追问：`shared_preferences` 能不能存用户信息？**
  - **答案：** 技术上可以存昵称、主题偏好这类少量、非敏感字段，但不适合保存完整用户档案、复杂结构或敏感凭证。它本质上是轻量 key-value 存储，缺少复杂查询、事务和数据关系能力；结构化用户数据更适合交给数据库或专门的缓存层。
- **追问：Hive 和 SQLite 怎么选？**
  - **答案：** 先看数据模型和查询方式。数据以 key-value 或简单对象为主、主要做整对象读写和缓存时，Hive 更轻量；需要多表关系、事务、条件查询、排序聚合和明确迁移能力时，优先 SQLite。不能只用“谁更快”做结论，最终要结合数据量、查询复杂度和团队维护成本。
- **追问：为什么有了接口缓存，还要做本地数据库？**
  - **答案：** 接口缓存主要减少重复请求，本地数据库还能提供离线可用、跨启动持久化、结构化查询、局部更新和增量同步。两者不是必须同时存在；如果业务没有离线和复杂查询需求，普通响应缓存可能已经够用。需要共存时，应由 Repository 统一协调内存、数据库和网络，并定义 TTL、版本及失效策略。
- **追问：token 放哪？安全吗？**
  - **答案：** 不放普通 `shared_preferences` 或明文文件。短期 access token 尽量只放内存，需要跨启动保存的 refresh token 或会话凭证放平台安全存储，例如通过 `flutter_secure_storage` 使用 Keychain / Keystore 体系；同时禁止写入日志，并配合服务端过期、轮换和撤销机制。安全存储只能提高攻击成本，设备被 Root、越狱或运行环境失陷时，客户端无法承诺绝对安全。

#### 1.1.5、易错点 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 把所有本地存储都说成缓存
- 只会背 `shared_preferences`
- 不会讲选型依据
- 把安全存储和普通本地存储混为一谈

#### 1.1.6、加分干货 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> 如果涉及敏感数据，比如 token / 密钥，我会优先考虑 `flutter_secure_storage` 这类安全存储，而不是普通明文存储。

---

### 1.2、Future 是不是多线程？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 1.2.1、核心回答（30 秒直接说） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> **不是。** `Future` 表示未来完成的异步结果，解决的是异步编排，不是线程模型。普通 `Future` 回调仍由当前 Isolate 的 Event Loop 调度；网络和 IO 在等待期间可以不阻塞 Dart 代码，但把 CPU 重任务包进 `Future(() {})` 仍会卡住当前 Isolate。真正需要并行计算时，应考虑工作 Isolate。

<details>
<summary><b>辅助视角｜面试官想听什么（默认收起）</b></summary>

- 能区分 **异步**、**并发** 和 **多线程**
- 知道 `Future` 依赖 Event Loop，而不是“自动开子线程”
- 能把普通异步任务与 `Isolate` 的并行计算边界讲清楚

</details>

#### 1.2.2、干货关键词 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 异步 != 多线程
- `Future` 是任务调度结果
- Event Loop
- Microtask Queue
- Event Queue
- 默认仍在主 Isolate 执行

#### 1.2.3、完整回答（60 秒展开） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> `Future` 本质上是一个未来某个时刻会返回结果的对象，它解决的是异步编排问题，不等于多线程。  
> 在 Dart 里，普通 `Future` 大多数情况下还是在当前 Isolate 的事件循环中执行。  
> 真正意义上的并发隔离，要看 `Isolate`。  
> 所以 `Future` 更准确说是 **异步编程模型的一部分**，不是线程模型。

#### 1.2.4、加分干货：Runtime 边界 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> 比如网络请求、定时器、IO 操作会以异步方式返回 `Future`，但这不代表我开启了一个线程去跑 Dart 代码。

> 从整个 Flutter Runtime 看也不能说“全是单线程”：Dart 业务代码通常从主 Isolate 开始，引擎和平台嵌入层还要协作处理平台事件与栅格化。从 Flutter 3.29 起，iOS 和 Android 的 UI 与 Platform 线程已经合并，因此不要死背固定线程数量。

#### 1.2.5、面试追问与答案 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- **追问：`Future.then` 进哪个队列？**
  - **答案：** `then` 只是给源 `Future` 注册完成回调，不能脱离源 `Future` 一概说成固定进入某个队列。源 `Future` 完成后才会执行回调；如果注册时源 `Future` 已经完成，回调也不会同步执行，而会安排到后续 microtask。面试时要同时说明“回调执行时机取决于源 `Future` 如何完成”。
- **追问：`scheduleMicrotask` 和 `Future(() {})` 谁先执行？**
  - **答案：** 在同一轮同步代码中，通常是 `scheduleMicrotask` 先执行。因为它直接进入 microtask queue，而 `Future(() {})` 底层通过 `Timer.run` 调度，属于 event queue；当前同步栈结束后会先清空 microtask，再取下一个 event。连续递归添加 microtask 可能饿死事件队列，所以不能滥用。
- **追问：`async/await` 本质是什么？**
  - **答案：** 它是基于 `Future` 的语法糖和异步状态机。`async` 函数立即返回 `Future`，执行到未完成的 `await` 时暂停当前函数的后续逻辑，把后续部分作为 continuation，等目标 `Future` 完成后再恢复执行；异常则通过返回的 `Future` 传播，可用 `try/catch` 捕获。整个过程不会因为写了 `async/await` 就自动创建线程。
- **追问：为什么 UI 会卡顿，明明用了 `Future`？**
  - **答案：** `Future` 只负责异步编排，不会自动把 Dart 代码搬到后台线程。CPU 密集型同步代码即使放进 `Future(() {})`，仍会在当前 Isolate 的事件循环中执行，照样阻塞帧调度。应先用 DevTools 定位耗时，再拆小任务、减少构建和布局开销；原生端较重的纯计算可用 `Isolate.run` 或 `compute` 转移到工作 Isolate。

#### 1.2.6、易错点 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 说“Future 就是开子线程”
- 说“async/await 就是多线程封装”
- 完全讲不清事件循环

#### 1.2.7、代码干货：队列执行顺序 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

### 1.3、介绍下 Isolate【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 1.3.1、核心回答（30 秒直接说） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> `Isolate` 是 Dart 的并发执行单位，每个 Isolate 都有 **独立内存和事件循环**，彼此通过消息传递通信，不共享可变堆对象。Flutter 的 UI 和业务回调通常运行在主 Isolate；大 JSON 解析、图片处理、加解密等 CPU 重任务可放到工作 Isolate，避免阻塞帧调度。它不是传统共享内存线程，创建和通信也有成本。

<details>
<summary><b>辅助视角｜面试官想听什么（默认收起）</b></summary>

- 能说清独立内存、Event Loop 和消息传递
- 不把 `Isolate` 简化成“Dart 线程”
- 知道什么时候该用、什么时候不值得用

</details>

#### 1.3.2、干货关键词 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 独立内存
- message passing
- 不共享堆内存
- 并发隔离
- CPU 密集型任务
- 避免阻塞主 Isolate

#### 1.3.3、完整回答（60 秒展开） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> Dart 没有传统意义上共享内存的多线程模型，核心并发单位是 `Isolate`。  
> 每个 `Isolate` 都有独立的内存和事件循环，所以天然避免了很多锁竞争问题。  
> 代价是通信不能直接共享对象，只能通过消息传递。  
> 在 Flutter 里，Widget 构建和业务回调通常由主 Isolate 执行；如果有 JSON 大解析、图片压缩、加解密、复杂计算这类 CPU 密集型任务，我会考虑放到工作 Isolate，避免阻塞 UI 调度。

#### 1.3.4、干货场景：什么时候该用 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 大 JSON 解析
- 图片处理
- 压缩 / 解压
- 加密 / 解密
- 大批量本地数据转换

#### 1.3.5、边界：什么时候不该用 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 很轻的小任务
- 高频、短时、小计算
- 强依赖 BuildContext / UI 的逻辑

#### 1.3.6、面试追问与答案 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- **追问：为什么 Isolate 不能共享内存？**
  - **答案：** 这是 Dart 并发模型的隔离保证：每个 Isolate 拥有独立堆和事件循环，另一个 Isolate 不能直接访问它的可变对象，只能通过 `SendPort` / `ReceivePort` 传递可发送消息。运行时可对部分消息做复制、共享不可变数据或所有权转移优化，但不会因此变成共享可变内存。
- **追问：`compute` 是什么？**
  - **答案：** `compute` 是 Flutter 提供的一次性后台计算便捷 API，适合会占用数毫秒以上、可能造成掉帧的纯计算。Native 平台上它等价于通过 `Isolate.run` 在独立 Isolate 执行回调，参数和结果必须可跨 Isolate 发送；Web 平台上它仍在当前事件循环运行，不具备多 Isolate 并行能力。
- **追问：创建 Isolate 有成本吗？**
  - **答案：** 有，包括创建和初始化 Isolate、分配独立堆、调度以及消息复制或转移的成本。因此轻量小任务直接执行通常更划算；高频任务可以批处理，或使用长生命周期工作 Isolate 复用通信通道。是否值得拆出去，应以任务耗时和性能分析结果判断。
- **追问：Isolate 和线程的关系？**
  - **答案：** Isolate 是 Dart 语言和运行时层的并发单位，线程是操作系统调度单位。每个 Isolate 都有自己的内存和单线程事件循环，Native 平台的工作 Isolate 可以在其它线程和 CPU 核上并行执行，但不能把 Isolate 当成可共享内存的传统线程，也不应依赖固定的一一映射关系。
- **追问：Flutter 为啥不用共享内存多线程？**
  - **答案：** 更准确地说，是 Dart 业务代码采用隔离内存和消息传递模型。这样避免共享可变状态带来的锁竞争、数据竞争和大量同步复杂度，更容易保证 UI 状态的一致性；代价是跨 Isolate 通信和数据传递有成本。它减少的是共享内存并发问题，并不能消除接口竞态、消息乱序等所有业务竞态。

#### 1.3.7、易错点 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 直接说 “Isolate 就是线程”
- 不知道消息传递
- 不知道创建成本
- 什么事都说丢给 Isolate

#### 1.3.8、代码干货：`compute` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

#### 1.3.9、代码干货：`Isolate.run` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```dart
import 'dart:isolate';

final result = await Isolate.run(() => parseJson(jsonString));
```

**选型：**

- `Isolate.run()`：推荐用于单次计算；
- `Isolate.spawn()`：适合需要长期收发消息的 Worker；
- `Future(() { ... })`：仍在当前 Isolate 调度，不会把 CPU 重任务自动移到后台。

#### 1.3.10、加分干货 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> `Isolate` 不是越多越好。因为创建、销毁、消息序列化本身有成本，所以更适合“重任务”，不适合“碎任务”。

---

### 1.4、如果你从 0 到 1 设计 Flutter 项目，你会怎么设计目录结构？【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 1.4.1、核心回答（30 秒直接说） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 我会先判断项目规模和协作方式。中小项目可以采用 `data / domain / presentation / core` 的全局分层；业务线多、需要多人并行时，更适合 **feature-first，再在 Feature 内部分层**。核心不是目录名字，而是职责清楚、依赖单向、模块可测试，公共能力可替换，并为后续拆包和组件化留出边界。

<details>
<summary><b>辅助视角｜面试官想看什么与弱回答示例（默认收起）</b></summary>

**面试官想看什么：**

- 你是否具备工程化能力
- 你不是只会按页面堆代码
- 你知道如何控制依赖方向、模块边界、公共抽象

**不推荐的回答：**

> 我一般按页面分目录：home、mine、detail……

这个回答只说了目录表象，没有说明职责、依赖和选型依据。

</details>

#### 1.4.2、干货拆解：设计原则 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 单一职责
- 分层清晰
- 单向依赖
- 可测试
- 可扩展
- 可替换
- 便于多人协作

#### 1.4.3、干货拆解：常见目录结构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

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

#### 1.4.4、干货选型：两种主流思路 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

##### 1.4.4.1、方案一：按分层拆 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

适合：

- 中小项目
- 团队人数少
- 先把边界理顺

##### 1.4.4.2、方案二：按 feature 拆，再在 feature 内部分层 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

适合：

- 中大型项目
- 业务模块多
- 多人并行开发
- 后续模块化 / 组件化

#### 1.4.5、完整回答（60 秒展开） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 如果是从 0 到 1，我会先判断项目规模。  
> 中小项目我会用“全局分层结构”，比如 `data / domain / presentation / core`。  
> 如果项目会持续迭代、多人协作、业务线多，我会用 **feature-first + feature 内部分层** 的结构。  
> 这样做的目标不是为了目录好看，而是为了让依赖方向清晰、模块边界清晰，后续方便测试、复用和拆包。

#### 1.4.6、面试追问与答案 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- **追问：为什么需要 `domain` 层？**
  - **答案：** `domain` 层用于承载与 UI 和数据源无关的业务规则或 Use Case，例如组合多个 Repository、复用复杂流程和统一业务校验，让页面状态层保持简单且方便单测。但它不是必选项；简单 CRUD 如果没有复杂或复用逻辑，可以让 ViewModel 直接调用 Repository，避免为了分层而分层。
- **追问：为什么不直接页面调 Repository？**
  - **答案：** 如果“页面”指 Widget，不建议让它直接负责数据编排、重试、错误转换和状态流转，否则 UI、业务与数据访问会耦合，生命周期和测试也更难处理。通常由 ViewModel、Controller、Bloc 或 Notifier 调用 Repository，Widget 只渲染状态和转发用户意图；简单场景下状态层直接调用 Repository 是合理的，不必强制再套 Use Case。
- **追问：怎么避免循环依赖？**
  - **答案：** 先固定单向依赖规则，例如 `presentation → domain → data abstraction`，具体数据实现由应用组合根通过依赖注入装配。Feature 之间不直接互相 import 实现，需要协作时通过公共契约、路由参数或事件通信；共享代码只上提到真正稳定的 `core` 或独立 package，并用 lint、package 边界和依赖图持续检查。
- **追问：公共 widget 放哪？**
  - **答案：** 无业务语义、能跨模块复用的按钮、间距、颜色和基础组件放 `core/ui`、`design_system` 或独立 UI package；带明确业务语义的组件仍放所属 Feature 的 `presentation/widgets`。判断标准是“离开当前业务后能否独立成立”，不能把暂时重复的页面片段全扔进 `common`。
- **追问：路由、网络、状态管理怎么接进去？**
  - **答案：** 路由在应用层统一注册，Feature 只暴露页面入口或路由契约；网络客户端属于基础设施层，由各 Feature 的 Service / Repository 使用；Provider、Bloc、Riverpod 等状态管理只放在 presentation 层。最终在应用组合根完成依赖注入，让 domain 不依赖路由、网络库和具体状态管理框架。

#### 1.4.7、易错点 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 只会说目录名，不会说设计原因
- 所有东西都扔 `utils`
- 所有页面共用一个 provider / bloc
- `model/entity/vo/dto` 概念混乱

#### 1.4.8、实战干货：简版目录 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

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

### 1.5、你有没有做过跨端的，比如 Flutter 调原生、原生调 Flutter？【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 1.5.1、核心回答（30 秒直接说） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 做过。Flutter 和原生互调我通常按场景分三类：  
> 1. **Flutter 调原生**：比如获取设备信息、调用相机、蓝牙、定位、支付、第三方 SDK；  
> 2. **原生调 Flutter**：比如原生页面跳转到 Flutter 页面、给 Flutter 传初始化参数、通知 Flutter 刷新；  
> 3. **双向事件通信**：比如登录状态同步、推送点击、支付结果回传、埋点桥接。  
> 常见实现我会用 `MethodChannel`、`EventChannel`，必要时还有 `BasicMessageChannel`。  
> 设计上我会重点关注：**通道命名规范、参数结构统一、错误码、线程切换、生命周期和回调时机**。

<details>
<summary><b>辅助视角｜面试官想听什么（默认收起）</b></summary>

- 这个题你必须准备，现在很多 Flutter 面试官都会问
- 这类题重点不是背 API 名字，而是理解 **调用链、边界和双向通信方式**
- 能主动说明 **异步回调、生命周期、数据格式和异常处理**
- 不把业务逻辑直接堆进 Channel Handler，具备桥接层封装意识

</details>

---

#### 1.5.2、干货拆解：Flutter 调原生 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
##### 1.5.2.1、关键字 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- `MethodChannel`
- invokeMethod
- async result
- 平台能力下沉
- 参数 Map
- 错误码约定

##### 1.5.2.2、Flutter 端代码点拨 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```dart
static const channel = MethodChannel('com.demo/device');

final version = await channel.invokeMethod<String>('getAppVersion');
```

##### 1.5.2.3、Android 端代码点拨（Kotlin） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

##### 1.5.2.4、iOS 端代码点拨（Swift） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

##### 1.5.2.5、回答时要补的点 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- Flutter 发起调用
- 原生执行能力
- 原生通过 `result.success / error / notImplemented` 回传
- 建议统一参数结构和错误码

---

#### 1.5.3、干货拆解：原生调 Flutter <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
##### 1.5.3.1、面试关键字 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 路由跳转
- 初始参数注入
- channel 反向调用
- FlutterEngine 复用
- 页面生命周期

##### 1.5.3.2、场景 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 原生首页某个入口进入 Flutter 页面
- 原生拿到登录态后通知 Flutter 刷新
- 推送点击进入 Flutter 指定页面

##### 1.5.3.3、代码点拨：原生调用 Flutter 方法 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
##### 1.5.3.4、Android（Kotlin） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```kotlin
val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.demo/event")
channel.invokeMethod("onLogin", mapOf("uid" to "1001"))
```

##### 1.5.3.5、Flutter 端接收 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

##### 1.5.3.6、这时你要说的关键点 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 原生主动通知 Flutter，本质也是 channel 通信
- Flutter 页面是否已初始化，要考虑时机
- 多引擎 / 单引擎复用时，通道注册要统一管理

---

#### 1.5.4、干货拆解：持续事件流 `EventChannel` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
##### 1.5.4.1、适用场景 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 电量变化
- 网络状态变化
- 传感器
- 定位持续更新
- 下载进度
- 播放进度

##### 1.5.4.2、Flutter 端代码点拨 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```dart
static const eventChannel = EventChannel('com.demo/network');

eventChannel.receiveBroadcastStream().listen((event) {
  // 处理持续事件
});
```

##### 1.5.4.3、关键字 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 广播流
- 持续推送
- 监听取消
- 生命周期解绑

---

#### 1.5.5、工程化干货 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 通道命名规范：`com.company.module/action`
- 参数优先统一成有版本号的 `Map` 协议；`StandardMessageCodec` 支持一组标准 Dart 类型，自定义对象需要先转换，不能直接跨通道传递
- 错误统一：`code / message / details`
- 敏感调用要鉴权
- 回调线程要明确
- 不要把业务逻辑全塞进 channel handler
- 桥接层只做协议转换，业务下沉到 service

##### 1.5.5.1、加分表达 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> 我一般会把平台通道封装成一层 `platform service`，上层业务只依赖 Dart 接口，不直接到处写 `MethodChannel`，这样便于测试和替换实现。

---

## 二、Flutter 完整面试题（按级别整理） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

---

### 2.1、初级题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 2.1.1、StatelessWidget 和 StatefulWidget 区别？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 是否可变
- `build`
- `State`
- 生命周期

**答题点：**
- `StatelessWidget`：数据不可变，依赖外部输入
- `StatefulWidget`：有独立 `State`，适合需要状态变化的页面

**追问：**
- **追问：`setState` 做了什么？**
  - **答案：** 它先同步执行传入的状态修改回调，再把对应 Element 标记为 dirty，并请求框架在后续构建阶段统一 rebuild。它不会在调用点立刻完成 layout 和 paint，也不会创建新线程；`State` 已销毁后继续调用还会触发错误。
- **追问：为什么 `StatefulWidget` 本身也是不可变的？**
  - **答案：** Widget 只是某一时刻的不可变配置描述，父节点重建时可以低成本创建新的 Widget；真正可变、需要跨重建保留的数据放在独立 `State` 对象里。Element 根据 `runtimeType` 和 `key` 判断能否复用原来的 `State`，从而把“配置更新”和“可变状态生命周期”分开。

---

#### 2.1.2、`setState` 原理是什么？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 标记 dirty
- 触发 rebuild
- 不是立刻重绘
- 框架调度

**标准答法：**

> `setState()` 会先同步执行传入的回调，再调用 `Element.markNeedsBuild()` 把对应 Element 标记为 `dirty`。框架在后续构建阶段统一处理 dirty Element，然后按需进入 layout、paint 和 compositing。状态赋值是同步的，但重建和绘制不是在 `setState()` 调用点立即完成。

**易错点：**

- `setState()` 不是生命周期方法；
- 同一个 `State` 在一帧内重复调用多次没有额外收益；
- 把 CPU 重循环放进 `Future` 后再 `setState()`，重循环仍可能先阻塞主 Isolate。

---

#### 2.1.3、Flutter 常见生命周期有哪些？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- `initState`
- `didChangeDependencies`
- `build`
- `didUpdateWidget`
- `reassemble`
- `deactivate`
- `dispose`

**核心顺序：**

```text
createState
  → initState
  → didChangeDependencies
  → build（可能多次）
  → didUpdateWidget（配置更新时）
  → deactivate（可能重新插回）
  → dispose（永久移除）
```

**答题点：**

- `initState()`：每个 `State` 调用一次，适合初始化控制器和普通订阅；
- `didChangeDependencies()`：在 `initState()` 后调用一次，依赖的 `InheritedWidget` 变化时会再次调用；
- `didUpdateWidget(oldWidget)`：父级提供相同 `runtimeType` 和 `key` 的新配置时调用，随后框架一定会再调用 `build()`；
- `reassemble()`：开发模式热重载时调用，不是生产环境常规生命周期；
- `deactivate()`：节点暂时离树，当前帧结束前仍可能重新插入；
- `dispose()`：永久离树，释放动画、控制器、流和监听；此后 `mounted == false`。

**补充分层：**

- Widget 生命周期、应用前后台生命周期、状态管理控制器生命周期不是一回事；
- GetX 的 `onInit()` 用于初始化，`onReady()` 在 `onInit()` 后一帧触发，`onClose()` 在控制器删除前清理资源；
- 应用前后台状态优先说明 `AppLifecycleListener` 或 `WidgetsBindingObserver.didChangeAppLifecycleState`。

**易错点：**
- 在 `initState()` 中建立对 `InheritedWidget` 的依赖，应改到 `didChangeDependencies()`；
- 把 `setState()` 当生命周期方法；
- 在 `deactivate()` 过早释放所有资源；
- 忘记在 `dispose()` 中取消订阅，或在 `dispose()` 后继续调用 `setState()`。

---

#### 2.1.4、`const` 在 Flutter 里有什么用？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 编译期常量
- 减少重复创建
- 有利于性能
- widget 复用判断

---

#### 2.1.5、Flutter 里常见布局组件？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- `Row`
- `Column`
- `Stack`
- `Expanded`
- `Flexible`
- `Wrap`
- `ListView`

---

#### 2.1.6、`Expanded` 和 `Flexible` 区别？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 剩余空间分配
- 紧约束 / 松约束

---

#### 2.1.7、`ListView.builder` 为什么比直接 children 更合适长列表？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 懒加载
- 按需构建
- 降低内存占用

---

#### 2.1.8、Flutter 里如何做页面跳转？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- `Navigator.push`
- `pop`
- 命名路由
- 路由参数

---

#### 2.1.9、Flutter 网络请求你怎么做？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- `dio`
- 封装
- 拦截器
- 错误处理
- token 注入

---

#### 2.1.10、Flutter 怎么做状态管理？你用过什么？【级别：初级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

### 2.2、中级题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 2.2.1、Flutter 的本地存储方案有哪些？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
见上文扩充版。

---

#### 2.2.2、Future 是不是多线程？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
见上文扩充版。

---

#### 2.2.3、Flutter 中 `async/await` 本质是什么？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 语法糖
- 基于 `Future`
- 挂起当前函数后续逻辑
- 不阻塞主线程同步代码

---

#### 2.2.4、microtask 和 event queue 区别？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- microtask 优先级更高
- event 存放普通异步任务
- 小心 microtask 饥饿

---

#### 2.2.5、为什么用了异步，页面还是会卡？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- CPU 密集型任务仍占主 Isolate
- `Future` 不等于后台线程
- JSON 大解析 / 大循环仍会卡

---

#### 2.2.6、介绍下 Isolate【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
见上文扩充版。

---

#### 2.2.7、Flutter 和 Dart 的关系？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- Flutter 是 UI 框架
- Dart 是语言
- Flutter engine + framework
- Dart 负责业务和运行时逻辑

---

#### 2.2.8、Widget / Element / RenderObject 的关系？【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- Widget：配置
- Element：实例化桥梁
- RenderObject：布局和绘制

**这一题如果能答清楚，明显加分。**

---

#### 2.2.9、`BuildContext` 是什么？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- Element 的抽象引用
- 用于定位树中位置
- 访问依赖和祖先节点

**易错点：**
- 把它理解成页面对象
- 生命周期错位使用

---

#### 2.2.10、你怎么做网络层封装？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- `dio` 二次封装
- 统一 baseUrl
- 拦截器
- token 刷新
- 错误映射
- 泛型解析
- 取消请求

---

#### 2.2.11、你怎么设计缓存策略？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 内存缓存
- 磁盘缓存
- 过期时间
- 读缓存 -> 请求网络 -> 回写
- 离线优先 / 网络优先

---

#### 2.2.12、Flutter 常见性能问题有哪些？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 不必要 rebuild
- 长列表卡顿
- 图片过大
- 过度嵌套
- 主线程重计算
- 动画掉帧

---

#### 2.2.13、如何减少不必要的 rebuild？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- `const`
- 拆小 widget
- 精细状态订阅
- `Selector`
- `Consumer`
- keys 合理使用

---

#### 2.2.14、为什么要做 Repository 抽象？【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 解耦数据来源
- 便于测试
- 可切换远端 / 本地
- 统一业务入口

---

#### 2.2.15、你怎么处理异常和错误提示？【级别：中级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 网络异常分层
- 业务错误码
- UI 友好提示
- 日志 / 上报
- 重试机制

---

#### 2.2.16、如果让你从 0 到 1 搭 Flutter 项目，你怎么设计目录结构？【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
见上文扩充版。

---

#### 2.2.17、你有没有做过 Flutter 调原生、原生调 Flutter？【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
见上文扩充版。

---

### 2.3、高级题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 2.3.1、大型 Flutter 项目怎么做模块化？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

#### 2.3.2、状态管理你怎么选型？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

#### 2.3.3、你怎么做 Flutter 性能优化？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 首帧优化
- 列表优化
- 图片缓存
- 重建控制
- isolate 拆重任务
- DevTools 分析
- shader / jank / memory

##### 2.3.3.1、推荐答法框架 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 先定位：DevTools / Timeline / Memory
- 再分类：build、layout、paint、IO、CPU
- 最后落方案：拆 widget、懒加载、缓存、异步计算

---

#### 2.3.4、Flutter 页面很复杂，如何控制状态膨胀？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 页面状态 vs 业务状态分离
- 单向数据流
- 局部状态下沉
- viewmodel / notifier / bloc 分层

---

#### 2.3.5、你如何做主题系统 / 设计系统？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- design token
- 颜色 / 字体 / 间距统一
- 深色模式
- 业务组件库
- 主题扩展

---

#### 2.3.6、Flutter 混编时，你最关注什么？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 引擎初始化成本
- FlutterEngine 复用
- 页面栈管理
- 生命周期同步
- 通道协议稳定性
- 包体积
- 崩溃定位

---

#### 2.3.7、原生和 Flutter 共存项目，路由怎么设计？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 原生路由表
- Flutter 路由映射
- 参数协议
- 页面返回结果
- 页面栈一致性

---

#### 2.3.8、Flutter 包体积怎么优化？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 资源压缩
- 删除无用依赖
- abi 拆分
- 按需资源
- 图片格式优化
- 字体裁剪

---

#### 2.3.9、如何做埋点、日志、崩溃监控？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 页面埋点
- 行为埋点
- 错误上报
- FlutterError
- Zone
- 平台侧补充日志

---

#### 2.3.10、Flutter 启动慢，你怎么排查？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 首屏链路
- 同步初始化过多
- 资源加载
- 引擎预热
- 延迟初始化
- 分阶段加载

---

#### 2.3.11、Flutter 中你怎么做 CI/CD？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 自动打包
- flavor
- 环境配置
- 自动测试
- 代码检查
- 发版流程
- 符号表管理

---

#### 2.3.12、如果团队里初中级 Flutter 较多，你怎么推进工程规范？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
**关键字：**
- 脚手架
- lint
- code review
- 模板化
- 组件规范
- 通道规范
- 文档沉淀

---

#### 2.3.13、如果让你带一个 Flutter 项目，你最先做什么？【级别：高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

## 三、跨端互调题的速记模板（面试时可直接背） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 3.1、题：你有没有做过跨端的，比如 Flutter 调原生、原生调 Flutter？【级别：中高级】 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 3.1.1、30 秒版本 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> 做过。Flutter 和原生互调我主要用 `MethodChannel` 和 `EventChannel`。  
> Flutter 调原生常见于设备能力、支付、定位、第三方 SDK；  
> 原生调 Flutter常见于页面跳转、登录态同步、推送回传；  
> 设计上我会关注通道协议、参数结构、错误码、生命周期和线程切换。  
> 如果项目复杂，我会把平台通道封装成统一的 `platform service`，上层业务不直接依赖 channel。

#### 3.1.2、60 秒版本 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> 做过，而且我一般不把它当成简单 API 调用，而是当成一层桥接协议。  
> Flutter 调原生，我通常用 `MethodChannel` 调设备信息、相机、蓝牙、支付这类平台能力；  
> 原生调 Flutter，一般是原生入口跳 Flutter 页、推送点击通知 Flutter、登录态同步；  
> 持续事件我会用 `EventChannel`。  
> 工程上我会统一通道命名、参数结构和错误码，避免多个页面各自乱写 channel。  
> 如果是混编项目，我还会考虑 `FlutterEngine` 复用、页面栈和生命周期同步问题。

---

## 四、面试定位判断 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 4.1、这 5 个题说明什么？ <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
这 5 个题整体不是初级面。

#### 4.1.1、偏中级 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- 本地存储方案
- Future 是否多线程

#### 4.1.2、偏中高级 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
- Isolate
- 从 0 到 1 设计目录结构
- 跨端互调

### 4.2、结论 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
> 这更像 **中级偏上 / 中高级** 面试。  
> 面试官在看你是不是“能独立负责项目”，不是只看你会不会写页面。

---

## 五、临场答题原则 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 5.1、原则 1：先给结论，再展开 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
别绕。

错误示范：
> 我觉得这个吧，应该要看情况……

正确示范：
> 结论先说：Future 不是多线程，它是异步结果模型。

---

### 5.2、原则 2：先讲场景，再讲技术 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
面试官更爱听“你怎么用”，不爱听百科。

---

### 5.3、原则 3：关键词要硬 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
比如：
- 单 Isolate
- Event Loop
- message passing
- 单向依赖
- Repository 抽象
- FlutterEngine 复用

这些词说出来，层级马上不一样。

---

### 5.4、原则 4：别装懂 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
尤其是：
- 渲染原理
- Isolate
- Widget/Element/RenderObject
- 混编引擎管理

不确定就说到你能兜住的层级。

---

## 六、冲刺建议 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 6.1、你必须重点背熟的 10 个题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
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

### 6.2、如果只剩 1 天准备 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
优先顺序：
1. Future / Isolate / 事件循环
2. 项目架构 / 目录结构
3. 跨端互调
4. 性能优化
5. 状态管理选型

---

## 七、代码点拨总表（只记关键骨架） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 7.1、Flutter 调原生 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```dart
static const channel = MethodChannel('com.demo/device');
final result = await channel.invokeMethod('getAppVersion');
```

### 7.2、原生回 Flutter <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```dart
channel.setMethodCallHandler((call) async {
  if (call.method == 'onLogin') {
    final args = Map<String, dynamic>.from(call.arguments);
  }
});
```

### 7.3、持续事件 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```dart
const eventChannel = EventChannel('com.demo/network');
eventChannel.receiveBroadcastStream().listen((event) {});
```

### 7.4、Isolate / compute <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```dart
final data = await compute(parseJson, jsonString);
```

### 7.5、microtask 优先级 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```dart
Future(() => print('event'));
scheduleMicrotask(() => print('microtask'));
```

---

## 八、一句话总评 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 这套题不算纯高级面，但已经明显超出“只会写 UI”的范围。
>
> 要拿下这类面试，核心不是死背，而是把 **异步模型、工程结构、跨端互调** 三块讲出独立负责项目的能力。

## 九、并发与帧调度补充 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 本章由原《Flutter面试 2.md》的独有内容蒸馏而来：保留同/异步辨析、Isolate 选型和帧调度，删除与前文重复的基础题及重复跨端代码。

### 9.1、同步 / 异步与单线程 / 多线程不是一回事 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 执行模型 | 是否等待结果 | 直观理解 |
| --- | --- | --- |
| 单线程 + 同步 | 当前任务完成前不能继续 | 洗完衣服后再做饭 |
| 单线程 + 异步 | 发起任务后先处理别的事件，结果就绪后再回调 | 洗衣机运行时去做饭 |
| 多线程 + 同步 | 工作交给另一线程，但当前线程仍阻塞等待 | 找人洗衣服，自己站着等 |
| 多线程 + 异步 | 工作并行执行，当前线程继续处理其它任务 | 找人洗衣服，完成后通知 |

面试时先说结论：

- `async` / `await` 表达的是**异步流程控制**，不等于自动创建线程。
- `Future` 表示一个将来完成的结果；其回调通常仍由当前 Isolate 的事件循环调度。
- 是否真正并行，要看工作是否被放到其它 Isolate、原生线程或操作系统异步 I/O。

### 9.2、事件循环与 Isolate 的边界 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

每个 Isolate 都有独立内存和事件循环；不同 Isolate 不共享可变状态，只能通过消息通信。主 Isolate 上耗时过长的同步计算会延迟点击、动画和绘制事件，导致掉帧。

```text
主 Isolate
├── Call Stack：当前同步代码
├── Microtask Queue：当前事件结束后优先清空
└── Event Queue：Timer、I/O 完成、输入与绘制等事件
```

下面的输出顺序为 `1、4、3、2`：

```dart
void main() {
  print('1');
  Future<void>(() => print('2'));
  Future<void>.microtask(() => print('3'));
  print('4');
}
```

常用选型：

- 普通网络等待、文件异步 I/O：先使用 `Future` / `Stream`，不要为了“异步”机械创建 Isolate。
- 大 JSON 解析、图片处理、压缩加密和大循环计算：评估 `Isolate.run` 或 Flutter 的 `compute`。
- 一次性计算：优先 `Isolate.run`。
- 需要持续收发多条消息的后台工作者：使用 `Isolate.spawn` + `ReceivePort` / `SendPort`，并设计退出、错误和资源释放协议。

```dart
import 'dart:isolate';

Future<int> calculate() {
  return Isolate.run(() {
    var sum = 0;
    for (var i = 0; i < 100000000; i++) {
      sum += i;
    }
    return sum;
  });
}
```

补充边界：Dart Web 不提供与 Dart Native 相同的 Isolate 实现；Flutter Web 中的 `compute` 会在当前事件循环执行，CPU 密集任务应另行评估 Web Worker。

### 9.3、Flutter 业务代码“单线程”不等于引擎只有一个线程 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

日常 Flutter 业务代码主要运行在主 Isolate，包括事件响应、状态更新和 Widget 构建；因此同步阻塞主 Isolate 会直接影响界面响应。

Flutter 引擎内部还会根据平台与渲染后端安排平台、光栅化和 I/O 等执行角色。面试时不要把“主 Isolate 单事件循环”扩大成“整个 Flutter 引擎只有一条线程”。

### 9.4、Flutter UI 按帧调度，`setState` 不会立即完成重建 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

简化后的帧流程：

```text
操作系统 Vsync
  ↓
SchedulerBinding.handleBeginFrame
  ↓
动画等瞬时回调
  ↓
持久帧回调：build → layout → paint
  ↓
post-frame callbacks
```

- `setState` 会立即、同步执行传入的回调，然后把对应 Element 标记为需要重建。
- 真正的 `build` 通常在后续帧流水线中发生；同一帧前对同一 State 的多次脏标记可以合并，但不应把重复调用当成优化手段。
- `addPostFrameCallback` 在本帧持久回调之后执行，而且它本身不会主动申请新帧。
- 帧预算取决于屏幕刷新率：60 Hz 约为 16.67 ms，120 Hz 约为 8.33 ms，不能把“16 ms”写成所有设备的固定值。

```dart
setState(() {
  counter++;
});

WidgetsBinding.instance.addPostFrameCallback((_) {
  // 此时本帧的主要渲染流水线已经完成。
});
```

## 十、官方资料 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- [**Dart 并发与 Isolate**](https://dart.dev/language/concurrency)
- [**Flutter 并发与 Isolate**](https://docs.flutter.dev/perf/isolates)
- [**Flutter 架构概览**](https://docs.flutter.dev/resources/architectural-overview)
- [**State.setState**](https://api.flutter.dev/flutter/widgets/State/setState.html)
- [**SchedulerBinding**](https://api.flutter.dev/flutter/scheduler/SchedulerBinding-mixin.html)
- [**Flutter State 生命周期**](https://api.flutter.dev/flutter/widgets/State-class.html)
- [**Flutter AppLifecycleListener**](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html)

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
