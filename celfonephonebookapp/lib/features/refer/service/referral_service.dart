import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/referral_model.dart';

class ReferralService {
  final _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  User? get currentUser => _client.auth.currentUser;

  Future<void> addReferral({
    required String name,
    required String phone,
    required String referralCode,
  }) async {
    await _client.from('referrals').insert({
      'referrer_id': currentUser!.id,
      'referred_name': name,
      'referred_phone': phone,
      'referral_code': referralCode,
    });
  }

  Future<List<ReferralModel>> getMyReferrals() async {
    final response = await _client
        .from('referrals')
        .select()
        .eq('referrer_id', currentUser!.id)
        .order('created_at', ascending: false);

    return (response as List).map((e) => ReferralModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>?> getCouponInfo() async {
    final response = await _client
        .from('referral_coupons')
        .select()
        .eq('user_id', currentUser!.id)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getCampaign() async {
    return await _client
        .from('winner_campaign')
        .select()
        .eq('is_active', true)
        .maybeSingle();
  }

  Future<int> getSuccessfulReferrals() async {
    final response = await _client
        .from('referrals')
        .select('id')
        .eq('referrer_id', currentUser!.id)
        .eq('joined', true);

    return (response as List).length;
  }

  Future<int> getPendingReferrals() async {
    final response = await _client
        .from('referrals')
        .select('id')
        .eq('referrer_id', currentUser!.id)
        .eq('joined', false);

    return (response as List).length;
  }

  Future<int> getCouponCount() async {
    final data = await _client
        .from('referral_coupons')
        .select('coupons')
        .eq('user_id', currentUser!.id)
        .maybeSingle();

    if (data == null) return 0;

    return data['coupons'] ?? 0;
  }
}
