import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/profile_model.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get Logged-in User Profile
  Future<ProfileModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) return null;

      final phone = user.phone;

      if (phone == null || phone.isEmpty) {
        return null;
      }

      // Remove +91 if your database stores only 10 digits
      final mobileNumber = phone.startsWith('+91') ? phone.substring(3) : phone;

      // Check whether profile exists
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('mobile_number', mobileNumber)
          .maybeSingle();

      if (response != null) {
        return ProfileModel.fromMap(response);
      }

      // Create new profile
      final Map<String, dynamic> newProfile = {
        'id': user.id,
        'mobile_number': mobileNumber,
        'person_name': '',
        'business_name': '',
        'city': '',
        'email': user.email ?? '',
        'person_prefix': '',
        'keywords': '',
        'pincode': '',
        'landline_code': '',
        'landline_number': '',
        'whats_app': mobileNumber,
        'address': '',
        'profile_image': '',
        'description': '',
        'promo_code': '',
        'web_site': '',
        'product_images': [],
        'user_type': 'person',
        'is_business': false,
      };

      final inserted = await _supabase
          .from('profiles')
          .insert(newProfile)
          .select()
          .single();

      return ProfileModel.fromMap(inserted);
    } catch (e, stack) {
      debugPrint("Profile Load Error: $e");
      debugPrintStack(stackTrace: stack);
      throw Exception("Failed to load profile: $e");
    }
  }

  /// Update Profile
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _supabase
          .from('profiles')
          .update(profile.toMap())
          .eq('mobile_number', profile.mobileNumber);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload Profile Image
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) return null;

      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}";

      final storagePath = "profiles/${user.id}/$fileName";

      await _supabase.storage
          .from('profile-images')
          .upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = _supabase.storage
          .from('profile-images')
          .getPublicUrl(storagePath);

      return imageUrl;
    } catch (e) {
      throw Exception("Profile image upload failed: $e");
    }
  }

  /// Upload Product Images
  Future<List<String>> uploadProductImages(List<File> imageFiles) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) return [];

      List<String> urls = [];

      for (final image in imageFiles) {
        final fileName =
            "${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}";

        final storagePath = "products/${user.id}/$fileName";

        await _supabase.storage
            .from('product-images')
            .upload(
              storagePath,
              image,
              fileOptions: const FileOptions(upsert: true),
            );

        urls.add(
          _supabase.storage.from('product-images').getPublicUrl(storagePath),
        );
      }

      return urls;
    } catch (e) {
      throw Exception("Product image upload failed: $e");
    }
  }

  /// Get Total Views
  Future<int> getViewsCount(String shopId) async {
    try {
      final response = await _supabase
          .from('views')
          .select('views')
          .eq('shop_id', shopId);

      int total = 0;

      for (final item in response) {
        total += ((item['views'] ?? 1) as num).toInt();
      }

      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Get Total Leads
  Future<int> getLeadsCount(String shopId) async {
    try {
      final response = await _supabase
          .from('leads')
          .select()
          .eq('shop_id', shopId);

      return response.length;
    } catch (_) {
      return 0;
    }
  }

  /// Get Recent Leads
  Future<List<Map<String, dynamic>>> getRecentLeads(String shopId) async {
    try {
      final response = await _supabase
          .from('leads')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false)
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  /// Delete Profile Image
  Future<void> deleteProfileImage(String storagePath) async {
    try {
      await _supabase.storage.from('profile-images').remove([storagePath]);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Delete Product Image
  Future<void> deleteProductImage(String storagePath) async {
    try {
      await _supabase.storage.from('product-images').remove([storagePath]);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
