# CI Flutter SDK 获取

该包由本仓GitHub工作流和`../verify.zsh`调用，固定版本与架构仍由工作流声明。只写`RUNNER_TEMP`及GitHub本job的`GITHUB_PATH`、`GITHUB_ENV`，不改系统Flutter、Shell或代理。

SDK归档先经随包公共core核验精确版本、架构、可信发布SHA和已有网络路线，再持续下载；同SHA身份可续传，摘要错误保留副本，完整校验及Flutter/Dart必要文件检查后原子发布。同版本/架构/SHA的本job可信SDK可复用。显式源、Pub与代理（含空值）保留，AUTO可在官方／CFUG公开等价对象与现有代理间择优。

`verify.zsh`仅在SDK获取阶段重试：machine输出先写私有临时文件，成功后发布；iOS构建前独立补齐平台制品。分析、测试、依赖与App构建不因失败重复。SDK内部不设重试总次数，但GitHub工作流原60分钟作业预算、步骤预算和用户Cancel仍有效，取消会停止本次下载子树。

隔离回归在同级`Tests/PrepareFlutterSdkTests.rb/`，使用临时假SDK与假网络，不安装真实环境。
