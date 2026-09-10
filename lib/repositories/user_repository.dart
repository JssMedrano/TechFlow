import '../models/user.dart';
import '../services/database_service.dart';

/// Repositório de usuários
class UserRepository {
  Future<AppUser?> authenticate(String username, String password) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim(), password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<int> count() async {
    final db = await DatabaseService.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM users');
    return (result.first['c'] as int?) ?? 0;
  }

  Future<int> insert(AppUser user) async {
    final db = await DatabaseService.instance.database;
    return db.insert('users', user.toMap()..remove('id'));
  }
}
