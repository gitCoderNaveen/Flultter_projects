import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/profile_model.dart';
import '../repository/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository();

  final ProfileRepository _repository;

  final ImagePicker _picker = ImagePicker();

  //===========================
  // STATE
  //===========================

  bool loading = false;

  bool saving = false;

  bool isBusiness = false;

  bool sameAsMobile = false;

  int viewsCount = 0;

  int leadsCount = 0;

  ProfileModel profile = ProfileModel.empty();

  List<Map<String, dynamic>> recentLeads = [];

  List<String> keywords = [];

  List<File> productImages = [];

  File? profileImageFile;
  String selectedPrefix = "Mr";

  //===========================
  // TEXT CONTROLLERS
  //===========================

  final personPrefixController = TextEditingController();

  final personNameController = TextEditingController();

  final businessNameController = TextEditingController();

  final professionController = TextEditingController();

  final descriptionController = TextEditingController();

  final addressController = TextEditingController();

  final mobileController = TextEditingController();

  final whatsappController = TextEditingController();

  final emailController = TextEditingController();

  final cityController = TextEditingController();

  final pincodeController = TextEditingController();

  final landlineCodeController = TextEditingController();

  final landlineController = TextEditingController();

  final websiteController = TextEditingController();

  final promoCodeController = TextEditingController();

  final keywordController = TextEditingController();

  //===========================
  // INITIALIZE
  //===========================

  Future<void> init() async {
    loading = true;
    notifyListeners();

    await loadProfile();

    loading = false;
    notifyListeners();
  }

  //===========================
  // Prefix Method
  //===========================
  void setPrefix(String value) {
    selectedPrefix = value;
    personPrefixController.text = value;
    notifyListeners();
  }

  //===========================
  // TOGGLE BUSINESS
  //===========================

  void toggleBusiness(bool value) {
    isBusiness = value;
    notifyListeners();
  }

  //===========================
  // SAME AS MOBILE
  //===========================

  void toggleSameAsMobile(bool value) {
    sameAsMobile = value;

    if (value) {
      whatsappController.text = mobileController.text;
    }

    notifyListeners();
  }

  //===========================
  // UPDATE FIELD
  //===========================

  void updateField({required String field, required String value}) {
    switch (field) {
      case "person_name":
        personNameController.text = value;
        break;

      case "business_name":
        businessNameController.text = value;
        break;

      case "person_prefix":
        personPrefixController.text = value;
        break;

      case "keywords":
        professionController.text = value;
        break;

      case "description":
        descriptionController.text = value;
        break;

      case "address":
        addressController.text = value;
        break;

      case "mobile_number":
        mobileController.text = value;

        if (sameAsMobile) {
          whatsappController.text = value;
        }

        break;

      case "whats_app":
        whatsappController.text = value;
        break;

      case "email":
        emailController.text = value;
        break;

      case "city":
        cityController.text = value;
        break;

      case "pincode":
        pincodeController.text = value;
        break;

      case "landline_code":
        landlineCodeController.text = value;
        break;

      case "landline_number":
        landlineController.text = value;
        break;

      case "web_site":
        websiteController.text = value;
        break;

      case "promo_code":
        promoCodeController.text = value;
        break;
    }

    notifyListeners();
  }

  //===========================
  // CLEAR FORM
  //===========================

  void clearForm() {
    personPrefixController.clear();

    personNameController.clear();

    businessNameController.clear();

    professionController.clear();

    descriptionController.clear();

    addressController.clear();

    mobileController.clear();

    whatsappController.clear();

    emailController.clear();

    cityController.clear();

    pincodeController.clear();

    landlineCodeController.clear();

    landlineController.clear();

    websiteController.clear();

    promoCodeController.clear();

    keywordController.clear();

    keywords.clear();

    productImages.clear();

    profileImageFile = null;

    profile = ProfileModel.empty();

    notifyListeners();
  }
  //==========================================================
  // LOAD PROFILE
  //==========================================================

  Future<void> loadProfile() async {
    try {
      loading = true;
      notifyListeners();

      final data = await _repository.getCurrentUser();

      if (data == null) {
        loading = false;
        notifyListeners();
        return;
      }

      profile = data;

      isBusiness = data.userType == "business" || data.isBusiness == true;

      /// Fill Controllers

      // personPrefixController.text = data.personPrefix;
      selectedPrefix = data.personPrefix.isEmpty ? "Mr" : data.personPrefix;
      personNameController.text = data.personName;
      businessNameController.text = data.businessName;
      professionController.text = data.keywords;
      descriptionController.text = data.description;
      addressController.text = data.address;
      mobileController.text = data.mobileNumber;
      whatsappController.text = data.whatsApp;
      emailController.text = data.email;
      cityController.text = data.city;
      pincodeController.text = data.pincode;
      landlineCodeController.text = data.landlineCode;
      landlineController.text = data.landlineNumber;
      websiteController.text = data.webSite;
      promoCodeController.text = data.promoCode;

      /// Keywords

      keywords.clear();

      if (data.keywords.isNotEmpty) {
        keywords.addAll(
          data.keywords
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }

      /// Dashboard

      viewsCount = await _repository.getViewsCount(data.id);

      leadsCount = await _repository.getLeadsCount(data.id);

      recentLeads = await _repository.getRecentLeads(data.id);

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();

      debugPrint(e.toString());
    }
  }

  //==========================================================
  // RELOAD PROFILE
  //==========================================================

  Future<void> reloadProfile() async {
    await loadProfile();
  }

  //==========================================================
  // PICK PROFILE IMAGE
  //==========================================================

  Future<void> pickProfileImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (file == null) return;

      profileImageFile = File(file.path);

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //==========================================================
  // PICK PRODUCT IMAGES
  //==========================================================

  Future<void> pickProductImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(imageQuality: 85);

      if (files.isEmpty) return;

      productImages.addAll(files.map((e) => File(e.path)));

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //==========================================================
  // REMOVE PRODUCT IMAGE
  //==========================================================

  void removeProductImage(int index) {
    if (index < 0 || index >= productImages.length) {
      return;
    }

    productImages.removeAt(index);

    notifyListeners();
  }

  //==========================================================
  // ADD KEYWORD
  //==========================================================

  void addKeyword() {
    final keyword = keywordController.text.trim();

    if (keyword.isEmpty) return;

    if (keywords.contains(keyword)) {
      keywordController.clear();
      return;
    }

    keywords.add(keyword);

    keywordController.clear();

    notifyListeners();
  }

  //==========================================================
  // REMOVE KEYWORD
  //==========================================================

  void removeKeyword(int index) {
    if (index < 0 || index >= keywords.length) {
      return;
    }

    keywords.removeAt(index);

    notifyListeners();
  }

  //==========================================================
  // CLEAR KEYWORDS
  //==========================================================

  void clearKeywords() {
    keywords.clear();

    notifyListeners();
  }

  //==========================================================
  // REMOVE PROFILE IMAGE
  //==========================================================

  void removeProfileImage() {
    profileImageFile = null;

    notifyListeners();
  }

  //==========================================================
  // IS VALID
  //==========================================================

  bool get isValid {
    if (personNameController.text.trim().isEmpty) {
      return false;
    }

    if (mobileController.text.trim().isEmpty) {
      return false;
    }

    if (isBusiness && businessNameController.text.trim().isEmpty) {
      return false;
    }

    return true;
  }
  //==========================================================
  // SAVE PROFILE
  //==========================================================

  Future<bool> saveProfile() async {
    try {
      if (!isValid) {
        throw Exception("Please fill all required fields.");
      }

      saving = true;
      notifyListeners();

      String profileImage = profile.profileImage;

      /// Upload Profile Image
      if (profileImageFile != null) {
        final url = await _repository.uploadProfileImage(profileImageFile!);

        if (url != null) {
          profileImage = url;
        }
      }

      /// Upload Product Images
      List<String> uploadedImages = profile.productImages;

      if (productImages.isNotEmpty) {
        uploadedImages = await _repository.uploadProductImages(productImages);
      }

      final updatedProfile = profile.copyWith(
        personPrefix: personPrefixController.text.trim(),
        personName: personNameController.text.trim(),
        businessName: businessNameController.text.trim(),
        keywords: isBusiness
            ? keywords.join(", ")
            : professionController.text.trim(),
        description: descriptionController.text.trim(),
        address: addressController.text.trim(),
        mobileNumber: mobileController.text.trim(),
        whatsApp: whatsappController.text.trim(),
        email: emailController.text.trim(),
        city: cityController.text.trim(),
        pincode: pincodeController.text.trim(),
        landlineCode: landlineCodeController.text.trim(),
        landlineNumber: landlineController.text.trim(),
        webSite: websiteController.text.trim(),
        promoCode: promoCodeController.text.trim(),
        profileImage: profileImage,
        productImages: uploadedImages,
        userType: isBusiness ? "business" : "person",
        isBusiness: isBusiness,
      );

      await _repository.updateProfile(updatedProfile);

      profile = updatedProfile;

      await reloadProfile();

      saving = false;

      notifyListeners();

      return true;
    } catch (e) {
      saving = false;

      notifyListeners();

      debugPrint("Save Profile Error");

      debugPrint(e.toString());

      return false;
    }
  }

  //==========================================================
  // RESET FORM
  //==========================================================

  void resetForm() {
    personPrefixController.text = profile.personPrefix;

    personNameController.text = profile.personName;

    businessNameController.text = profile.businessName;

    professionController.text = profile.keywords;

    descriptionController.text = profile.description;

    addressController.text = profile.address;

    mobileController.text = profile.mobileNumber;

    whatsappController.text = profile.whatsApp;

    emailController.text = profile.email;

    cityController.text = profile.city;

    pincodeController.text = profile.pincode;

    landlineCodeController.text = profile.landlineCode;

    landlineController.text = profile.landlineNumber;

    websiteController.text = profile.webSite;

    promoCodeController.text = profile.promoCode;

    keywords = profile.keywords.isEmpty
        ? []
        : profile.keywords.split(",").map((e) => e.trim()).toList();

    profileImageFile = null;

    productImages.clear();

    notifyListeners();
  }

  //==========================================================
  // HAS CHANGES
  //==========================================================

  bool get hasChanges {
    return personNameController.text != profile.personName ||
        personPrefixController.text != profile.personPrefix ||
        businessNameController.text != profile.businessName ||
        professionController.text != profile.keywords ||
        descriptionController.text != profile.description ||
        addressController.text != profile.address ||
        mobileController.text != profile.mobileNumber ||
        whatsappController.text != profile.whatsApp ||
        emailController.text != profile.email ||
        cityController.text != profile.city ||
        pincodeController.text != profile.pincode ||
        landlineCodeController.text != profile.landlineCode ||
        landlineController.text != profile.landlineNumber ||
        websiteController.text != profile.webSite ||
        promoCodeController.text != profile.promoCode ||
        profileImageFile != null ||
        productImages.isNotEmpty ||
        isBusiness != profile.isBusiness;
  }

  //==========================================================
  // DISPOSE
  //==========================================================

  @override
  void dispose() {
    personPrefixController.dispose();

    personNameController.dispose();

    businessNameController.dispose();

    professionController.dispose();

    descriptionController.dispose();

    addressController.dispose();

    mobileController.dispose();

    whatsappController.dispose();

    emailController.dispose();

    cityController.dispose();

    pincodeController.dispose();

    landlineCodeController.dispose();

    landlineController.dispose();

    websiteController.dispose();

    promoCodeController.dispose();

    keywordController.dispose();

    super.dispose();
  }
}
