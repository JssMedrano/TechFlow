import 'package:flutter/material.dart';

import '../models/technician.dart';
import '../repositories/technician_repository.dart';

/// Estado de técnicos — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class TechnicianProvider extends ChangeNotifier {
  final _repo = TechnicianRepository();
  List<Technician> _items = [];
  bool loading = false;
  String? error;
  String query = '';

  List<Technician> get items => _items;
  List<Technician> get activeItems =>
      _items.where((t) => t.active).toList();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _items = await _repo.getAll(query: query);
    } catch (_) {
      error = 'Falha ao carregar técnicos.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> search(String value) async {
    query = value;
    await load();
  }

  Future<String?> save(Technician technician) async {
    try {
      if (technician.id == null) {
        await _repo.insert(technician);
      } else {
        await _repo.update(technician);
      }
      await load();
      return null;
    } catch (_) {
      return 'Não foi possível salvar o técnico.';
    }
  }

  Future<String?> remove(int id) async {
    try {
      final msg = await _repo.delete(id);
      if (msg == null) await load();
      return msg;
    } catch (_) {
      return 'Não foi possível excluir o técnico.';
    }
  }
}
