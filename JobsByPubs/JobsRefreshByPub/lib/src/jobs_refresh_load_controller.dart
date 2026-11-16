import 'package:flutter/foundation.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

typedef FetchPage<T> = Future<List<T>> Function(int page, int pageSize);

/// 请求成功后才提交页码；刷新、加载和完成反馈共用同一个互斥状态机。
class JobsRefreshLoadController<T> extends ChangeNotifier {
  JobsRefreshLoadController({
    required this.fetchPage,
    this.pageSize = 20,
    String? historyKey,
    DateTime Function()? now,
  }) : assert(pageSize > 0) {
    edgeController = JobsEdgeRefreshController(
      historyKey: historyKey,
      now: now,
      completionDuration: const Duration(milliseconds: 350),
      onTrigger: (edge) =>
          edge == JobsRefreshEdge.leading ? _refresh() : _loadMore(),
    );
    edgeController.addListener(changed);
  }
  final int pageSize;
  final FetchPage<T> fetchPage;
  final List<T> items = [];
  late final JobsEdgeRefreshController edgeController;
  int _page = 1;
  bool _disposed = false;
  int get page => _page;
  bool get hasMore => edgeController.hasMore;
  bool get isRefreshing => edgeController.busy && edgeController.isRefresh;
  bool get isLoadingMore => edgeController.busy && !edgeController.isRefresh;
  Object? get error => edgeController.error;
  DateTime? get lastRefreshedAt => edgeController.lastRefreshedAt;
  DateTime? get lastLoadedAt => edgeController.lastLoadedAt;

  void changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh({bool userInitiated = true}) async {
    await edgeController.run(JobsRefreshEdge.leading,
        userInitiated: userInitiated);
  }

  Future<void> loadMore({bool userInitiated = true}) async {
    await edgeController.run(JobsRefreshEdge.trailing,
        userInitiated: userInitiated);
  }

  Future<void> _refresh() async {
    final result = await fetchPage(1, pageSize);
    if (_disposed) return;
    items
      ..clear()
      ..addAll(result);
    _page = 1;
    edgeController.setHasMore(result.length == pageSize);
  }

  Future<void> _loadMore() async {
    final next = _page + 1;
    final result = await fetchPage(next, pageSize);
    if (_disposed) return;
    items.addAll(result);
    _page = next;
    edgeController.setHasMore(result.length == pageSize);
  }

  @override
  void dispose() {
    _disposed = true;
    edgeController.removeListener(changed);
    edgeController.dispose();
    super.dispose();
  }
}
