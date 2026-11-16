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

<a id="🔚" href="#前言">返回前言</a>
