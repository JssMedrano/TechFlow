import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

/// Gerenciador de autenticação local — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class AuthProvider extends ChangeNotifier {
  final _repo = UserRepository();
  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  bool get canManageUsers => _user?.role == UserRole.administrador;
  bool get canDelete =>
      _user?.role == UserRole.administrador ||
      _user?.role == UserRole.atendente;
  bool get canEditCatalog =>
      _user?.role == UserRole.administrador ||
      _user?.role == UserRole.atendente;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('session_user');
    final password = prefs.getString('session_pass');
    if (username == null || password == null) return;
    final user = await _repo.authenticate(username, password);
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _repo.authenticate(username, password);
      if (user == null) {
        _error = 'Usuário ou senha inválidos.';
        _loading = false;
        notifyListeners();
        return false;
      }
      _user = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_user', username);
      await prefs.setString('session_pass', password);
      _loading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Não foi possível autenticar. Tente novamente.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user');
    await prefs.remove('session_pass');
    notifyListeners();
  }
}
