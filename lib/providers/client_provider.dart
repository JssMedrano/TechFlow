import 'package:flutter/material.dart';

import '../models/client.dart';
import '../repositories/client_repository.dart';

/// Estado de clientes
class ClientProvider extends ChangeNotifier {
  final _repo = ClientRepository();
  List<Client> _items = [];
  bool loading = false;
  String? error;
  String query = '';

  List<Client> get items => _items;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _items = await _repo.getAll(query: query);
    } catch (_) {
      error = 'Falha ao carregar clientes.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> search(String value) async {
    query = value;
    await load();
  }

  Future<String?> save(Client client) async {
    try {
      if (client.id == null) {
        await _repo.insert(client);
      } else {
        await _repo.update(client);
      }
      await load();
      return null;
    } catch (_) {
      return 'Não foi possível salvar o cliente.';
    }
  }

  Future<String?> remove(int id) async {
    try {
      final msg = await _repo.delete(id);
      if (msg == null) await load();
      return msg;
    } catch (_) {
      return 'Não foi possível excluir o cliente.';
    }
  }
}
