# Demo 源码目录整理

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、迁移盘点](#inventory)
- [二、行为与验证合同](#behavior)
- [三、本批验证](#validation)
- [四、独立文件启动入口](#file-launchers)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

2026-11-16，按用户要求移除 `lib/demos` 下的 `入口.dart` 和 `源码/` 中间层，独立启动函数与实现源码放在一起。只调整目录、入口和引用，功能 ID、默认值、持久化键及页面生命周期保持原有合同。

## 一、<span id="inventory">迁移盘点</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 范围 | 迁移前 | 目标 |
| --- | --- | --- |
| 纯转发入口 | 175 份 `入口.dart`，仅导出实现并委托 main | 已删除；登记和导入直接指向真实实现 |
| 含实现的入口 | 46 份 `入口.dart`，自身包含实际页面和 main | 已按功能目录名称命名，例如 `朋友圈浏览/朋友圈浏览.dart` |
| 源码目录 | 175 个 `源码/`，共 263 个文件 | 已上移一层并移除空目录；三份生成 part 文件内容字节保持 |
| 重名检查 | 上移目标无已存在文件、无重复目标 | 已完成309文件无覆盖迁移 |
| 兼容与依赖 | 旧 `lib/JobsDemoTools` 转发、跨功能导入、part、目录登记、测试和文档 | 已更新587文件；相对URI按迁移前后文件位置重新计算，不保留已删除入口的占位文件 |

## 二、<span id="behavior">行为与验证合同</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

- 首页 `sourcePath`、`entryPath` 指向真实实现；实现头注提供可复制的项目相对运行命令，main 放在导入和 part 指令之后。
- 辅助文件不新增 main；纵向分页等有独立配置的实现保留自己的启动与页面构造。
- 三主题、十语、服务端请求与本地回退、空态和页面资源继续复用原实现，不借目录调整改业务。
- 源码修改前已盘点并保存原文快照；迁移、全量引用及AST核对、主工程测试已完成，构建状态按下表单独登记。历史验证不能代替本批结果。

## 三、<span id="validation">本批验证</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 验证 | 结果与边界 |
| --- | --- |
| 工具链 | FVM `stable` 实际为 Flutter3.50.0／Dart3.14.0；未升级SDK或业务依赖 |
| 路径与登记 | `lib/demos` 下 `入口.dart`、`源码/` 均为零；全部项目内Dart import／export／part目标存在，189个legacy ID及序列与快照一致 |
| 源码语义 | 当前302个含main源码均以main作为指令区之后首个声明；该数量包含OCR验收源码，不等于首页功能数。309份迁移实现的AST正文声明保持，仅一处“选择入口.dart”说明改为“选择本文件”；三份生成part的SHA256逐字节一致 |
| 测试 | 目录阶段704项通过、1项截图测试跳过；合入本批OCR交互后的最终主工程 `flutter test --no-pub` 为710项通过、2项显式截图测试跳过（4分22秒）。300个目录builder共用动作入口回归通过，299个前批基线ID保持 |
| 静态分析 | JobsRefreshByPub沿同类本地包补`publish_to: none`后，全工程0 error、0 warning、700兼容info；`flutter analyze --no-pub --no-fatal-infos`退出0，不屏蔽warning或error |
| Web | JavaScript release构建通过，36.0秒；未启用Wasm，SDK试探Wasm时提示旧web库不兼容，不作为Wasm构建通过 |
| iOS | OCR源码SDK与交互合入后，官方FVM主入口Simulator Debug无签名构建通过，Xcode394.4秒，实际使用官方SPM缓存；823份Dart源码及核心归档构建前后SHA一致。随后同一新包从首页进入OCR，真实识别35行／367ms，浅深、整页滚动及全文复制实际通过；本机相机后置镜头不可用提示关闭后原图／结果保留，物理拍照待真机；不扩展为300项设备业务验收 |

本批没有暂存、提交、推送或改写Git历史。旧 `docs/旧功能源码迁移.json` 的历史target／entry／hash与 `项目相关报告/验收记录/` JSON保留，只更新当前指针；原始构建／交互证据不由目录迁移重新命名。

最终构建、分析、710项测试、823份源码指纹与新Kernel哈希见[本批最终验证清单](./验收记录/2026-11-16-Flutter目录与OCR交互最终验证/manifest.json)；原始日志同目录保存。源码／构建通过、生产界面实看和真实模型推理分别记账。

2026-11-17的[当前生产OCR实屏摘要](./验收记录/2026-11-17-Flutter生产OCR实屏/summary.json)及[资产盘点第五节](./Rust-OCR集成资产盘点.md#production-ui)补充同一新包的有限UI与真实样本验证；构建阶段的历史清单保留原时点状态。

## 四、<span id="file-launchers">独立文件启动入口</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

2026-11-17确认：每个Demo的实际实现源码应可独立启动；支持终端 `frun` 等待手动输入／拖入文件，以及右键 `.dart` 从终端运行。各方式均以所属工程为构建上下文、所选源码为 `-t` 目标，不改写主入口，不新建临时Flutter工程。

| 资产 | 入口与行为 | 默认／持久化／生命周期 | 实现与验证状态 |
| --- | --- | --- | --- |
| 目录Demo | 9个catalog共300个注册项，300唯一ID；`sourcePath`与`entryPath`同指真实含main实现 | 沿用每个Demo原主题、十语、数据与设备合同；没有新增偏好键 | 本轮AST静态核查全部存在且有顶层main，解析错误0；没有修改Demo源码，不将此核查等同300项设备实跑 |
| Dart源码范围 | `lib/demos`共412个Dart：302个顶层main、110个辅助文件 | 另两个main为OCR验收入口与长按录制独立目标；helper／part／生成文件不作为可运行入口 | 全部302个main均为导入／part指令后首个声明；计数依据与逐文件结果见[审计清单](./验收记录/2026-11-17-Demo独立启动/audit.json) |
| 终端命令 | `frun`无参等待路径；带参直接选定；`--dry-run`只读解析；`--`后透传Flutter参数 | 路径向上定位最近pubspec；优先工程FVM；SDK先准备，实际Flutter直连终端执行一次；退出目标后继续等待 | [终端环境工程](<../../../JobsGenesis/JobsConfigOS/🌍JobsMacEnvVarConfigs/README.md>)源码及本机新增命令已部署，源码cmp一致、新登录shell可发现；300入口只读通过、110个helper全部拒绝，实际启动结果见下文 |
| 系统右键 | 含main的单个`.dart`显示“从终端运行 Flutter Demo”；项目目录保留原项目运行 | 所选target贯穿菜单、宿主、运行器及后台会话标识，避免相同工程不同Demo误重连 | [双端菜单工程](<../../../JobsGenesis/OS@Extension/README.md>)源码已接入、隔离验证按[菜单资产表](<../../../JobsGenesis/OS@Extension/项目相关报告/Flutter-Demo独立运行资产盘点.md>)记录；本机菜单安装态未更新，真实Finder／Windows菜单待更新后验收 |

使用方法见[终端与右键运行独立源码](../docs/功能实验室.md#standalone-file-run)。本节仅记录启动入口，不改变前面目录迁移的历史验证结论。

本轮终端实测：新终端从`/tmp`执行已安装`frun`，先等待路径，提交带引号的实际源码后直接启动项目FVM；胶囊Demo Web Debug编译16.8秒，HTTP200，单键`h`响应完整帮助、单键`q`使Flutter退出0并重新进入等待状态，再`q`回车结束命令0。修正了SDK包装经管道运行造成键盘控制失效的问题，最终实际业务直接连接TTY。未连接浏览器，不记UI或热重载业务验收。现有`test/source_entry_test.dart`两项通过；没有修改Demo源码，没有执行全量构建／全量测试。证据为[全部入口只读结果](./验收记录/2026-11-17-Demo独立启动/frun-all-entry-dry-run.json)、[helper拒绝结果](./验收记录/2026-11-17-Demo独立启动/frun-helper-rejection.json)、[真实运行摘要](./验收记录/2026-11-17-Demo独立启动/frun-real-run.json)及同目录日志。

<a id="🔚" href="#前言">返回前言</a>
