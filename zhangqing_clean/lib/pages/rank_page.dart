import 'package:flutter/material.dart';
import '../models.dart';
import '../supabase_client.dart';
import '../theme.dart';
import 'mate_detail_page.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});
  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  bool _isToday = true;
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排行',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500)),
      ),
      body: FutureBuilder<_RankData>(
        future: _fetch(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary));
          }
          final data = snap.data!;
          final rows = _isToday ? data.today : data.total;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(children: [
                  _segBtn('今日', _isToday),
                  _segBtn('总累积', !_isToday),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: rows.isEmpty
                  ? const Center(
                      child: Text('还没有同学',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textWeak)))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: rows.length,
                      itemBuilder: (_, i) => _buildRow(i + 1, rows[i]),
                    ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _segBtn(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isToday = label == '今日'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  active ? FontWeight.w500 : FontWeight.w400,
              color: active ? Colors.white : AppColors.textSub,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int rank, _RankRow r) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MateDetailPage(mate: r.mate)),
        );
        setState(() => _refresh++);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: appShadow,
        ),
        child: Row(children: [
          SizedBox(
            width: 20,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: rank <= 3 ? 15 : 14,
                fontWeight:
                    rank <= 3 ? FontWeight.w500 : FontWeight.w400,
                color: rank <= 3
                    ? AppColors.primary
                    : AppColors.textWeak,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _Avatar(name: r.mate.name),
          const SizedBox(width: 10),
          Expanded(
            child: Text(r.mate.name,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textMain)),
          ),
          Text(
            '¥${r.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: r.amount == 0
                  ? AppColors.textWeak
                  : AppColors.textMain,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ]),
      ),
    );
  }

  Future<_RankData> _fetch() async {
    _refresh;
    final mates =
        await supabase.from('mates').select().order('created_at');
    final records =
        await supabase.from('records').select().neq('status', 'deleted');

    final mateList = (mates as List).map((m) => Mate.fromMap(m)).toList();
    final recList =
        (records as List).map((r) => RecordItem.fromMap(r)).toList();

    final today = [
      for (final m in mateList)
        _RankRow(mate: m, amount: _sumToday(recList, m.id)),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    final total = [
      for (final m in mateList)
        _RankRow(mate: m, amount: _sumTotal(recList, m.id)),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return _RankData(today, total);
  }

  bool _isTodayTime(DateTime t) {
    final n = DateTime.now();
    return t.year == n.year && t.month == n.month && t.day == n.day;
  }

  double _sumToday(List<RecordItem> recs, String mateId) => recs
      .where((r) => r.mateId == mateId && _isTodayTime(r.createdAt))
      .fold(0.0, (s, r) => s + r.amount);

  double _sumTotal(List<RecordItem> recs, String mateId) => recs
      .where((r) => r.mateId == mateId)
      .fold(0.0, (s, r) => s + r.amount);
}

class _RankRow {
  final Mate mate;
  final double amount;
  _RankRow({required this.mate, required this.amount});
}

class _RankData {
  final List<_RankRow> today;
  final List<_RankRow> total;
  _RankData(this.today, this.total);
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AvatarStyle.bgOf(name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(AvatarStyle.lastChar(name),
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AvatarStyle.fgOf(name))),
      ),
    );
  }
}
