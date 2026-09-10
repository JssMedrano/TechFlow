/// Técnico responsável
class Technician {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String specialty;
  final bool active;
  final DateTime createdAt;

  const Technician({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.specialty,
    required this.active,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'specialty': specialty,
        'active': active ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory Technician.fromMap(Map<String, dynamic> map) => Technician(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: map['phone'] as String,
        email: map['email'] as String,
        specialty: map['specialty'] as String,
        active: (map['active'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Technician copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? specialty,
    bool? active,
    DateTime? createdAt,
  }) {
    return Technician(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
