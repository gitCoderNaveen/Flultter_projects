import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PromotionServices {
  final _client = SupabaseService.client;

  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  bool isLoggedIn() {
    return _client.auth.currentSession != null;
  }
}
