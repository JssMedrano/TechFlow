import '../models/technician.dart';
import '../services/database_service.dart';

/// Repositório de técnicos — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class TechnicianRepository {
  Future<List<Technician>> getAll({bool onlyActive = false, String? query}) async {
    final db = await DatabaseService.instance.database;
    final where = <String>[];
    final args = <Object>[];

    if (onlyActive) {
      where.add('active = 1');
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      where.add('(name LIKE ? OR specialty LIKE ? OR email LIKE ?)');
      args.addAll([q, q, q]);
    }

    final rows = await db.query(
      'technicians',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Technician.fromMap).toList();
  }

  Future<Technician?> getById(int id) async {
    final db = await DatabaseService.instance.database;
    final rows =
        await db.query('technicians', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Technician.fromMap(rows.first);
  }

  Future<int> insert(Technician technician) async {
    final db = await DatabaseService.instance.database;
    return db.insert('technicians', technician.toMap()..remove('id'));
  }

  Future<int> update(Technician technician) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'technicians',
      technician.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [technician.id],
    );
  }

  Future<String?> delete(int id) async {
    final db = await DatabaseService.instance.database;
    final used = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM service_orders WHERE technician_id = ?',
      [id],
    );
    if (((used.first['c'] as int?) ?? 0) > 0) {
      return 'Não é possível excluir: existem OS atribuídas a este técnico. '
          'Desative o cadastro em vez de excluir.';
    }
    await db.delete('technicians', where: 'id = ?', whereArgs: [id]);
    return null;
  }
}
