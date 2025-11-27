import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  String _mobileToEmail(String mobile) {
    return '${mobile.replaceAll(' ', '')}@phone.local';
  }

  Future<AuthResponse> signUpWithMobile(String mobile, String password,
      {String? businessName, String? businessPrefix}) async {
    final email = _mobileToEmail(mobile);
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      options: AuthOptions(data: {'mobile_number': mobile}),
    );

    if (response.user != null) {
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'business_name': businessName ?? '',
        'business_prefix': businessPrefix ?? '',
        'mobile_number': mobile,
      });
    }
    return response;
  }

  Future<AuthResponse> signInWithMobile(String mobile, String password) async {
    final email = _mobileToEmail(mobile);
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<bool> isAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    final res = await _client
        .from('profiles')
        .select('is_admin')
        .eq('id', user.id)
        .single();
    return res.data != null && res.data['is_admin'] == true;
  }

  Future<void> signOut() async => _client.auth.signOut();
}
