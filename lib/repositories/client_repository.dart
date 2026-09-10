import '../models/client.dart';
import '../services/database_service.dart';

/// Repositório de clientes — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ClientRepository {
  Future<List<Client>> getAll({String? query}) async {
    final db = await DatabaseService.instance.database;
    List<Map<String, dynamic>> rows;
    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      rows = await db.query(
        'clients',
        where: 'name LIKE ? OR document LIKE ? OR email LIKE ? OR phone LIKE ?',
        whereArgs: [q, q, q, q],
        orderBy: 'name COLLATE NOCASE',
      );
    } else {
      rows = await db.query('clients', orderBy: 'name COLLATE NOCASE');
    }
    return rows.map(Client.fromMap).toList();
  }

  Future<Client?> getById(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('clients', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Client.fromMap(rows.first);
  }

  Future<int> insert(Client client) async {
    final db = await DatabaseService.instance.database;
    return db.insert('clients', client.toMap()..remove('id'));
  }

  Future<int> update(Client client) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'clients',
      client.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<String?> delete(int id) async {
    final db = await DatabaseService.instance.database;
    final usedEquip = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM equipment WHERE client_id = ?',
      [id],
    );
    if (((usedEquip.first['c'] as int?) ?? 0) > 0) {
      return 'Não é possível excluir: existem equipamentos vinculados.';
    }
    final usedOrders = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM service_orders WHERE client_id = ?',
      [id],
    );
    if (((usedOrders.first['c'] as int?) ?? 0) > 0) {
      return 'Não é possível excluir: existem ordens de serviço vinculadas.';
    }
    await db.delete('clients', where: 'id = ?', whereArgs: [id]);
    return null;
  }
}
