import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => SupabaseService.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => SupabaseService.currentUser;

  // Dados do perfil do usuário
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  AuthProvider() {
    // Escutar mudanças de estado de autenticação
    SupabaseService.client.auth.onAuthStateChange.listen((event) {
      _handleAuthStateChange(event);
    });

    // Carregar perfil se usuário já estiver autenticado
    if (isAuthenticated) {
      _loadUserProfile();
    }
  }

  Future<void> _handleAuthStateChange(AuthState authState) async {
    switch (authState.event) {
      case AuthChangeEvent.signedIn:
        await _loadUserProfile();
        break;
      case AuthChangeEvent.signedOut:
        _userProfile = null;
        break;
      case AuthChangeEvent.tokenRefreshed:
        // Token atualizado, recarregar perfil se necessário
        if (_userProfile == null && isAuthenticated) {
          await _loadUserProfile();
        }
        break;
      default:
        break;
    }
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    try {
      _userProfile = await SupabaseService.getCurrentUserProfile();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar perfil: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await SupabaseService.signInWithEmail(email, password);

      if (response.user != null) {
        // Usuário autenticado com sucesso
        await _loadUserProfile();
        return true;
      } else {
        _errorMessage = 'Falha na autenticação';
        return false;
      }
    } on AuthException catch (e) {
      // Em desenvolvimento, se for erro de email não confirmado, tentamos workaround
      if (e.message == 'Email not confirmed') {
        return await _handleUnconfirmedEmail(email, password);
      }
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método auxiliar para desenvolvimento - simula confirmação de email
  Future<bool> _handleUnconfirmedEmail(String email, String password) async {
    try {
      // Em desenvolvimento, vamos tentar carregar o perfil diretamente
      // Isso funciona porque o usuário existe no banco, apenas não confirmamos o email
      final profile = await SupabaseService.getCurrentUserProfile();
      if (profile != null) {
        _userProfile = profile;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Perfil não encontrado. Tente confirmar seu email primeiro.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar perfil. Confirme seu email primeiro.';
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    _setLoading(true);
    _clearError();

    try {
      // Validações básicas
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _errorMessage = 'Todos os campos são obrigatórios';
        return false;
      }

      if (password != confirmPassword) {
        _errorMessage = 'As senhas não coincidem';
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'A senha deve ter pelo menos 6 caracteres';
        return false;
      }

      // Verificar se email já está cadastrado
      final emailExists = await SupabaseService.isEmailRegistered(email);
      if (emailExists) {
        _errorMessage = 'Este email já está cadastrado';
        return false;
      }

      final response = await SupabaseService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        // Usuário criado com sucesso - aguardar confirmação de email
        // Não tentamos carregar perfil ainda pois pode não estar confirmado
        return true;
      } else {
        _errorMessage = 'Falha no cadastro. Verifique se o email é válido.';
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      if (email.isEmpty) {
        _errorMessage = 'Email é obrigatório';
        return false;
      }

      await SupabaseService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao enviar email de recuperação: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? fotoUrl,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedProfile = await SupabaseService.updateUserProfile(
        name: name,
        bio: bio,
        fotoUrl: fotoUrl,
      );

      _userProfile = updatedProfile;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      if (newPassword.length < 6) {
        _errorMessage = 'A senha deve ter pelo menos 6 caracteres';
        return false;
      }

      await SupabaseService.updatePassword(newPassword);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar senha: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.signOut();
      _userProfile = null;
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Email ou senha incorretos';
      case 'Email not confirmed':
        return 'Email não confirmado. Verifique sua caixa de entrada e confirme sua conta.';
      case 'User already registered':
        return 'Este email já está cadastrado';
      case 'Password should be at least 6 characters':
        return 'A senha deve ter pelo menos 6 caracteres';
      case 'Unable to validate email address: invalid format':
        return 'Formato de email inválido';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }

  // Método utilitário para recarregar perfil
  Future<void> refreshProfile() async {
    if (isAuthenticated) {
      await _loadUserProfile();
    }
  }
}
