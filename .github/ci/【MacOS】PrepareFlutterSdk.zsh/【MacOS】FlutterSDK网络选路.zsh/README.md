# Flutter SDK 网络选路

此目录是自含 MacOS zsh 模块，可整体复制到独立脚本包，也可将 `JOBS_FLUTTER_ROUTE_BEGIN` / `END` 内函数原样嵌入单文件。没有运行时仓库绝对路径依赖；依赖 MacOS 自带 zsh、curl、JXA、Git、scutil、Perl 和基础命令。只处理环境准备，不调用业务构建。

## 调用契约

- `jobs_flutter_sdk_retry 标题 日志 SDK根 目标版本 命令 参数…`：SDK获取失败持续重试，失败后使选路缓存失效并重新检测；Ctrl+C / TERM / HUP 只清理本轮自有子树。调用方只传 `fvm install/use`、`flutter --version/precache/upgrade` 或可重复执行的SDK下载步骤，不能包装整个业务构建。
- `jobs_flutter_sdk_once 标题 日志 SDK根 目标版本 命令 参数…`：网络准备等待可用路线，真实命令只执行一次，原码返回。普通 pub/run/analyze/build 应先单独准备SDK，再通过此接口运行一次。
- `jobs_flutter_route_prepare SDK根 目标版本 日志 [dart|platform|archive|git|source]` 是低层接口，成功后导出当前进程的选路环境。它只供已在子进程内的调用方使用，不能直接在用户交互Shell顶层调用。`jobs_flutter_route_invalidate` 仅移除本模块本次路线缓存，不清SDK或下载片段。
- 普通wrapper在父层只管理私有缓存路径，网络选路和SDK命令都在子进程内，返回后不遗留SDK源或代理到用户Shell。stdin、stdout和逐个参数保留；提示走stderr，机器输出不混入探测日志。
- SDK根或版本可为空：优先从命令实际 `bin/flutter`、工程 `.fvm/flutter_sdk` 或PATH发现；目标身份来自本地元数据，不能从目录名猜版本。函数封装命令请直接传已知SDK根。

`dart` 为默认模式：目标Engine与当前Dart stamp一致且原生Dart存在时复用健康环境，不联网测速。`platform` 在拉平台资源前检测SDK制品路线。`archive` 按官方发布清单精确匹配版本与宿主架构，并保留发布SHA。后三者只在Google官方／CFUG等价SDK制品间选择，不能把结果用于Git或安装器。

`git` 保持 `JOBS_FLUTTER_ROUTE_SOURCE_URL` 原repo，向当前版本的目标ref执行有界 `ls-remote`，比较已知网络路线；可设置 `JOBS_FLUTTER_ROUTE_GIT_REF`。`source` 保持该变量中的原始安装器URL，验证真实小正文及错误页；可用 `JOBS_FLUTTER_ROUTE_EXPECTED_TEXT` 提供必须存在的正文标记。两者均不替换repo/URL，不写Git配置。`fvm install` 支持 `--no-setup` 时应先分离Git获取，再对所装SDK的 `--version` 初始化做制品检测；旧FVM组合通道需明确说明，不能声称下游已按另一来源测速。

## POSIX / Bash 入口

保留原解释器与交互，只把准备和SDK命令转给包内模块；不要用heredoc抢走SDK命令stdin：

```sh
JOBS_ROUTE_CACHE_DIR="$(/bin/zsh ./【MacOS】FlutterSDK网络选路.zsh --cache-dir)" || exit $?
JOBS_FLUTTER_ROUTE_CACHE_DIR="$JOBS_ROUTE_CACHE_DIR" \
  /bin/zsh ./【MacOS】FlutterSDK网络选路.zsh \
  --run '准备SDK' './本轮日志.log' './SDK目录' '3.38.4' './SDK目录/bin/flutter' --version
```

CLI还支持 `--once`（参数相同）及 `-- 命令 参数…`（从 `JOBS_FLUTTER_ROUTE_SDK_ROOT` / `VERSION` / `LOG` 读取上下文）。实际入口应以自身位置解析包内模块，不能依赖启动目录。多次CLI调用共用上述本任务私有缓存目录；zsh函数调用自动保留任务缓存。

