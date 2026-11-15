# 通知图标来源

通知 small icon 使用 [Google Material Icons notifications](https://github.com/google/material-design-icons/blob/master/src/social/notifications/materialicons/24px.svg)，Apache 2.0 许可见同目录 LICENSE。先检索 iconfont，未取得可追溯且适配 Android small icon 的明确资源后，使用官方源。

SVG 保留官方路径；Android VectorDrawable 使用相同 pathData，由系统渲染为通知所需的单色前景。运行时只引用本地 ic_jobs_notification，不加载网络图片。App备用图标另从既有 Swift 工程的四个 JobsAlternateIcon 资源原样复用。
