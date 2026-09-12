import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/order_history.dart';
import '../models/service_order.dart';
import '../repositories/service_order_repository.dart';

/// Estado de ordens de serviço e painel
class ServiceOrderProvider extends ChangeNotifier {
  final _repo = ServiceOrderRepository();
  List<ServiceOrder> _items = [];
  List<ServiceOrder> _allForAttention = [];
  DashboardStats? stats;
  bool loading = false;
  String? error;

  String query = '';
  OrderStatus? statusFilter;
  OrderPriority? priorityFilter;
  int? technicianFilter;
  bool onlyDelayed = false;
  bool onlyUrgent = false;

  List<ServiceOrder> get items => _items;
  List<ServiceOrder> get delayedOrders =>
      _allForAttention.where((o) => o.isDelayed).toList();
  List<ServiceOrder> get urgentOpenOrders => _allForAttention
      .where((o) =>
          o.isUrgent &&
          o.status != OrderStatus.concluida &&
          o.status != OrderStatus.cancelada)
      .toList();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _items = await _repo.getAll(ServiceOrderFilter(
        query: query,
        status: statusFilter,
        priority: priorityFilter,
        technicianId: technicianFilter,
        onlyDelayed: onlyDelayed,
        onlyUrgent: onlyUrgent,
      ));
      _allForAttention = await _repo.getAll();
      stats = await _repo.dashboardStats();
    } catch (_) {
      error = 'Falha ao carregar ordens de serviço.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> refreshStats() async {
    stats = await _repo.dashboardStats();
    notifyListeners();
  }

  Future<ServiceOrder?> getById(int id) => _repo.getById(id);

  Future<String> nextCode() => _repo.nextCode();

  Future<String?> save(ServiceOrder order, String userName,
      {OrderStatus? previousStatus}) async {
    try {
      if (order.id == null) {
        await _repo.insert(order, userName: userName);
      } else {
        final err = await _repo.update(
          order,
          userName: userName,
          previousStatus: previousStatus,
        );
        if (err != null) return err;
      }
      await load();
      return null;
    } catch (_) {
      return 'Não foi possível salvar a ordem de serviço.';
    }
  }

  Future<String?> changeStatus(
    int id,
    OrderStatus status,
    String userName,
  ) async {
    try {
      final err = await _repo.changeStatus(
        orderId: id,
        newStatus: status,
        userName: userName,
      );
      if (err == null) await load();
      return err;
    } catch (_) {
      return 'Não foi possível alterar o status.';
    }
  }

  Future<String?> remove(int id) async {
    try {
      await _repo.delete(id);
      await load();
      return null;
    } catch (_) {
      return 'Não foi possível excluir a ordem.';
    }
  }

  Future<List<OrderHistory>> history(int orderId) => _repo.history(orderId);

  void clearFilters() {
    query = '';
    statusFilter = null;
    priorityFilter = null;
    technicianFilter = null;
    onlyDelayed = false;
    onlyUrgent = false;
  }
}
