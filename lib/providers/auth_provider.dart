import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mock user data
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simular delay de autenticação
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock login - qualquer email/senha será aceito por enquanto
      if (email.isNotEmpty && password.isNotEmpty) {
        _currentUser = {
          'id': '1',
          'name': 'Usuário Teste',
          'email': email,
          'bio': 'Amante da culinária',
          'avatar': null,
        };
        _isAuthenticated = true;
      } else {
        throw Exception('Email e senha são obrigatórios');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simular delay de cadastro
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock register
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        _currentUser = {
          'id': '1',
          'name': name,
          'email': email,
          'bio': '',
          'avatar': null,
        };
        _isAuthenticated = true;
      } else {
        throw Exception('Todos os campos são obrigatórios');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Simular delay de reset
      await Future.delayed(const Duration(seconds: 2));
      
      if (email.isEmpty) {
        throw Exception('Email é obrigatório');
      }
      
      // Mock reset - sempre "sucesso"
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
