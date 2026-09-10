/// Histórico de alterações da OS — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OrderHistory {
  final int? id;
  final int orderId;
  final String action;
  final String details;
  final String userName;
  final DateTime createdAt;

  const OrderHistory({
    this.id,
    required this.orderId,
    required this.action,
    required this.details,
    required this.userName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'order_id': orderId,
        'action': action,
        'details': details,
        'user_name': userName,
        'created_at': createdAt.toIso8601String(),
      };

  factory OrderHistory.fromMap(Map<String, dynamic> map) => OrderHistory(
        id: map['id'] as int?,
        orderId: map['order_id'] as int,
        action: map['action'] as String,
        details: map['details'] as String,
        userName: map['user_name'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
