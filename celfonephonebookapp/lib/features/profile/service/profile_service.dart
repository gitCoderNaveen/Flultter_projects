import 'dart:io';
import 'package:celfonephonebookapp/Supabase/Supabase.dart';
import 'package:celfonephonebookapp/features/profile/model/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = SupbaseService.client;

  Future<UserProfile?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final dataById = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (dataById != null) {
        return UserProfile.fromSupabase(dataById);
      }

      final phone = user.phone ?? '';
      if (phone.isNotEmpty) {
        final dataByPhone = await _client
            .from('profiles')
            .select()
            .eq('mobile_number', phone)
            .maybeSingle();

        if (dataByPhone != null) {
          await _client
              .from('profiles')
              .update({'id': user.id})
              .eq('mobile_number', phone);

          final updated = Map<String, dynamic>.from(dataByPhone);
          updated['id'] = user.id;
          return UserProfile.fromSupabase(updated);
        }
      }

      return UserProfile(id: user.id, mobileNumber: user.phone);
    } catch (e) {
      print("Fetch Error: $e");
      return UserProfile(id: user.id, mobileNumber: user.phone);
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> data) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    data['updated_at'] = DateTime.now().toIso8601String();
    data['id'] = user.id;

    final existingById = await _client
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existingById != null) {
      await _client.from('profiles').update(data).eq('id', user.id);
      return;
    }

    final phone = data['mobile_number']?.toString() ?? user.phone ?? '';
    if (phone.isNotEmpty) {
      final existingByPhone = await _client
          .from('profiles')
          .select('id')
          .eq('mobile_number', phone)
          .maybeSingle();

      if (existingByPhone != null) {
        await _client.from('profiles').update(data).eq('mobile_number', phone);
        return;
      }
    }

    await _client.from('profiles').insert(data);
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final ext = imageFile.path.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _client.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );
      return _client.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      print("Profile Image Upload Error: $e");
      return null;
    }
  }

  Future<String?> uploadProductImage(File imageFile) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final ext = imageFile.path.split('.').last;
      final fileName =
          'prod_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _client.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );
      return _client.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      print("Product Image Upload Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
