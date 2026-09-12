/// Equipamento / ativo vinculado ao cliente
class Equipment {
  final int? id;
  final int clientId;
  final String type;
  final String brand;
  final String model;
  final String serialNumber;
  final String assetTag;
  final String notes;
  final DateTime createdAt;

  /// Nome do cliente (junção/join) para listagens.
  final String? clientName;

  const Equipment({
    this.id,
    required this.clientId,
    required this.type,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.assetTag,
    required this.notes,
    required this.createdAt,
    this.clientName,
  });

  String get displayName => '$brand $model ($type)';

  Map<String, dynamic> toMap() => {
        'id': id,
        'client_id': clientId,
        'type': type,
        'brand': brand,
        'model': model,
        'serial_number': serialNumber,
        'asset_tag': assetTag,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory Equipment.fromMap(Map<String, dynamic> map) => Equipment(
        id: map['id'] as int?,
        clientId: map['client_id'] as int,
        type: map['type'] as String,
        brand: map['brand'] as String,
        model: map['model'] as String,
        serialNumber: map['serial_number'] as String,
        assetTag: map['asset_tag'] as String,
        notes: map['notes'] as String? ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
        clientName: map['client_name'] as String?,
      );

  Equipment copyWith({
    int? id,
    int? clientId,
    String? type,
    String? brand,
    String? model,
    String? serialNumber,
    String? assetTag,
    String? notes,
    DateTime? createdAt,
    String? clientName,
  }) {
    return Equipment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      assetTag: assetTag ?? this.assetTag,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      clientName: clientName ?? this.clientName,
    );
  }
}
