import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameRecordsPage(title: "hi"),
    ));

/// =============================== 业务模型（自包含） ===============================
enum BetStatus { success, fail }
enum GameResult { win, lose, draw }

class BetRecord {
  final String gameName;
  final int amount; // 分制，展示时自己格式化
  final String memberId;
  final String orderNo;
  final DateTime betTime;
  final BetStatus status;
  final GameResult result;

  BetRecord({
    required this.gameName,
    required this.amount,
    required this.memberId,
    required this.orderNo,
    required this.betTime,
    required this.status,
    required this.result,
  });
}

class RecordQuery {
  final String? memberId;
  final String? gameCategory; // 用于 startsWith 过滤
  const RecordQuery({this.memberId, this.gameCategory});
}

/// =============================== 页面主体 ===============================
class GameRecordsPage extends StatefulWidget {
  final String title;
  const GameRecordsPage({super.key, required this.title});

  @override
  State<GameRecordsPage> createState() => _GameRecordsPageState();
}

class _GameRecordsPageState extends State<GameRecordsPage> {
  // ====== 上拉释放加载控制 ======
  static const double _pullUpTrigger = 72.0; // 触发阈值（像素）
  double _pullUpExtent = 0.0; // 当前越界上拉的距离
  bool _readyToReleaseToLoad = false; // 是否达到“释放加载”提示

  // ------- 模拟“服务端数据模板”（你可换成真实请求） -------
  final List<BetRecord> _seed = [
    BetRecord(
      gameName: 'MG电子-赏金猎人',
      amount: 231200,
      memberId: '112345222',
      orderNo: '112345222443',
      betTime: DateTime(2025, 4, 2, 16, 12, 41),
      status: BetStatus.success,
      result: GameResult.win,
    ),
    BetRecord(
      gameName: 'MG电子-赏金猎人',
      amount: 231200,
      memberId: '112345222',
      orderNo: '112345222444',
      betTime: DateTime(2025, 4, 2, 16, 12, 41),
      status: BetStatus.fail,
      result: GameResult.win,
    ),
    BetRecord(
      gameName: 'MG电子-赏金猎人',
      amount: 231200,
      memberId: '112345222',
      orderNo: '112345222445',
      betTime: DateTime(2025, 4, 2, 16, 12, 41),
      status: BetStatus.success,
      result: GameResult.win,
    ),
  ];

  // ------- 分页 & 列表状态 -------
  final ScrollController _scrollController = ScrollController();
  final List<BetRecord> _data = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 10;

  RecordQuery? _lastQuery;

  @override
  void initState() {
    super.initState();
    _refresh(); // 进入页面先加载第一页
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 下拉刷新
  Future<void> _refresh() async {
    _page = 1;
    _hasMore = true;
    _data.clear();
    await _fetchPage(reset: true);
    if (mounted) setState(() {});
  }

  // 接近底部自动加载（可与上拉释放并存；不想要就注释掉内部调用）
  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await _fetchPage();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  // 模拟接口请求：基于种子数据生成分页数据
  Future<void> _fetchPage({bool reset = false}) async {
    await Future.delayed(const Duration(milliseconds: 400)); // 模拟网络耗时

    // 根据查询条件过滤“服务端数据”。真实项目你在接口里处理。
    final allServerData = List<BetRecord>.generate(200, (i) {
      final s = _seed[i % _seed.length];
      return BetRecord(
        gameName: s.gameName,
        amount: s.amount + (i % 7) * 100, // 随机变化一点
        memberId: s.memberId,
        orderNo: (int.parse(s.orderNo) + i).toString(),
        betTime: s.betTime.add(Duration(minutes: i)),
        status: i % 5 == 0 ? BetStatus.fail : BetStatus.success,
        result: GameResult.win,
      );
    }).where((e) {
      final okMember = _lastQuery?.memberId == null ||
          e.memberId.contains(_lastQuery!.memberId!);
      final okCate = _lastQuery?.gameCategory == null ||
          e.gameName.startsWith(_lastQuery!.gameCategory!);
      return okMember && okCate;
    }).toList();

    final start = (_page - 1) * _pageSize;
    final end = _page * _pageSize;
    final pageSlice = start < allServerData.length
        ? allServerData.sublist(start, end.clamp(0, allServerData.length))
        : <BetRecord>[];

    if (pageSlice.isEmpty) {
      _hasMore = false;
      return;
    }

    _data.addAll(pageSlice);
    _page += 1;
    _hasMore = _data.length < allServerData.length;
  }

  // 本地过滤（这里暂不启用；示例保留）
  List<BetRecord> _applyLocalFilter(List<BetRecord> src, RecordQuery? q) {
    if (q == null) return src;
    return src.where((e) {
      final okMember = q.memberId == null || e.memberId.contains(q.memberId!);
      final okCate =
          q.gameCategory == null || e.gameName.startsWith(q.gameCategory!);
      return okMember && okCate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 外层 Scaffold，深色背景
    return Scaffold(
      backgroundColor: const Color(0xFF171B24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171B24),
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: false,
      ),
      body: Container(
        padding:
            const EdgeInsets.only(left: 12, top: 14, right: 12, bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2430),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF2B3140)),
        ),
        margin: const EdgeInsets.all(12),
        child: Column(
          children: [
            RecordSearchBar(
              categories: const ['全部', 'MG电子', 'AG真人', 'PG电子'],
              onSearch: (q) async {
                _lastQuery = q;
                await _refresh(); // 搜索后重置分页并重新加载
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF2B2B2B),
                backgroundColor: const Color(0xFFFFD8A6),
                onRefresh: _refresh,
                child: _buildListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final view = _applyLocalFilter(_data, null);

    Widget inner;
    if (view.isEmpty) {
      inner = ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        children: const [
          SizedBox(height: 140),
          Center(
              child: Text('暂无数据',
                  style: TextStyle(
                      color: Color(0xFF9AA3B2), fontWeight: FontWeight.w600))),
          SizedBox(height: 140),
        ],
      );
    } else {
      inner = ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(bottom: 12),
        itemCount: view.length + 1,
        itemBuilder: (_, i) {
          if (i < view.length) return BetRecordTile(record: view[i]);
          return _buildFooter(); // ↓ footer 会根据状态显示不同文案
        },
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        // 1) 只关心在“底部”的越界（向上拉）
        if (n is OverscrollNotification) {
          final atBottom = n.metrics.pixels >= n.metrics.maxScrollExtent;
          if (atBottom && n.overscroll > 0) {
            _pullUpExtent += n.overscroll;
            final ready = _pullUpExtent >= _pullUpTrigger;
            if (ready != _readyToReleaseToLoad) {
              setState(() => _readyToReleaseToLoad = ready);
            }
          }
        }

        // 2) 手指松开且滚动停止：如果达到阈值就加载
        if (n is ScrollEndNotification) {
          if (_readyToReleaseToLoad && !_isLoadingMore && _hasMore) {
            _pullUpExtent = 0;
            _readyToReleaseToLoad = false;
            _loadMore(); // 触发加载更多
          } else {
            // 没达阈值或不该加载时，重置
            _pullUpExtent = 0;
            if (_readyToReleaseToLoad) {
              setState(() => _readyToReleaseToLoad = false);
            }
          }
        }
        return false; // 不拦截，继续向下分发
      },
      child: inner,
    );
  }

  Widget _buildFooter() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFFFFD8A6)),
          ),
        ),
      );
    }

    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text('— 没有更多了 —',
              style: TextStyle(color: Color(0xFF9AA3B2), fontSize: 12)),
        ),
      );
    }

    // 还可以加载：显示提示文案（根据是否达到阈值切换）
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          _readyToReleaseToLoad ? '释放加载更多' : '上拉加载更多',
          style: const TextStyle(color: Color(0xFF9AA3B2), fontSize: 12),
        ),
      ),
    );
  }
}

