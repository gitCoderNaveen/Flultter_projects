import 'dart:io';
import 'package:flutter/material.dart';
import '../model/media_partner_model.dart';
import '../service/media_partner_service.dart';

class MediaPartnerController extends ChangeNotifier {
  final MediaPartnerService _service = MediaPartnerService();

  bool isLoading = false;

  Future<bool> checkMobile(String mobile) async {
    final result = await _service.checkMobile(mobile);

    return result == null;
  }

  Future<bool> checkLandline(String landline) async {
    final result = await _service.checkLandline(landline);

    return result == null;
  }

  Future<void> saveProfile({
    required MediaPartnerModel model,
    File? image,
    required String userId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      String? imageUrl;

      if (image != null) {
        imageUrl = await _service.uploadImage(image, userId);
      }

      final newModel = MediaPartnerModel(
        userType: model.userType,
        prefix: model.prefix,
        city: model.city,
        pincode: model.pincode,
        address: model.address,
        personName: model.personName,
        businessName: model.businessName,
        mobileNumber: model.mobileNumber,
        landline: model.landline,
        email: model.email,
        profession: model.profession,
        description: model.description,
        profileImage: imageUrl,
      );

      await _service.insertProfile(newModel);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
