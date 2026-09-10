import '../core/constants.dart';
import '../core/status_transitions.dart';
import '../models/order_history.dart';
import '../models/order_item.dart';
import '../models/service_order.dart';
import '../services/database_service.dart';

/// Filtros de busca de OS — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ServiceOrderFilter {
  final String? query;
  final OrderStatus? status;
  final OrderPriority? priority;
  final int? technicianId;
  final bool? onlyDelayed;
  final bool? onlyUrgent;

  const ServiceOrderFilter({
    this.query,
    this.status,
    this.priority,
    this.technicianId,
    this.onlyDelayed,
    this.onlyUrgent,
  });
}

/// Repositório de ordens de serviço — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ServiceOrderRepository {
  static const _selectJoin = '''
    SELECT o.*,
           c.name AS client_name,
           (e.brand || ' ' || e.model || ' (' || e.type || ')') AS equipment_name,
           t.name AS technician_name
    FROM service_orders o
    INNER JOIN clients c ON c.id = o.client_id
    INNER JOIN equipment e ON e.id = o.equipment_id
    LEFT JOIN technicians t ON t.id = o.technician_id
  ''';

  Future<List<OrderItem>> _itemsFor(int orderId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return rows.map(OrderItem.fromMap).toList();
  }

  Future<ServiceOrder> _hydrate(Map<String, dynamic> map) async {
    final order = ServiceOrder.fromMap(map);
    if (order.id == null) return order;
    final items = await _itemsFor(order.id!);
    return order.copyWith(items: items);
  }

  Future<List<ServiceOrder>> getAll([ServiceOrderFilter? filter]) async {
    final db = await DatabaseService.instance.database;
    final where = <String>[];
    final args = <Object>[];

    if (filter?.status != null) {
      where.add('o.status = ?');
      args.add(filter!.status!.name);
    }
    if (filter?.priority != null) {
      where.add('o.priority = ?');
      args.add(filter!.priority!.name);
    }
    if (filter?.technicianId != null) {
      where.add('o.technician_id = ?');
      args.add(filter!.technicianId!);
    }
    if (filter?.onlyUrgent == true) {
      where.add("o.priority = 'urgente'");
    }
    if (filter?.query != null && filter!.query!.trim().isNotEmpty) {
      final q = '%${filter.query!.trim()}%';
      where.add(
        '(o.code LIKE ? OR c.name LIKE ? OR e.brand LIKE ? OR e.model LIKE ? OR t.name LIKE ? OR e.type LIKE ?)',
      );
      args.addAll([q, q, q, q, q, q]);
    }

    final sql = '''
      $_selectJoin
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      ORDER BY o.opened_at DESC
    ''';

    final rows = await db.rawQuery(sql, args);
    final orders = <ServiceOrder>[];
    for (final row in rows) {
      orders.add(await _hydrate(row));
    }

    if (filter?.onlyDelayed == true) {
      return orders.where((o) => o.isDelayed).toList();
    }
    return orders;
  }

  Future<ServiceOrder?> getById(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      $_selectJoin
      WHERE o.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return _hydrate(rows.first);
  }

  Future<String> nextCode() async {
    final db = await DatabaseService.instance.database;
    final year = DateTime.now().year;
    final rows = await db.rawQuery(
      "SELECT code FROM service_orders WHERE code LIKE ? ORDER BY id DESC LIMIT 1",
      ['OS-$year-%'],
    );
    var seq = 1;
    if (rows.isNotEmpty) {
      final last = rows.first['code'] as String;
      final parts = last.split('-');
      seq = (int.tryParse(parts.last) ?? 0) + 1;
    }
    return 'OS-$year-${seq.toString().padLeft(4, '0')}';
  }

  Future<int> insert(ServiceOrder order, {required String userName}) async {
    final db = await DatabaseService.instance.database;
    return db.transaction((txn) async {
      final id = await txn.insert('service_orders', order.toMap()..remove('id'));
      for (final item in order.items) {
        await txn.insert(
          'order_items',
          item.copyWith(orderId: id).toMap()..remove('id'),
        );
      }
      await txn.insert('order_history', {
        'order_id': id,
        'action': 'Criação',
        'details': 'Ordem ${order.code} aberta com status ${order.status.label}.',
        'user_name': userName,
        'created_at': DateTime.now().toIso8601String(),
      });
      return id;
    });
  }

  Future<String?> update(
    ServiceOrder order, {
    required String userName,
    OrderStatus? previousStatus,
  }) async {
    if (order.id == null) return 'Ordem inválida.';

    if (previousStatus != null && previousStatus != order.status) {
      if (!StatusTransitions.canTransition(previousStatus, order.status)) {
        return 'Transição inválida: ${previousStatus.label} → ${order.status.label}.';
      }
      final completionError = StatusTransitions.validateCompletion(
        to: order.status,
        diagnosis: order.diagnosis,
        solution: order.solution,
      );
      if (completionError != null) return completionError;

      final assignError = StatusTransitions.validateAssign(
        to: order.status,
        technicianId: order.technicianId,
      );
      if (assignError != null) return assignError;
    }

    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'service_orders',
        order.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [order.id],
      );
      await txn.delete('order_items', where: 'order_id = ?', whereArgs: [order.id]);
      for (final item in order.items) {
        await txn.insert(
          'order_items',
          item.copyWith(orderId: order.id).toMap()..remove('id'),
        );
      }

      final details = previousStatus != null && previousStatus != order.status
          ? 'Status alterado de ${previousStatus.label} para ${order.status.label}.'
          : 'Dados da ordem atualizados.';

      await txn.insert('order_history', {
        'order_id': order.id,
        'action': previousStatus != null && previousStatus != order.status
            ? 'Status'
            : 'Atualização',
        'details': details,
        'user_name': userName,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
    return null;
  }

  Future<String?> changeStatus({
    required int orderId,
    required OrderStatus newStatus,
    required String userName,
  }) async {
    final current = await getById(orderId);
    if (current == null) return 'Ordem não encontrada.';

    if (!StatusTransitions.canTransition(current.status, newStatus)) {
      return 'Transição inválida: ${current.status.label} → ${newStatus.label}.';
    }
    final completionError = StatusTransitions.validateCompletion(
      to: newStatus,
      diagnosis: current.diagnosis,
      solution: current.solution,
    );
    if (completionError != null) return completionError;

    final assignError = StatusTransitions.validateAssign(
      to: newStatus,
      technicianId: current.technicianId,
    );
    if (assignError != null) return assignError;

    final updated = current.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      closedAt: (newStatus == OrderStatus.concluida ||
              newStatus == OrderStatus.cancelada)
          ? DateTime.now()
          : current.closedAt,
      clearClosedAt: newStatus != OrderStatus.concluida &&
          newStatus != OrderStatus.cancelada,
    );

    return update(updated, userName: userName, previousStatus: current.status);
  }

  Future<String?> delete(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('service_orders', where: 'id = ?', whereArgs: [id]);
    return null;
  }

  Future<List<OrderHistory>> history(int orderId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'order_history',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'created_at DESC',
    );
    return rows.map(OrderHistory.fromMap).toList();
  }

  Future<DashboardStats> dashboardStats() async {
    final orders = await getAll();
    double totalValue = 0;
    for (final o in orders) {
      totalValue += o.totalCost;
    }
    return DashboardStats(
      total: orders.length,
      open: orders.where((o) => o.status == OrderStatus.aberta).length,
      inProgress:
          orders.where((o) => o.status == OrderStatus.emAtendimento).length,
      waitingParts:
          orders.where((o) => o.status == OrderStatus.aguardandoPeca).length,
      completed:
          orders.where((o) => o.status == OrderStatus.concluida).length,
      urgent: orders.where((o) => o.isUrgent).length,
      delayed: orders.where((o) => o.isDelayed).length,
      totalValue: totalValue,
    );
  }
}
