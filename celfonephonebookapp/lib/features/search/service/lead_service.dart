import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class LeadService {
  final supabase = Supabase.instance.client;

  Future<void> createLead(Map item) async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final profile = await supabase
          .from('s_profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      final viewerName = profile?['full_name'] ?? "";

      final shopId = item['id'];

      final shopName = item['business_name']?.toString().isNotEmpty == true
          ? item['business_name']
          : item['person_name'];

      final cus_number = item['mobile_number'];

      /// check profile verified

      final shopProfile = await supabase
          .from('profiles')
          .select('verified')
          .eq('id', shopId)
          .maybeSingle();

      final verified = shopProfile?['verified'] ?? false;

      bool apiTriggered = false;

      if (verified) {
        final response = await http.post(
          Uri.parse(
            "http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$cus_number&text=Thanks for Regstering with Signpost Celfon5g+. Your login credintials are Username: $shopName, Password: $cus_number. Please login to your profile and edit if needed. Regards, Signpost Celfon Team&priority=ndnd&stype=normal",
          ),
          body: {"shop_id": "$shopId", "shop_name": shopName},
        );

        apiTriggered = response.statusCode == 200;
      }

      await supabase.from('leads').insert({
        "viewer_id": user.id,

        "viewer_name": viewerName,

        "shop_id": shopId,

        "shop_name": shopName,

        "is_verified": true,

        "lead_sent": apiTriggered,
      });
    } catch (e) {
      print(e);
    }
  }
}
