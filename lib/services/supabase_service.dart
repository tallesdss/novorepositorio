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
}
