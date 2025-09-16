import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Getter para acessar o cliente Supabase de forma fácil
  static SupabaseClient get client => Supabase.instance.client;

  // Getter para verificar se o usuário está autenticado
  static bool get isAuthenticated => client.auth.currentUser != null;

  // Getter para acessar o usuário atual
  static User? get currentUser => client.auth.currentUser;

  // Getter para acessar a sessão atual
  static Session? get currentSession => client.auth.currentSession;

  // ==========================================
  // AUTENTICAÇÃO
  // ==========================================

  /// Realiza o login com email e senha
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Realiza o cadastro com email, senha e nome
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    // O perfil será criado automaticamente pelo trigger no banco de dados
    return response;
  }

  /// Envia email de recuperação de senha
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: null, // Pode ser configurado para redirecionar para uma URL específica
    );
  }

  /// Faz logout do usuário
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Atualiza a senha do usuário
  static Future<UserResponse> updatePassword(String newPassword) async {
    return await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Atualiza o email do usuário
  static Future<UserResponse> updateEmail(String newEmail) async {
    return await client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
  }

  // ==========================================
  // PERFIL DO USUÁRIO
  // ==========================================

  /// Busca o perfil do usuário atual
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (currentUser == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();

    return response;
  }

  /// Atualiza o perfil do usuário
  static Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? bio,
    String? fotoUrl,
  }) async {
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['nome'] = name;
    if (bio != null) updates['bio'] = bio;
    if (fotoUrl != null) updates['foto_url'] = fotoUrl;
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await client
        .from('profiles')
        .update(updates)
        .eq('id', currentUser!.id)
        .select()
        .single();

    return response;
  }


  // ==========================================
  // UTILITÁRIOS
  // ==========================================

  /// Verifica se o email já está cadastrado
  static Future<bool> isEmailRegistered(String email) async {
    try {
      final response = await client
          .from('profiles')
          .select('email')
          .eq('email', email)
          .single();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Busca usuário por ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }
}
