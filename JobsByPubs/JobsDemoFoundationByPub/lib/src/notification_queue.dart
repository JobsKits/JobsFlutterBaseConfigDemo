import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

@immutable
class JobsQueuedNotice {
  const JobsQueuedNotice({required this.id, required this.content});
  final String id, content;
}

/// 同时展示有上限、按标识更新并重新计时；清空／销毁会撤销所有未完成的计时器。
class JobsNotificationQueue extends ChangeNotifier {
  JobsNotificationQueue({
    int concurrency = 4,
    this.duration = const Duration(seconds: 5),
  }) : _concurrency = concurrency.clamp(1, 4);
  final Duration duration;
  final _pending = Queue<JobsQueuedNotice>();
  final _active = <String, JobsQueuedNotice>{};
  final _timers = <String, Timer>{};
  final _completed = <String>[];
  int _concurrency;
  bool _disposed = false;
  int get concurrency => _concurrency;
  set concurrency(int value) {
    if (_disposed) return;
    _concurrency = value.clamp(1, 4);
    _drain();
    notifyListeners();
  }

  List<JobsQueuedNotice> get active => List.unmodifiable(_active.values);
  List<JobsQueuedNotice> get pending => List.unmodifiable(_pending);
  List<String> get completed => List.unmodifiable(_completed);
  void add(JobsQueuedNotice notice) {
    if (_disposed) return;
    if (_active.containsKey(notice.id)) {
      update(notice.id, notice.content);
      return;
    }
    _pending.removeWhere((value) => value.id == notice.id);
    _pending.add(notice);
    _drain();
    notifyListeners();
  }

  bool update(String id, String content) {
    if (_disposed || !_active.containsKey(id)) return false;
    _active[id] = JobsQueuedNotice(id: id, content: content);
    _schedule(id);
    notifyListeners();
    return true;
  }

  void _schedule(String id) {
    _timers.remove(id)?.cancel();
    _timers[id] = Timer(duration, () => dismiss(id));
  }

  void _drain() {
    while (_active.length < _concurrency && _pending.isNotEmpty) {
      final notice = _pending.removeFirst();
      _active[notice.id] = notice;
      _schedule(notice.id);
    }
  }

  void dismiss(String id) {
    if (_disposed) return;
    _timers.remove(id)?.cancel();
    if (_active.remove(id) != null) {
      _completed.add(id);
      if (_completed.length > 100) _completed.removeAt(0);
    } else {
      _pending.removeWhere((value) => value.id == id);
    }
    _drain();
    notifyListeners();
  }

  void clear() {
    if (_disposed) return;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _pending.clear();
    _active.clear();
    _completed.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _pending.clear();
    _active.clear();
    super.dispose();
  }
}
