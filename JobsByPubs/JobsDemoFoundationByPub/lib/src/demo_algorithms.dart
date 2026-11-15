import 'dart:async';

/// 41 位毫秒时间、10 位节点、12 位序列；BigInt 在 Web 上也保留整数精度。
class JobsSnowflake {
  JobsSnowflake({
    required this.node,
    int Function()? clock,
    this.epoch = 1577836800000,
  }) : assert(node >= 0 && node <= 1023),
       _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  final int node;
  final int epoch;
  final int Function() _clock;
  int _lastMillisecond = -1;
  int _sequence = 0;
  Future<void> _tail = Future<void>.value();

  /// 串行分配防止多个异步调用竞争；失败不污染后续请求。
  Future<BigInt> next() {
    final completer = Completer<BigInt>();
    _tail = _tail.then((_) async {
      try {
        var now = _clock();
        if (now < _lastMillisecond) throw StateError('Clock moved backwards');
        if (now == _lastMillisecond) {
          if (_sequence == 4095) {
            final deadline = Stopwatch()..start();
            do {
              if (deadline.elapsedMilliseconds > 100) {
                throw StateError('Clock did not advance');
              }
              await Future<void>.delayed(const Duration(milliseconds: 1));
              now = _clock();
              if (now < _lastMillisecond) {
                throw StateError('Clock moved backwards');
              }
            } while (now <= _lastMillisecond);
            _sequence = 0;
          } else {
            _sequence++;
          }
        } else {
          _sequence = 0;
        }
        final elapsed = now - epoch;
        if (node < 0 ||
            node > 1023 ||
            elapsed < 0 ||
            BigInt.from(elapsed) >= (BigInt.one << 41)) {
          throw RangeError(
            'Snowflake node or timestamp outside supported range',
          );
        }
        _lastMillisecond = now;
        completer.complete(
          (BigInt.from(elapsed) << 22) |
              (BigInt.from(node) << 12) |
              BigInt.from(_sequence),
        );
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });
    return completer.future;
  }
}

class JobsDebouncer {
  JobsDebouncer(this.delay);
  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}

/// 首次立即执行，在间隔内忽略重复调用。
class JobsThrottle {
  JobsThrottle(this.interval);
  final Duration interval;
  final Stopwatch _watch = Stopwatch()..start();
  int? _lastMicroseconds;

  bool call(void Function() action) {
    final now = _watch.elapsedMicroseconds;
    if (_lastMicroseconds != null &&
        now - _lastMicroseconds! < interval.inMicroseconds) {
      return false;
    }
    _lastMicroseconds = now;
    action();
    return true;
  }

  void reset() => _lastMicroseconds = null;
}
