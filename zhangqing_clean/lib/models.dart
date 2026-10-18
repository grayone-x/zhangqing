class Mate {
  final String id;
  final String name;
  final DateTime createdAt;
  Mate({required this.id, required this.name, required this.createdAt});

  factory Mate.fromMap(Map<String, dynamic> m) => Mate(
        id: m['id'] as String,
        name: m['name'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

class RecordItem {
  final String id;
  final String mateId;
  final double amount;
  final String status; // unpaid / paid / deleted
  final DateTime createdAt;
  RecordItem({
    required this.id,
    required this.mateId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory RecordItem.fromMap(Map<String, dynamic> m) => RecordItem(
        id: m['id'] as String,
        mateId: m['mate_id'] as String,
        amount: (m['amount'] as num).toDouble(),
        status: m['status'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
