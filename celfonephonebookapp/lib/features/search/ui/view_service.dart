import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:celfonephonebookapp/core/services/auth_service.dart';

class ViewService {
  final supabase = Supabase.instance.client;

  Future<void> saveView(Map item) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      /// get viewer name
      final profile = await supabase
          .from('s_profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      final viewerName = profile?['full_name'] ?? "";

      final viewerId = user.id;

      final shopName = item['business_name']?.toString().isNotEmpty == true
          ? item['business_name']
          : item['person_name'];

      final shopId = item['id'];

      /// check existing row
      final existing = await supabase
          .from('views')
          .select('id, views')
          .eq('viewer_id', viewerId)
          .eq('shop_id', shopId)
          .maybeSingle();

      if (existing != null) {
        /// already exists -> increment views
        final currentViews = existing['views'] ?? 0;

        await supabase
            .from('views')
            .update({'views': currentViews + 1})
            .eq('id', existing['id']);
      } else {
        /// first time view -> insert
        await supabase.from('views').insert({
          'viewer_name': viewerName,
          'viewer_id': viewerId,
          'shop_name': shopName,
          'shop_id': shopId,
          'views': 1,
        });
      }
    } catch (e) {
      print("Save View Error: $e");
    }
  }
}
