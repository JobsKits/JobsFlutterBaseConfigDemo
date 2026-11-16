# 开发脚本

[Git 拉取后初始化脚本](./【MacOS】⚙️Git拉取Flutter项目到本地以后的必要配置.command) 在项目内执行 `fvm install stable` 和 `fvm use stable --skip-pub-get`，再在无工程的临时目录调用项目实际 SDK 升级，刷新稳定频道缓存；不会顺带升级项目的 `pubspec.lock`。项目 SDK 由 [**FVM**](https://fvm.app/) 管理，不改本机独立全局 [**Flutter**](https://flutter.dev/) SDK，普通运行不自动升级。

## Flutter SDK网络获取

本目录Jobs维护的Flutter/Dart/FVM入口在SDK获取前使用随包`Scripts`模块检测实际来源和候选路线；获取失败自动重测并重试，按Ctrl+C或发送终止信号结束。已有健康SDK直接使用，项目构建、依赖和运行命令只执行一次。明确指定的Flutter源、FVM原仓库及代理配置（包括空值）保留，设置仅对当前任务子进程生效。移动入口时保留同级完整`Scripts`目录；不会写入系统代理或用户Shell配置。
