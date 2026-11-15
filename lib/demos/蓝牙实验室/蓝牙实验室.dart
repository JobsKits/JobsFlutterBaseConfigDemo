import 'package:flutter/material.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: BluetoothLabDemo()));

class BluetoothLabDemo extends StatefulWidget {
  const BluetoothLabDemo({super.key});
  @override
  State<BluetoothLabDemo> createState() => _BluetoothLabDemoState();
}

class _BluetoothLabDemoState extends State<BluetoothLabDemo> {
  final state = NativeLabState('ble');
  final queue = JobsBleCommandQueue();
  final trace = JobsBleTrace();
  final device = TextEditingController();
  final service = TextEditingController();
  final characteristic = TextEditingController();
  final bytes = TextEditingController(text: '01 02 03');
  final name = TextEditingController();
  final traceSource = TextEditingController();
  final found = <String, Map<String, dynamic>>{};
  final services = <Map<String, dynamic>>[];
  bool mockMode = false;
  late final mock = JobsMockBlePeripheral(
    onEvent: (event) {
      state.value = event;
      state.add(event);
    },
  );
  bool reconnect = false;
  bool duplicates = false;
  bool notify = false;
  @override
  void initState() {
    super.initState();
    state.addListener(update);
  }

  void update() {
    final value = state.value;
    if (value is Map && value['event'] != null) trace.append('event', value);
    if (value is Map && value['device'] is Map) {
      final d = Map<String, dynamic>.from(value['device'] as Map);
      found[d['id'].toString()] = d;
    }
    if (mounted) setState(() {});
  }

  Map<String, dynamic> get args => {
    'id': device.text.trim(),
    'service': service.text.trim(),
    'characteristic': characteristic.text.trim(),
  };
  Future<void> discover() async {
    final result = await state.run('ble.discover', args);
    if (result is List && mounted) {
      setState(() {
        services.clear();
        services.addAll(result.map((e) => Map<String, dynamic>.from(e as Map)));
      });
    }
  }

