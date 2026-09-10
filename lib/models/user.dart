import '../core/constants.dart';

/// Usuário do sistema (autenticação local) — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class AppUser {
  final int? id;
  final String username;
  final String password;
  final String displayName;
  final UserRole role;
  final int? technicianId;

  const AppUser({
    this.id,
    required this.username,
    required this.password,
    required this.displayName,
    required this.role,
    this.technicianId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password': password,
        'display_name': displayName,
        'role': role.name,
        'technician_id': technicianId,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as int?,
        username: map['username'] as String,
        password: map['password'] as String,
        displayName: map['display_name'] as String,
        role: UserRoleX.fromString(map['role'] as String),
        technicianId: map['technician_id'] as int?,
      );

  AppUser copyWith({
    int? id,
    String? username,
    String? password,
    String? displayName,
    UserRole? role,
    int? technicianId,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      technicianId: technicianId ?? this.technicianId,
    );
  }
}
