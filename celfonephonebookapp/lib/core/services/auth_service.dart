import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static bool get isLoggedIn => _client.auth.currentSession != null;

  static Stream<AuthState> get onAuthChange => _client.auth.onAuthStateChange;
}
