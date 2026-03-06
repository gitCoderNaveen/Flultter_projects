import 'package:supabase_flutter/supabase_flutter.dart';

class PartnerServices {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return null;

      final response = await supabase
          .from('s_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      print("Service Error: $e");
      return null;
    }
  }

  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  String? getUserEmail() {
    return supabase.auth.currentUser?.email;
  }

  String? getUserId() {
    return supabase.auth.currentUser?.id;
  }
}
