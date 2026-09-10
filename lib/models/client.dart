/// Cliente da empresa — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class Client {
  final int? id;
  final String name;
  final String document;
  final String phone;
  final String email;
  final String address;
  final DateTime createdAt;

  const Client({
    this.id,
    required this.name,
    required this.document,
    required this.phone,
    required this.email,
    required this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'document': document,
        'phone': phone,
        'email': email,
        'address': address,
        'created_at': createdAt.toIso8601String(),
      };

  factory Client.fromMap(Map<String, dynamic> map) => Client(
        id: map['id'] as int?,
        name: map['name'] as String,
        document: map['document'] as String,
        phone: map['phone'] as String,
        email: map['email'] as String,
        address: map['address'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Client copyWith({
    int? id,
    String? name,
    String? document,
    String? phone,
    String? email,
    String? address,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      document: document ?? this.document,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