## 策略与边界

- 所有显式SDK源与代理key包含“已设置为空”均优先保留；Pub源不因SDK测速被替换。没有显式代理时，候选来自当前启用的scutil HTTP / HTTPS / SOCKS配置，包括企业LAN及已有远程代理；不猜端口、不扫描新代理、不增加未知公共代理。已有curl代理配置或Git有效代理保持原工具语义。
- SDK候选使用不超过256KiB的真实Range响应，连接2秒、单候选6秒并发检测，核对206、对象总长、官方对象MD5/ETag、ZIP主体及具体版本/架构。足够的有效部分样本可参与慢速比较；错误页、整包200和不匹配对象不算可用。Git元数据与安装器正文按各自来源检测，不冒充SDK制品吞吐。
- 通过输入指纹复用本任务300秒内路线，显式配置、版本、Engine或架构变化失效；SDK下载失败立即失效并重测。没有可验证路线就持续退避检测，不进入SDK或业务。
- 源、指标、选择理由与注入范围写入脱敏日志，原始探测文件保存在700权限的本任务临时目录。只给当前SDK子进程注入环境，不修改系统代理、全局launchd、Shell启动文件或Git持久配置；退出目标进程、按原入口启动即可撤回。
- 本模块仅选择路线。完整分发仍须按发布SHA / SDK工具原有摘要校验，目标版本展示与真实安装验收分别进行。


## 原源、离线镜像与调用补充

- `--fvm-install 标题 日志 FVM命令 版本 [install原参数…]` 在支持 `--no-setup` 时分开检测原Git来源和SDK制品，再补齐目标Dart；显式 `--no-setup` 保留仅获取源码的意图。上下文仅管道筛选来源与缓存路径，不保存包含环境的完整JSON。
- `--flutter-upgrade 标题 日志 SDK根 请求channel [原完整upgrade命令…]` 保留SDK原remote/ref，在同一选中环境核对Git后升级；私有分支的现有engine样本明确只代表制品网络通道。
- Google摘要不可达时，公开标准对象允许已获准CFUG相同版本/engine/架构路径验证，日志明确没有官方摘要核验。未知公开性的fork、自定义engine或realm只保留原源；显式选择的自定义源按用户授权使用。realm读取SDK本地 `bin/cache/engine.realm`，不删减命名空间。
- 小样本最快的AUTO路线若真实获取失败，冷却60秒并优先轮换其它已验证路线；显式配置不被轮换覆盖。全部不可达则持续退避重测，直到成功或用户中断。
- `JOBS_FLUTTER_ROUTE_CURL_CONFIG` 可传调用方已经使用的curl配置文件；探测保留配置且缓存含内容摘要。`JOBS_FLUTTER_ROUTE_PREPARE_ONCE=1` 仅供本身已有持续重试/双栈回退的上层使用：单轮不可达返回75，默认仍无限自动重测。
- `JOBS_FLUTTER_ROUTE_CAPTURE_OUTPUT=1` 供直接SDK命令追加日志并保留stdout/stderr；已经自行记录日志的回调不要启用，防止重复捕获。普通业务使用 `--once`，SDK准备和业务执行分开，业务失败不重放。


## 管理器运行时与取消

`jobs_flutter_fvm_runtime 标题 日志 FVM命令`（CLI `--fvm-runtime` 同参数）只在静态确认文本FVM入口依赖外部PATH Dart，且该Dart真实解析为Flutter的bin/dart shim时，先准备这一管理器实际运行时；MachO/AOT、独立Dart及engine stamp匹配的健康原生Dart直接复用。返回stdout保持空，日志/SDK进度走stderr，取消原码阻断后续FVM metadata。未知自改PATH或本地dart函数/alias的wrapper不猜运行依赖。

公共wrapper仅在LOCAL_OPTIONS作用域关闭NOUNSET，返回后保留调用方选项。取消及单次超时只停止本轮自有树：先STOP父进程防止子下载失败后重生，再停止子树并KILL；调用方wait回收自己的子进程。已有其它SDK写入者只等待，不会被STOP或终止。