/// =============================== 搜索条（自包含） ===============================
class RecordSearchBar extends StatefulWidget {
  final List<String> categories; // 含“全部”
  final FutureOr<void> Function(RecordQuery query) onSearch;
  const RecordSearchBar({
    super.key,
    required this.categories,
    required this.onSearch,
  });

  @override
  State<RecordSearchBar> createState() => _RecordSearchBarState();
}

class _RecordSearchBarState extends State<RecordSearchBar> {
  final TextEditingController _memberCtrl = TextEditingController();
  late String _category;

  @override
  void initState() {
    super.initState();
    _category = widget.categories.first; // 默认“全部”
  }

  @override
  void dispose() {
    _memberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 会员ID输入
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: _memberCtrl,
              cursorColor: const Color(0xFFFFD8A6),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: '会员ID（可选）',
                hintStyle:
                    const TextStyle(color: Color(0xFF778099), fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: const Color(0xFF232939),
                enabledBorder: _border(),
                focusedBorder: _border(focused: true),
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 分类下拉
        SizedBox(
          width: 140,
          height: 36,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF232939),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: const Color(0xFF2B3140), width: 1, strokeAlign: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                isDense: true,
                underline: const SizedBox.shrink(),
                iconEnabledColor: const Color(0xFFFFD8A6),
                dropdownColor: const Color(0xFF232939),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: widget.categories
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() {
                  if (v != null) _category = v;
                }),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 搜索按钮
        SizedBox(
          height: 36,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD8A6),
              foregroundColor: const Color(0xFF2B2B2B),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              final cate = _category == '全部' ? null : _category;
              widget.onSearch(RecordQuery(
                memberId: _memberCtrl.text.trim().isEmpty
                    ? null
                    : _memberCtrl.text.trim(),
                gameCategory: cate,
              ));
            },
            child: const Text('搜索', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({bool focused = false}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: focused ? const Color(0xFFFFD8A6) : const Color(0xFF2B3140),
          width: focused ? 1.2 : 1.0,
        ),
      );
}

/// =============================== 列表项（自包含） ===============================
class BetRecordTile extends StatelessWidget {
  final BetRecord record;
  const BetRecordTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final amountYuan = (record.amount / 100).toStringAsFixed(2);
    final statusColor =
        record.status == BetStatus.success ? const Color(0xFF5CD18C) : const Color(0xFFE57373);
    final timeStr =
        "${record.betTime.year.toString().padLeft(4, '0')}-${record.betTime.month.toString().padLeft(2, '0')}-${record.betTime.day.toString().padLeft(2, '0')} "
        "${record.betTime.hour.toString().padLeft(2, '0')}:${record.betTime.minute.toString().padLeft(2, '0')}:${record.betTime.second.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF232939),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2B3140)),
      ),
      child: Row(
        children: [
          // 左：游戏名 + 订单/时间
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.gameName,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _kv('会员', record.memberId),
                    const SizedBox(width: 12),
                    _kv('单号', record.orderNo),
                  ],
                ),
                const SizedBox(height: 4),
                _kv('时间', timeStr),
              ],
            ),
          ),
          // 右：金额 + 状态
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('¥$amountYuan',
                  style: const TextStyle(
                      color: Color(0xFFFFD8A6),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor, width: .8),
                ),
                child: Text(
                  record.status == BetStatus.success ? '成功' : '失败',
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: '$k：',
                style: const TextStyle(color: Color(0xFF9AA3B2), fontSize: 12)),
            TextSpan(
                text: v,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      );
}
