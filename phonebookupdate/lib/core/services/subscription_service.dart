import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  static Future<Map<String, dynamic>> activeFeatures() async {
    final user = Supabase.instance.client.auth.currentUser!;

    final res = await Supabase.instance.client
        .from('user_subscriptions')
        .select('subscription_plans(features)')
        .eq('user_id', user.id)
        .eq('status', 'active')
        .single();

    return res['subscription_plans']['features'];
  }
}
