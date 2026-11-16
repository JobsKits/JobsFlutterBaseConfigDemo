# Jobs 刷新提示音

三个WAV均为Jobs原创数学合成，2026-11-16生成，无外部采样或第三方音频；不复制原生Sound.wav或业务spin.mp3。

| 文件 | 音高／时长 | 用途 |
| --- | --- | --- |
| `refresh_started.wav` | 660Hz，65ms | 用户有效触发刷新／加载 |
| `refresh_succeeded.wav` | 660Hz→880Hz，130ms | 操作完成 |
| `refresh_failed.wav` | 330Hz→220Hz，130ms | 操作失败 |

格式为22050Hz、单声道、16位PCM，使用正弦包络避免边缘爆音。生成公式与WAV字段见[refresh_feedback.dart](../../lib/src/refresh_feedback.dart)的`jobsRefreshCue`。原生Darwin播放器当前不支持字节源，运行时通过包资源前缀及`AssetSource`准备本地音频URL；不请求网络。

播放音量0.3，iOS使用ambient会话并混合其它音频，遵循设备静音与音量；声音和触觉分别由全局设置关闭。首屏自动请求保持安静，后台、覆盖路由与销毁后不补放反馈。平台没有触觉或音频能力时保留可见状态；真实听感／触感需要实际设备验收。
