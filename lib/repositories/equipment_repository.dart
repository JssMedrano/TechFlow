import '../models/equipment.dart';
import '../services/database_service.dart';

/// Repositório de equipamentos — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class EquipmentRepository {
  Future<List<Equipment>> getAll({int? clientId, String? query}) async {
    final db = await DatabaseService.instance.database;
    final where = <String>[];
    final args = <Object>[];

    if (clientId != null) {
      where.add('e.client_id = ?');
      args.add(clientId);
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      where.add(
        '(e.brand LIKE ? OR e.model LIKE ? OR e.type LIKE ? OR e.serial_number LIKE ? OR e.asset_tag LIKE ? OR c.name LIKE ?)',
      );
      args.addAll([q, q, q, q, q, q]);
    }

    final sql = '''
      SELECT e.*, c.name AS client_name
      FROM equipment e
      INNER JOIN clients c ON c.id = e.client_id
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      ORDER BY e.brand COLLATE NOCASE, e.model COLLATE NOCASE
    ''';

    final rows = await db.rawQuery(sql, args);
    return rows.map(Equipment.fromMap).toList();
  }

  Future<Equipment?> getById(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT e.*, c.name AS client_name
      FROM equipment e
      INNER JOIN clients c ON c.id = e.client_id
      WHERE e.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return Equipment.fromMap(rows.first);
  }

  Future<int> insert(Equipment equipment) async {
    final db = await DatabaseService.instance.database;
    return db.insert('equipment', equipment.toMap()..remove('id'));
  }

  Future<int> update(Equipment equipment) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'equipment',
      equipment.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [equipment.id],
    );
  }

  Future<String?> delete(int id) async {
    final db = await DatabaseService.instance.database;
    final used = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM service_orders WHERE equipment_id = ?',
      [id],
    );
    if (((used.first['c'] as int?) ?? 0) > 0) {
      return 'Não é possível excluir: existem ordens de serviço vinculadas.';
    }
    await db.delete('equipment', where: 'id = ?', whereArgs: [id]);
    return null;
  }
}