  @override
  void dispose() {
    queue.cancelPending();
    state.removeListener(update);
    state.dispose();
    for (final c in [
      device,
      service,
      characteristic,
      bytes,
      name,
      traceSource,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '蓝牙实验室',
    state: state,
    children: [
      SwitchListTile(
        title: Text(platformText(context, '模拟蓝牙设备')),
        value: mockMode,
        onChanged: (v) {
          setState(() {
            mockMode = v;
            found.clear();
            services.clear();
            device.text = v ? JobsMockBlePeripheral.id : '';
            service.text = v ? JobsMockBlePeripheral.service : '';
            characteristic.text = v ? JobsMockBlePeripheral.characteristic : '';
            state.executor = v ? mock.handle : null;
          });
        },
      ),
      TextField(
        controller: name,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: platformText(context, '搜索功能')),
      ),
      SwitchListTile(
        title: Text(platformText(context, '重复广播')),
        value: duplicates,
        onChanged: (v) => setState(() => duplicates = v),
      ),
      SwitchListTile(
        title: Text(platformText(context, '自动重连')),
        value: reconnect,
        onChanged: (v) => setState(() => reconnect = v),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          nativeButton(context, state, '平台能力', 'ble.state'),
          nativeButton(context, state, '扫描', 'ble.scan', {
            'name': name.text,
            'duplicates': duplicates,
            'seconds': 10,
          }),
          nativeButton(context, state, '停止', 'ble.stopScan'),
        ],
      ),
      for (final d in found.values)
        ListTile(
          title: Text(d['name'].toString()),
          subtitle: Text('${d['id']}\nRSSI ${d['rssi']}'),
          onTap: () => setState(() => device.text = d['id'].toString()),
        ),
      if (found.isEmpty)
        JobsEmptyState(
          title: platformText(context, '无数据'),
          message: platformText(context, '真实设备'),
          onReload: () => state.run('ble.scan', {'seconds': 10}),
        ),
      TextField(
        controller: device,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: platformText(context, '设备标识')),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          nativeButton(context, state, '连接', 'ble.connect', {
            'id': device.text,
            'autoReconnect': reconnect,
          }),
          nativeButton(context, state, '断开', 'ble.disconnect', args),
          FilledButton.tonal(
            onPressed: discover,
            child: Text(platformText(context, '发现服务')),
          ),
          nativeButton(context, state, 'MTU', 'ble.mtu', args),
          nativeButton(context, state, '协商MTU', 'ble.requestMtu', {
            ...args,
            'mtu': 185,
          }),
          nativeButton(context, state, 'RSSI', 'ble.rssi', args),
        ],
      ),
      for (final s in services)
        ExpansionTile(
          title: Text(s['uuid'].toString()),
          children: [
            for (final c in s['characteristics'] as List)
              ListTile(
                title: Text(c['uuid'].toString()),
                subtitle: Text(c.toString()),
                onTap: () => setState(() {
                  service.text = s['uuid'].toString();
                  characteristic.text = c['uuid'].toString();
                }),
              ),
          ],
        ),
      TextField(
        controller: service,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: platformText(context, '服务UUID')),
      ),
      TextField(
        controller: characteristic,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: platformText(context, '特征UUID')),
      ),
      TextField(
        controller: bytes,
        decoration: InputDecoration(labelText: platformText(context, '写入十六进制')),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          nativeButton(context, state, '读取', 'ble.read', args),
          FilledButton.tonal(
            onPressed: () async {
              try {
                final data = bytes.text
                    .split(RegExp(r'\s+'))
                    .where((s) => s.isNotEmpty)
                    .map((s) => int.parse(s, radix: 16))
                    .toList();
                if (data.any((v) => v < 0 || v > 255)) {
                  throw const FormatException('0...FF');
                }
                await state.run('ble.write', {
                  ...args,
                  'bytes': data,
                  'response': true,
                });
              } catch (e) {
                state.add(e);
              }
            },
            child: Text(platformText(context, '写入十六进制')),
          ),
          nativeButton(context, state, '读取描述符', 'ble.descriptorRead', args),
        ],
      ),
      SwitchListTile(
        title: Text(platformText(context, '通知')),
        value: notify,
        onChanged: (v) {
          setState(() => notify = v);
          state.run('ble.notify', {...args, 'enabled': v});
        },
      ),

      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.tonal(
            onPressed: () async {
              try {
                final payload = bytes.text
                    .split(RegExp(r'\s+'))
                    .where((s) => s.isNotEmpty)
                    .map((s) => int.parse(s, radix: 16))
                    .toList();
                final packet = JobsBleCodec.encode(payload);
                final decoded = JobsBleCodec.decode(packet);
                trace.append('protocol-roundtrip', {
                  'frame': packet.toList(),
                  'decoded': decoded.toList(),
                });
                state.add(trace.events.last);
              } catch (error) {
                state.add(error);
              }
            },
            child: Text(platformText(context, '编解码与CRC16')),
          ),
          FilledButton.tonal(
            onPressed: () async {
              try {
                final payload = bytes.text
                    .split(RegExp(r'\s+'))
                    .where((s) => s.isNotEmpty)
                    .map((s) => int.parse(s, radix: 16))
                    .toList();
                final mtu = await state.run('ble.mtu', args);
                if (mtu is! Map) return;
                for (final chunk in JobsBleCodec.fragments(
                  payload,
                  mtu['withResponse'] as int,
                )) {
                  await queue.enqueue(
                    () => (mockMode ? mock.handle : JobsPlatformLab.invoke)(
                      'ble.write',
                      {...args, 'bytes': chunk.toList(), 'response': true},
                    ),
                    retries: 1,
                  );
                  trace.append('write', chunk.toList());
                }
                state.add(trace.export());
              } catch (error) {
                state.add(error);
              }
            },
            child: Text(platformText(context, '分包队列与重试')),
          ),
          TextButton(
            onPressed: () {
              queue.cancelPending();
              state.add(trace.export());
            },
            child: Text(platformText(context, '导出日志并取消队列')),
          ),
        ],
      ),
      TextField(
        controller: traceSource,
        maxLines: 3,
        decoration: InputDecoration(labelText: platformText(context, '日志JSON')),
      ),
      FilledButton.tonal(
        onPressed: () {
          try {
            trace.import(traceSource.text);
            for (final event in trace.events.toList()) {
              state.add({'replay': true, ...event});
            }
          } catch (error) {
            state.add(error);
          }
        },
        child: Text(platformText(context, '回放日志')),
      ),
    ],
  );
}
