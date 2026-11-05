# SDK 网络资源

本目录随相邻入口整体复制，包含[命令适配](./【MacOS】FlutterSDK命令适配.sh/README.md)与[网络选路](./【MacOS】FlutterSDK网络选路.zsh/README.md)。入口确认之后才调用；健康SDK复用，缺失环境先准备，SDK获取失败持续重试，真实业务只执行一次。日志位于本任务系统临时目录，Ctrl+C可终止；不改系统代理、Shell启动文件或全局Git配置。
