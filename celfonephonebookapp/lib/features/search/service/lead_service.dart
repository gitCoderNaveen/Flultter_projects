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

      // shop_id is UUID - use as string directly
      final shopId = item['id']?.toString();

      if (shopId == null || shopId.isEmpty) {
        print('LEAD ERROR: shop_id is null or empty');
        return;
      }

      final shopName = item['business_name']?.toString().isNotEmpty == true
          ? item['business_name']
          : item['person_name'];
      final application = "DOWNLOAD CELFONBOOK APP FROM PLAYSTORE";

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
            "http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$cus_number&text=New Lead From CELFON BOOK App. We have a new lead from $viewerName needing products related to your activity. To view Contact details of the Lead, Please login here $application for support, Contact +91 97868 89092.&priority=ndnd&stype=normal",
          ),
          body: {"shop_id": shopId, "shop_name": shopName},
        );

        apiTriggered = response.statusCode == 200;
      }

      await supabase.from('leads').insert({
        "viewer_id": user.id,
        "viewer_name": viewerName,
        "shop_id": shopId,
        "shop_name": shopName,
        "is_verified": verified,
        "lead_sent": apiTriggered,
      });

      print('LEAD SUCCESS: shop=$shopName id=$shopId');
    } catch (e, stack) {
      print('LEAD ERROR: $e');
      print('STACK: $stack');
    }
  }
}
