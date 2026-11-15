# 演示公共包藏文字体

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、来源与许可](#source)
- [二、包内接入](#integration)
- [三、验证方式](#verification)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

[Noto Serif Tibetan](https://fonts.google.com/noto/specimen/Noto+Serif+Tibetan) 为演示公共包提供本地藏文字形，覆盖全局语言选择中的 `བོད་ཡིག` 及藏文业务文案。字体随包打包，运行时不从网络下载。字体文件保留上游原始内容，未作裁剪或字形修改。

## 一、<span id="source">来源与许可</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 文件 | 来源与用途 |
| --- | --- |
| [NotoSerifTibetan-Regular.ttf](./NotoSerifTibetan-Regular.ttf) | 官方 Google Fonts 服务提供的 Regular／400 TrueType 字体 |
| [OFL.txt](./OFL.txt) | Noto Project Authors 的 SIL Open Font License 1.1 原文，随字体分发 |

字体下载地址来自 [Google Fonts 官方样式接口](https://fonts.googleapis.com/css2?family=Noto+Serif+Tibetan:wght@400&display=swap) 返回的 [fonts.gstatic.com 固定资源](https://fonts.gstatic.com/s/notoseriftibetan/v24/gokGH7nwAEdtF9N45n0Vaz7O-pk0wsvxHeDXMfqguoCmIrYcPS4.ttf)。许可取自 [Google Fonts 官方仓库固定提交](https://github.com/google/fonts/blob/8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5/ofl/notoseriftibetan/OFL.txt)。字体项目主页为 [Noto Tibetan](https://notofonts.github.io/tibetan/)。仓库固定提交用于许可来源追溯，实际字体为上述官方字体服务的静态 Regular 文件。

| 文件 | SHA-256 |
| --- | --- |
| `NotoSerifTibetan-Regular.ttf` | `f94e3bde2a13ec085793d1ff2d97f8dd58960df0aeb92c65afad276fa4a57c15` |
| `OFL.txt` | `0077789fc3cb20f358278ba4c6437eb14ade97d4d3e3281eaa42853efcd9dc8b` |

## 二、<span id="integration">包内接入</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

[包配置](../../pubspec.yaml)在 `flutter.fonts` 下声明 `NotoTibetan`，不要求宿主重复声明或复制字体。[公共主题](../../lib/src/demo_app.dart)统一提供包命名空间回退：

```dart
fontFamilyFallback: const ['packages/jobs_demo_foundation/NotoTibetan'],
```

主工程、白天与黑夜主题、全局设置和独立 Demo 预览均消费此回退；已有拉丁文字字体和系统主题继续按默认字体优先匹配。系统控件的藏文翻译可用性由本地化委托决定，字形覆盖与控件翻译属于不同能力。

## 三、<span id="verification">验证方式</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

`file` 和 `fc-scan` 可检查字体格式、家族、样式及字符集。已核对语言名所用藏文字形与公共词库中的藏文码点均被字体覆盖。重新构建后应检查产物 `FontManifest.json` 中的 `packages/jobs_demo_foundation/NotoTibetan` 条目与对应本地字体资源，再在真实 Web 或设备界面观察藏文显示；仅检查源码声明不能代替实际渲染验收。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
