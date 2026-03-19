// controllers/admin_controller.dart

import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:celfonephonebookapp/features/admin/model/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController {
  final supabase = SupabaseService.client;

  // Get current user
  get currentUser => supabase.auth.currentUser;

  Future<String?> getCurrentUserDisplayName() async {
    final user = currentUser;

    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select('business_name, person_name')
        .eq('id', user.id)
        .single();

    final businessName = data['business_name'];
    final personName = data['person_name'];

    return businessName ?? personName ?? "No Name";
  }

  // Fetch profiles
  Future<List<Profile>> fetchProfiles() async {
    final data = await supabase.from('profiles').select();

    return data.map<Profile>((e) => Profile.fromJson(e)).toList();
  }

  Future<void> deleteProfile(String id) async {
    await supabase.from('profiles').delete().eq('id', id);
  }

  // Count profiles
  Future<int> getProfilesCount() async {
    final res = await supabase
        .from('profiles')
        .select()
        .count(CountOption.exact);

    return res.count ?? 0;
  }

  // Update profile
  Future<void> updateProfile({
    required String id,
    required String name,
    required String phone,
  }) async {
    await supabase
        .from('profiles')
        .update({'business_name': name, 'mobile_number': phone})
        .eq('id', id);

    // Insert audit log
    await supabase.from('admin_update_details').insert({
      'admin_user_id': currentUser!.id,
      'selected_card_id': id,
      'updated_details': {'name': name, 'phone': phone},
    });
  }
}
