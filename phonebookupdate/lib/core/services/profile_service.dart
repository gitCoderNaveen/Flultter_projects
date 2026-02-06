import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return await _supabase
        .from('s_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('s_profiles').update(data).eq('id', user.id);
  }

  static Future<void> deleteProfile() async {
    final user = _supabase.auth.currentUser!;
    await _supabase.from('s_profiles').delete().eq('id', user.id);
  }
}
