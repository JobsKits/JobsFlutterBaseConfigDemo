import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/调试/JobsCommonUtil.dart';

extension AnyLogGetter<T> on T {
  /// 使用点语法 `.log;` 打印对象
  T get log {
    assert(() {
      // ignore: avoid_print
      print(this);
      return true;
    }());
    return this; // 返回自身，方便链式调用
  }
}

extension JobsPrintExt<T> on T {
  /// 调用 .p 就会走 JobsPrint(this)
  T get p {
    JobsPrint(this);
    return this; // 返回自身，方便链式调用
  }

  T l(String tag) {
    JobsPrint({tag: this});
    return this;
  }
}
