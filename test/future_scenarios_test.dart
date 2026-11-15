import 'package:flutter_test/flutter_test.dart';

import '../lib/demos/协议扩展与模块化/协议扩展与模块化.dart';

void main() {
  test('Serial requests propagate predecessor output', () async {
    final v = await runFutureScenario(0, responseMillis: 1);
    expect(v['result'], 'benefits(profile(login))');
    expect(v['trace'], ['login', 'profile', 'benefits']);
  });
  test('Concurrent aggregation waits for each branch', () async {
    final v = await runFutureScenario(1, responseMillis: 1);
    expect(v['result'], ['feed', 'profile', 'offers']);
  });
  test('Failure recovers from cache', () async {
    final v = await runFutureScenario(2, responseMillis: 1);
    expect(v['result'], 'cached-profile');
    expect(v['trace'], ['primary', 'recover-cache']);
  });
  test('Resolved aggregation retains two successes and one failure', () async {
    final v = await runFutureScenario(3, responseMillis: 1);
    final rows = (v['result'] as List).cast<Map>();
    expect(rows.where((e) => e['success'] == true).length, 2);
    expect(rows[1]['error'], contains('profile failed'));
  });
  test('Race returns request before timeout', () async {
    expect((await runFutureScenario(4, responseMillis: 1))['result'], 'remote');
  });
  test('Race times out before request', () async {
    expect(
      (await runFutureScenario(4, responseMillis: 300))['result'],
      'timeout',
    );
  });
}
