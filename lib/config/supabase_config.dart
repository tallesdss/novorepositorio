/// Configurações do Supabase
/// 
/// NOTA DE SEGURANÇA:
/// - A URL e anon key são públicas e destinadas ao uso client-side
/// - A segurança real vem das políticas RLS no banco de dados
/// - NUNCA coloque service_role keys aqui (essas são privadas)
class SupabaseConfig {
  static const String url = 'https://rtwcsuuafdauxljqsvtj.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0d2NzdXVhZmRhdXhsanFzdnRqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4Njg1NzcsImV4cCI6MjA3MzQ0NDU3N30.Ooj1b-Dh4nKyUTjKG25nWzkjKzSbTh0CxZMLDj-eTIo';
  
  // Para produção, você pode usar diferentes configurações:
  // static const String url = String.fromEnvironment('SUPABASE_URL', defaultValue: urlDev);
  // static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: anonKeyDev);
}
