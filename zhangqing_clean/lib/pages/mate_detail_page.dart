import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../supabase_client.dart';
import '../theme.dart';

class MateDetailPage extends StatefulWidget {
  final Mate mate;
  const MateDetailPage({super.key, required this.mate});

  @override
  State<MateDetailPage> createState() => _MateDetailPageState();
}

class _MateDetailPageState extends State<MateDetailPage> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<_Detail>(
        future: _fetch(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary));
          }
          final d = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Column(children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AvatarStyle.bgOf(widget.mate.name),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(AvatarStyle.lastChar(widget.mate.name),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color:
                                AvatarStyle.fgOf(widget.mate.name))),
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.mate.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMain)),
                const SizedBox(height: 2),
                Text(
                  '今日 ¥${d.today.toStringAsFixed(2)} · 未付 ¥${d.unpaidTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSub),
                ),
              ]),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: appShadow,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: d.records.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('没有未付记录',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textWeak)),
                        ),
                      )
                    : Column(
                        children: [
                          for (var i = 0;
                              i < d.records.length;
                              i++)
                            _buildRecordRow(
                                d.records[i],
                                i < d.records.length - 1),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecordRow(RecordItem r, bool hasLine) {
    final time = DateFormat('MM-dd HH:mm').format(r.createdAt.toLocal());
    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          width: 72,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Center(
            child: Text('删除',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除这笔？'),
            content: Text('¥${r.amount.toStringAsFixed(2)} · $time'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('取消',
                      style: TextStyle(color: AppColors.textSub))),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('删除',
                      style: TextStyle(color: AppColors.primary))),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await supabase
            .from('records')
            .update({'status': 'deleted'})
            .eq('id', r.id);
        setState(() => _refresh++);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: hasLine
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFEDF3FA)))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('¥${r.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMain,
                    fontFeatures: [FontFeature.tabularFigures()])),
            Text(time,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textWeak)),
          ],
        ),
      ),
    );
  }

  Future<_Detail> _fetch() async {
    _refresh;
    final records = await supabase
        .from('records')
        .select()
        .eq('mate_id', widget.mate.id)
        .eq('status', 'unpaid')
        .order('created_at', ascending: false);

    final recs =
        (records as List).map((r) => RecordItem.fromMap(r)).toList();
    final n = DateTime.now();
    return _Detail(
      records: recs,
      unpaidTotal: recs.fold(0.0, (s, r) => s + r.amount),
      today: recs
          .where((r) {
            final t = r.createdAt.toLocal();
            return t.year == n.year &&
                t.month == n.month &&
                t.day == n.day;
          })
          .fold(0.0, (s, r) => s + r.amount),
    );
  }
}

class _Detail {
  final List<RecordItem> records;
  final double unpaidTotal;
  final double today;
  _Detail({
    required this.records,
    required this.unpaidTotal,
    required this.today,
  });
}
