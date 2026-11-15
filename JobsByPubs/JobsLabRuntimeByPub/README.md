# Jobs Lab Runtime

[Flutter](https://flutter.dev/) 功能实验室的可复用运行时，宿主依赖使用相对路径，包自身不依赖主工程。

| API | 演示能力 |
| --- | --- |
| `JobsLabSandbox` | 按应用与账号命名空间持久化，拒绝绝对路径、编码后的越界路径；同一空间串行写入 |
| `JobsLabBridge` | 显式方法白名单、应用能力授权、结构化响应 |
| `JobsLabPatchRegistry` | 校验配置补丁、应用及回滚；原生方法替换见 `jobs_platform_lab` |
| `JobsLabCodec` | Unicode GZIP、Base64、随机盐与 AES-GCM 验证加密 |
| `JobsLabRecordStore` | 对象记录持久化、查询、新增、修改、删除 |
| `JobsLabTimerHub` | 多个可独立开始、暂停、重置、删除的计时器，共用底层调度 |
| `validateCNID18` | 地区码、实际生日、顺序码和校验位检查 |

```yaml
dependencies:
  jobs_lab_runtime:
    path: ./JobsByPubs/JobsLabRuntimeByPub
```

公共包资源通过 `packages/jobs_lab_runtime/assets/catalog.json` 访问，独立命令入口为 `bin/jobs_lab_runtime.dart`。实际页面在宿主 `lib/demos/中文功能名/`，统一支持独立启动、十语与主题切换。

验证：宿主 `test/lab_runtime_test.dart` 覆盖跨空间隔离、并发写入、白名单拒绝、补丁回滚、校验边界、压缩、密文篡改、CRUD 与计时生命周期。
