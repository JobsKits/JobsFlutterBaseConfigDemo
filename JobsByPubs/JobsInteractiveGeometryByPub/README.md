# JobsInteractiveGeometryByPub

Jobs 自写的 Flutter 交互几何包，供演示页和业务控件复用。运行依赖仅为 Flutter 和 `vector_math`，无网络、私有包、图片或字体依赖。

| API | 用途 |
| --- | --- |
| `ArcGeometry` / `JobsArcSlider` | 任意旋转和缺口的圆弧进度、指针反解、键盘与无障碍增减 |
| `HysteresisGate` / `JobsNeonSlider` | 独立迟滞状态机与可控闪光滑块，触发后必须低于复位阈值才重新就绪 |
| `SpiralGeometry` | 螺旋位置、四顶点透视、远近排序及逆绘制顺序命中 |
| `CanvasTransform` | 平移、旋转、缩放矩阵及屏幕坐标到局部坐标反解 |
| `ParticleSystem` | 经纬球、Fibonacci 均匀球面、立方体、圆环、心形、Lorenz / Aizawa 吸引子 |
| `SurfaceGeometry` | 可调分辨率的波动网格与扰动面片球，返回可自绘拓扑 |
| `JobsGeometryClock` | 暂停、系统减弱动画、后台和 `TickerMode` 统一管理；恢复时不累积后台时间 |
| `JobsGeometryLabLayout` / `JobsGeometryParameter` | 窄屏纵向滚动、宽屏左右布局及键盘可调参数 |

```dart
JobsArcSlider(
  value: progress,
  semanticLabel: label,
  geometry: const ArcGeometry(gap: 2.1, rotation: 1.57),
  onChanged: (value) => setState(() => progress = value),
)
```

粒子质量档分别为 200 / 700 / 1600 点。球面使用经纬采样，Fibonacci 使用黄金角采样；固定种子的随机分布可复现。Lorenz 参数为 σ=10、ρ=28、β=8/3，Aizawa 参数为 a=.95、b=.7、c=.6、d=3.5、e=.25、f=.1。吸引子采用有界 Euler 子步（单步不超过 .005 秒，每帧最多推进 .05 秒），遇到非有限值或发散至绝对值 1000 时重置该粒子并统计次数，适合交互可视化。

包不持有页面的主题和语言状态，文案通过调用方传入；示例页沿用宿主 `JobsDemoApp` 的三种主题和十种语言。动态画面提供暂停与单步，系统减弱动画时仍可手动查看变化。

在宿主根目录运行限定验证：

```sh
./.fvm/flutter_sdk/bin/flutter test --no-pub JobsByPubs/JobsInteractiveGeometryByPub/test/geometry_models_test.dart test/geometry_curated_test.dart
```
