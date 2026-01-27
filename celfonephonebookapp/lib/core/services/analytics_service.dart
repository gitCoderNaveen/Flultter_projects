import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  static final _supabase = Supabase.instance.client;

  static Future<void> logProfileView(String profileId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('user_sessions').insert({
      'user_id': user.id,
      'profile_id': profileId,
      'action': 'view',
    });
  }

  /// Lead actions
  static Future<void> logLead({
    required String profileId,
    required String leadType, // call | whatsapp | enquiry | sms | website
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('search_logs').insert({
      'user_id': user.id,
      'profile_id': profileId,
      'action': leadType,
    });
  }
}
