import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 校验跨端公共运行时的隔离、拒绝路径、并发存储、白名单和编码完整性。
void main(){
 setUp(()=>SharedPreferences.setMockInitialValues({}));
 test('沙箱路径及账号边界保持，多个实例并发写不丢项',()async{
  final a=JobsLabSandbox('app_a');final a2=JobsLabSandbox('app_a');final b=JobsLabSandbox('app_b');
  await Future.wait(List.generate(30,(i)=>(i.isEven?a:a2).write('items/$i','value $i')));
  expect((await a.entries()).length,30);expect(await b.entries(),isEmpty);
  for(final path in ['../other','/root','a/../b','a/%2e%2e/b',r'a\b','file://x','a//b']){expect(()=>a.validatePath(path),throwsArgumentError);}
  await a.remove('items/0');expect((await a.entries()).length,29);
 });
 test('Bridge仅允许正确appId及显式能力，错误保持协议响应',()async{
  final bridge=JobsLabBridge(appId:'demo',allowedMethods:{'sum'},capabilities:{'sum':(args)=>(args['a'] as int)+(args['b'] as int)});
  expect((await bridge.dispatch({'id':1,'appId':'demo','method':'sum','params':{'a':2,'b':3}}))['result'],5);
  for(final request in [{'appId':'other','method':'sum'},{'appId':'demo','method':'storage.delete'},'not-json',{'appId':'demo','method':'sum','params':[]}]){expect((await bridge.dispatch(request))['ok'],false);}
 });
 test('热更新检查schema，回滚恢复原工厂值',(){final registry=JobsLabPatchRegistry()..register('card',{'count':1,'title':'Jobs'});registry.apply('card',{'count':2});expect(registry.resolve('card')['count'],2);expect(()=>registry.apply('card',{'extra':true}),throwsArgumentError);expect(()=>registry.apply('card',{'count':'2'}),throwsArgumentError);registry.rollback('card');expect(registry.resolve('card')['count'],1);});
 test('CNID严格拒绝非法日期、校验位及序号',(){expect(validateCNID('11010519491231002X').valid,true);expect(validateCNID('11010519490231002X').valid,false);expect(validateCNID('110105194912310020').valid,false);expect(validateCNID('abc').valid,false);});
 test('GZIP恢复多语言，坏输入安全失败',(){const value='Jobs བོད་ཡིག 中文 🐦';expect(JobsLabCodec.decompress(JobsLabCodec.compress(value)),value);expect(()=>JobsLabCodec.decompress('broken'),throwsA(anything));});
 test('图片加盐每次不同，认证失败不输出图片',(){final bytes=Uint8List.fromList(List.generate(1000,(i)=>i%256));final a=JobsLabCodec.sealImage(bytes,'demo-passphrase');final b=JobsLabCodec.sealImage(bytes,'demo-passphrase');expect(a,isNot(b));expect(JobsLabCodec.openImage(a,'demo-passphrase'),bytes);expect(()=>JobsLabCodec.openImage(a,'wrong'),throwsA(anything));final envelope=jsonDecode(a) as Map<String,dynamic>;envelope['ciphertext']=base64Encode(List.filled(30,0));expect(()=>JobsLabCodec.openImage(jsonEncode(envelope),'demo-passphrase'),throwsA(anything));});
 test('对象记录新增修改筛选与删除实际持久化',()async{final store=JobsLabRecordStore('records');await store.put('1',{'name':'Jobs'});await store.put('2',{'name':'Flutter'});await store.put('1',{'name':'Swift'});expect((await store.query(contains:'Swift')).single['id'],'1');await store.delete('1');expect((await store.query()).single['id'],'2');});
 test('计时器暂停保持进度、重置和移除销毁',()async{final hub=JobsLabTimerHub();addTearDown(hub.dispose);hub.create('a',const Duration(milliseconds:300));hub.start('a');await Future<void>.delayed(const Duration(milliseconds:25));hub.pause('a');final elapsed=hub.timers['a']!.elapsed;await Future<void>.delayed(const Duration(milliseconds:25));expect(hub.timers['a']!.elapsed,elapsed);hub.reset('a');expect(hub.timers['a']!.elapsed,Duration.zero);hub.remove('a');expect(hub.timers,isEmpty);});
}
