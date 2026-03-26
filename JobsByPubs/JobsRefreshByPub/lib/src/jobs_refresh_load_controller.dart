import 'package:flutter/foundation.dart';

typedef FetchPage<T> = Future<List<T>> Function(int page, int pageSize);

/// 通用控制器
class JobsRefreshLoadController<T> extends ChangeNotifier {
  final int pageSize;
  final FetchPage<T> fetchPage;

  final List<T> items = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;

  JobsRefreshLoadController({
    required this.fetchPage,
    this.pageSize = 20,
  });

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();
    try {
      _page = 1;
      final list = await fetchPage(_page, pageSize);
      items
        ..clear()
        ..addAll(list);
      _hasMore = list.length == pageSize;
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isRefreshing) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final next = _page + 1;
      final list = await fetchPage(next, pageSize);
      _page = next;
      items.addAll(list);
      _hasMore = list.length == pageSize;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
