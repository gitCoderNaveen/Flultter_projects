import 'dart:io';

import 'package:celfonephonebookapp/features/profile/service/profile_service.dart';

import '../model/profile_model.dart';

class ProfileRepository {
  ProfileRepository({
    ProfileService? service,
  }) : _service = service ?? ProfileService();

  final ProfileService _service;

  /// Get Logged-in User Profile
  Future<ProfileModel?> getCurrentUser() async {
    try {
      return await _service.getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  /// Update Profile
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _service.updateProfile(profile);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload Profile Image
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      return await _service.uploadProfileImage(imageFile);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload Product Images
  Future<List<String>> uploadProductImages(
    List<File> imageFiles,
  ) async {
    try {
      return await _service.uploadProductImages(imageFiles);
    } catch (e) {
      rethrow;
    }
  }

  /// Get Total Views
  Future<int> getViewsCount(String shopId) async {
    try {
      return await _service.getViewsCount(shopId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get Total Leads
  Future<int> getLeadsCount(String shopId) async {
    try {
      return await _service.getLeadsCount(shopId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get Recent Leads
  Future<List<Map<String, dynamic>>> getRecentLeads(
    String shopId,
  ) async {
    try {
      return await _service.getRecentLeads(shopId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete Profile Image
  Future<void> deleteProfileImage(
    String storagePath,
  ) async {
    try {
      await _service.deleteProfileImage(storagePath);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete Product Image
  Future<void> deleteProductImage(
    String storagePath,
  ) async {
    try {
      await _service.deleteProductImage(storagePath);
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh Profile
  Future<ProfileModel?> reloadProfile() async {
    return await getCurrentUser();
  }

  /// Dashboard Summary
  Future<Map<String, dynamic>> getDashboardSummary(
    String shopId,
  ) async {
    try {
      final profile = await getCurrentUser();

      final views = await getViewsCount(shopId);

      final leads = await getLeadsCount(shopId);

      final recent = await getRecentLeads(shopId);

      return {
        'profile': profile,
        'views': views,
        'leads': leads,
        'recentLeads': recent,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Save Complete Profile
  Future<void> saveCompleteProfile({
    required ProfileModel profile,
    File? profileImage,
    List<File>? productImages,
  }) async {
    try {
      ProfileModel updatedProfile = profile;

      /// Upload Profile Image
      if (profileImage != null) {
        final imageUrl =
            await uploadProfileImage(profileImage);

        if (imageUrl != null) {
          updatedProfile = updatedProfile.copyWith(
            profileImage: imageUrl,
          );
        }
      }

      /// Upload Product Images
      if (productImages != null &&
          productImages.isNotEmpty) {
        final urls =
            await uploadProductImages(productImages);

        updatedProfile = updatedProfile.copyWith(
          productImages: urls,
        );
      }

      await updateProfile(updatedProfile);
    } catch (e) {
      rethrow;
    }
  }
}