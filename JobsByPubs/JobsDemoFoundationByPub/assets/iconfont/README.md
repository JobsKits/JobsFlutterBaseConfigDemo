# <span id="前言">JobsIconfont 资源来源</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

本目录供 Flutter 与现有 OC／Swift Demo 功能平行使用。图片先显示本地随包副本，随后请求对应官方 URL；网络失败保留本地图片。`invalidURL` 测试项固定回退到本地 Logo。

| 资源 | 官方来源 |
| --- | --- |
| logo.png | https://img.alicdn.com/imgextra/i4/O1CN01XZe8pH1USpiUNT1QN_!!6000000002517-2-tps-114-114.png |
| font-banner.png | https://img.alicdn.com/imgextra/i1/O1CN01vqHHzA1JvGYdLg5KV_!!6000000001090-2-tps-2280-452.png |
| usage-guide.png | https://img.alicdn.com/tfscom/T1R3VxFuRnXXaCwpjX.png |

相邻 `fonts/JobsIconfontSample.ttf`、`fonts/AlimamaShuzhiti-Regular.ttf` 与 `fonts/JobsIconfontCatalog.json` 原样复用现有 Swift 自有 `JobsIconfont@Pods/Resource`，字体及上游 CSS／字体 URL 的原始记录保留在该 catalog。业务使用 `JobsIconfontGlyph`／`JobsIconfontAsset`，不散布 Unicode 和资源文件名。

`JobsIconfont-Code-LICENSE.txt` 为原生 JobsIconfont **代码**的 MIT 许可。字体、图标和图片的授权以 iconfont／Alibaba 官方来源与项目原有授权为准；该代码许可不改变资源权利归属。本次未发布或向公共仓库推送资源。

2026-11-14 校验的文件大小和 SHA-256 见 `provenance.json`。离线运行不依赖上述 URL 可用；图片请求4秒超时，缓存只写 `jobs.iconfont.*` 命名空间，清理不影响其它业务数据。

<a id="🔚" href="#前言">返回首页</a>
