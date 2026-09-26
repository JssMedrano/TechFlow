import 'package:flutter/material.dart';

import '../models/equipment.dart';
import '../repositories/equipment_repository.dart';

/// Estado de equipamentos
class EquipmentProvider extends ChangeNotifier {
  final _repo = EquipmentRepository();
  List<Equipment> _items = [];
  bool loading = false;
  String? error;
  String query = '';

  List<Equipment> get items => _items;

  Future<void> load({int? clientId}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _items = await _repo.getAll(clientId: clientId, query: query);
    } catch (_) {
      error = 'Falha ao carregar equipamentos.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> search(String value) async {
    query = value;
    await load();
  }

  Future<List<Equipment>> byClient(int clientId) =>
      _repo.getAll(clientId: clientId);

  Future<String?> save(Equipment equipment) async {
    try {
      if (equipment.id == null) {
        await _repo.insert(equipment);
      } else {
        await _repo.update(equipment);
      }
      await load();
      return null;
    } catch (_) {
      return 'Não foi possível salvar o equipamento.';
    }
  }

  Future<String?> remove(int id) async {
    try {
      final msg = await _repo.delete(id);
      if (msg == null) await load();
      return msg;
    } catch (_) {
      return 'Não foi possível excluir o equipamento.';
    }
  }
}
