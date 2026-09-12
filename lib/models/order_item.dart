/// Item de peça/material da OS
class OrderItem {
  final int? id;
  final int? orderId;
  final String description;
  final double quantity;
  final double unitPrice;

  const OrderItem({
    this.id,
    this.orderId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  Map<String, dynamic> toMap() => {
        'id': id,
        'order_id': orderId,
        'description': description,
        'quantity': quantity,
        'unit_price': unitPrice,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        id: map['id'] as int?,
        orderId: map['order_id'] as int?,
        description: map['description'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        unitPrice: (map['unit_price'] as num).toDouble(),
      );

  OrderItem copyWith({
    int? id,
    int? orderId,
    String? description,
    double? quantity,
    double? unitPrice,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
