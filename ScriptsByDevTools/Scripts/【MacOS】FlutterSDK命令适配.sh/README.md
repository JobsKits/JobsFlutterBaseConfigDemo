# Flutter SDK命令适配

用法：`/bin/sh 本脚本 原SDK命令 参数...`。保留原解释器、stdin与参数；FVM安装使用公共两阶段接口，普通Flutter/Dart命令先补齐所属SDK，再执行原业务一次。SDK网络设置仅作用于子进程。安装/升级Flutter cask时从Brew JSON读取真实URL，Brew继续负责原始URL和摘要校验。

同级`FlutterSDK网络选路.zsh`提供真实制品样本探测、任务缓存、失败重测和取消清树；此适配器不写用户Shell环境。目录应随原入口整体复制。

Brew原URL尚未知时，仅对原始`brew info`元数据查询做有界获取与持续退避，不猜API/tap来源；明确不存在cask、权限、磁盘或格式错误停止。SDK payload随后单独测路。`flutter upgrade`使用公共组合接口：目标频道新制品选路后，在同一子进程网络环境检查SDK真实Git跟踪源，再升级；自定义分支只使用代表制品，不更换用户分支。

`--official-archive stable 输出文件`仅取得manifest精确版本/架构并校验SHA256的官方SDK归档，解压留给入口一次执行；`--releases`读取原SDK发布清单；`--brew-dart brew install|upgrade`只维护既有FVM前置Dart formula，从Brew当前bottle或source元数据读取供应商URL，无法完成原鉴权预检时明确降级原通道继续实际获取，不假称已验证payload。Dart返回0还须验证原生入口。`channel`先测原SDK Git目标ref，后续upgrade单独测新制品。

所有FVM首次执行前（包括metadata/context/version）先用公共`--fvm-runtime`核验真实外部Dart依赖，只有冷Flutter Dart shim需要SDK预备；Mach-O、独立原生Dart及健康缓存免网，取消原码返回。仅`dart pub global activate fvm`属于SDK前置工具包获取，会持续重试并验证原缓存入口；普通Dart项目命令一次执行。完整资源包含同级SDK获取重试模块。

**终端配色保护：** 独立运行时，在支持完整保存与恢复配色的交互终端中临时使用黑底白字及统一强调色；正常结束、失败或可捕获中断后恢复进入前的配色，不修改终端全局偏好或 Shell 启动配置。不支持完整保护、无交互终端、`NO_COLOR`、既有纯文本模式和 Sourcetree 场景不切换配色，并沿用纯文本输出约定。强制终止（如 `kill -9`）无法由脚本自身保证恢复，请使用运行时显示的独立恢复入口。

