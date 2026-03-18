import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/discount_greeting_model.dart';

class DiscountGreetingService {
  Future<DiscountGreetingCard?> fetchGreetingCard(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('discount_greeting_cards')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return DiscountGreetingCard.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> recordDiscountView({
    required String listingId,
    required String businessName,
    required String personName,
    required String mobileNumber,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    await Supabase.instance.client.from('discount_views').insert({
      'user_id': user.id,
      'listing_id': listingId,
      'business_name': businessName,
      'person_name': personName,
      'mobile_number': mobileNumber,
    });
  }

  Future<void> saveDiscountView(String discountId) async {
    final client = Supabase.instance.client;

    final user = client.auth.currentUser;

    if (user == null) return;

    /// Fetch user details from profiles
    final profile = await client
        .from('profiles')
        .select('business_name, person_name, mobile_number')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return;

    /// Insert into discount_views
    await client.from('discount_views').insert({
      'user_id': user.id,
      'listing_id': discountId,
      'business_name': profile['business_name'],
      'person_name': profile['person_name'],
      'mobile_number': profile['mobile_number'],
    });
  }

  Future<void> claimDiscount(String discountId) async {
    await Supabase.instance.client
        .from('discount_greeting_cards')
        .update({'claimed_at': DateTime.now().toIso8601String()})
        .eq('id', discountId);
  }
}
