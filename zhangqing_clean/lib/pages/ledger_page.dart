import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../supabase_client.dart';
import '../theme.dart';
import 'mate_detail_page.dart';
import 'widgets/amount_pad.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});
  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('M月d日').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text('账清',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 14),
            child: Text(today,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSub)),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt,
                color: AppColors.textMain),
            onPressed: _addMateDialog,
          ),
        ],
      ),
      body: FutureBuilder<_Ledger>(
        future: _fetchLedger(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary));
          }
          final ledger = snap.data!;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => setState(() => _refresh++),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
              children: [
                _SummaryCard(ledger: ledger),
                const SizedBox(height: 16),
                if (ledger.rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Column(children: [
                      Icon(Icons.edit_note,
                          size: 48, color: AppColors.textWeak),
                      SizedBox(height: 8),
                      Text('还没有同学，点右上角 + 添加',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textWeak)),
                    ]),
                  )
                else
                  for (final r in ledger.rows) _buildRow(r),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_Ledger> _fetchLedger() async {
    _refresh;
    final mates =
        await supabase.from('mates').select().order('created_at');
    final records =
        await supabase.from('records').select().neq('status', 'deleted');

    final mateList = (mates as List).map((m) => Mate.fromMap(m)).toList();
    final recList =
        (records as List).map((r) => RecordItem.fromMap(r)).toList();
    return _Ledger(mateList, recList);
  }

  Widget _buildRow(_RowData r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: appShadow,
      ),
      child: GestureDetector(
        onLongPress: () => _mateMenu(r),
        child: Row(children: [
          _Avatar(name: r.mate.name),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MateDetailPage(mate: r.mate),
                  ),
                );
                setState(() => _refresh++);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.mate.name,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.textMain)),
                  Text(
                    r.unpaid > 0
                        ? '欠 ¥${r.unpaid.toStringAsFixed(2)}'
                        : '今日还没来',
                    style: TextStyle(
                      fontSize: 12,
                      color: r.unpaid > 0
                          ? AppColors.textSub
                          : AppColors.textWeak,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            r.today == 0 ? '0' : '+${r.today.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color:
                  r.today == 0 ? AppColors.textWeak : AppColors.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _quickAdd(r.mate),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _quickAdd(Mate mate) async {
    final amount = await showAmountPad(context, mate.name);
    if (amount == null) return;
    await supabase.from('records').insert({
      'user_id': supabase.auth.currentUser!.id,
      'mate_id': mate.id,
      'amount': amount,
    });
    setState(() => _refresh++);
  }

  Future<void> _addMateDialog() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('添加同学',
            style: TextStyle(fontSize: 15, color: AppColors.textMain)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '输入名字，如「张伟」',
            hintStyle: const TextStyle(
                fontSize: 13, color: AppColors.textWeak),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消',
                style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              final n = ctrl.text.trim();
              if (n.isNotEmpty) Navigator.pop(ctx, n);
            },
            child: const Text('确定',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
    if (name == null) return;
    await supabase.from('mates').insert({
      'user_id': supabase.auth.currentUser!.id,
      'name': name,
    });
    setState(() => _refresh++);
  }

  void _mateMenu(_RowData r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('删除同学'),
                      content:
                          Text('删除「${r.mate.name}」及其全部账目？'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(_, false),
                            child: const Text('取消')),
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(_, true),
                            child: const Text('删除',
                                style: TextStyle(
                                    color: AppColors.primary))),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await supabase
                        .from('mates')
                        .delete()
                        .eq('id', r.mate.id);
                    setState(() => _refresh++);
                  }
                },
                child: const Text('删除同学'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Ledger {
  final List<_RowData> rows;
  final double todayTotal;
  final int todayCount;
  _Ledger(List<Mate> mates, List<RecordItem> recs)
      : todayTotal = recs
            .where((r) => _isToday(r.createdAt))
            .fold(0.0, (s, r) => s + r.amount),
        todayCount = recs.where((r) => _isToday(r.createdAt)).length,
        rows = [
          for (final m in mates)
            _RowData(
              mate: m,
              unpaid: recs
                  .where((r) =>
                      r.mateId == m.id && r.status == 'unpaid')
                  .fold(0.0, (s, r) => s + r.amount),
              today: recs
                  .where((r) =>
                      r.mateId == m.id && _isToday(r.createdAt))
                  .fold(0.0, (s, r) => s + r.amount),
            ),
        ]..sort((a, b) => b.unpaid.compareTo(a.unpaid));

  static bool _isToday(DateTime t) {
    final n = DateTime.now();
    return t.year == n.year && t.month == n.month && t.day == n.day;
  }
}

class _RowData {
  final Mate mate;
  final double unpaid;
  final double today;
  _RowData(
      {required this.mate, required this.unpaid, required this.today});
}

class _SummaryCard extends StatelessWidget {
  final _Ledger ledger;
  const _SummaryCard({required this.ledger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: appShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('今日入账',
            style: TextStyle(fontSize: 12, color: AppColors.textSub)),
        const SizedBox(height: 2),
        Row(children: [
          Text('¥${ledger.todayTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(width: 8),
          Text('${ledger.todayCount} 笔',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textWeak)),
        ]),
      ]),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AvatarStyle.bgOf(name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(AvatarStyle.lastChar(name),
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AvatarStyle.fgOf(name))),
      ),
    );
  }
}
