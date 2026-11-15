import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

String microDocument(BuildContext context, String appId) {
  final labels = jsonEncode({
    'save': tr(context, '保存'),
    'read': tr(context, '读取'),
    'content': tr(context, '内容'),
    'verify': tr(context, '校验'),
    'clear': tr(context, '清空'),
    'reload': tr(context, '重新加载'),
  }).replaceAll('<', r'\u003c');
  final dark = Theme.of(context).brightness == Brightness.dark;
  return '''<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font:16px system-ui;background:${dark ? '#151b19' : '#f6f8f5'};color:${dark ? '#eef4ef' : '#161c19'};margin:16px}input,button{font:inherit;padding:10px;margin:6px 4px 6px 0;max-width:95%;box-sizing:border-box}button{background:#176653;color:white;border:0;border-radius:6px}pre{white-space:pre-wrap;overflow-wrap:anywhere}</style></head><body><h3>$appId</h3><input id="value" value="Jobs Flutter"><div id="actions"></div><pre id="output">JavaScript ↔ Dart</pre><script>
const labels=$labels; const appId=${jsonEncode(appId)};
function send(method,params){const message=JSON.stringify({id:Date.now(),appId,method,params});if(window.JobsBridge){JobsBridge.postMessage(message);}else{parent.postMessage(message,location.origin);}}
window.jobsReply=(reply)=>document.getElementById('output').textContent=JSON.stringify(reply,null,2);
window.addEventListener('message',event=>{if(event.source!==parent||event.origin!==location.origin)return;try{window.jobsReply(JSON.parse(event.data));}catch(_){}});
const actions=[['echo',labels.verify,()=>({value:document.getElementById('value').value})],['storage.set',labels.save,()=>({key:'note',value:document.getElementById('value').value})],['storage.get',labels.read,()=>({key:'note'})],['system.forbidden','DENIED',()=>({})]];
for(const [method,title,parameters] of actions){const button=document.createElement('button');button.textContent=title;button.onclick=()=>send(method,parameters());document.getElementById('actions').append(button);}
</script></body></html>''';
}
