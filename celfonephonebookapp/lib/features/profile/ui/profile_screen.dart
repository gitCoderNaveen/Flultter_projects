import 'dart:io';
import 'package:celfonephonebookapp/features/profile/model/user_profile_model.dart';
import 'package:celfonephonebookapp/features/profile/service/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  UserProfile? _user;

  bool _isIndividualTab = true;

  final _prefixController = TextEditingController();
  final _nameController = TextEditingController();
  final _professionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _landlineCodeController = TextEditingController();
  final _landlineNumberController = TextEditingController();
  final _whatsappController = TextEditingController();

  final _bPersonNameController = TextEditingController();
  final _bNameController = TextEditingController();
  final _bProductInputController = TextEditingController();
  final _bDescriptionController = TextEditingController();
  final _bAddressController = TextEditingController();
  final _bCityController = TextEditingController();
  final _bPincodeController = TextEditingController();
  final _bEmailController = TextEditingController();
  final _bLandlineCodeController = TextEditingController();
  final _bLandlineNumberController = TextEditingController();
  final _bWhatsappController = TextEditingController();
  final _bPromoCodeController = TextEditingController();
  final _bWebSiteController = TextEditingController();
  final _bProductImagesController = TextEditingController();

  List<String> _businessKeywords = [];
  String _mobileNumber = "Loading...";
  bool _isSameAsMobileInd = false;
  bool _isSameAsMobileBus = false;

  final List<String> _prefixOptions = ['Mr.', 'Ms.', 'Mrs.', 'Dr.', 'Er.'];
  String? _selectedPrefix;

  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userProfile = await _profileService.getCurrentUser();
      final authUser = Supabase.instance.client.auth.currentUser;

      if (mounted) {
        setState(() {
          _user = userProfile;
          _mobileNumber =
              userProfile?.mobileNumber ?? authUser?.phone ?? "No Number";

          if (userProfile != null) {
            if (userProfile.userType == 'business' ||
                userProfile.isBusiness == true) {
              _isIndividualTab = false;
            }

            _selectedPrefix = _prefixOptions.contains(userProfile.personPrefix)
                ? userProfile.personPrefix
                : null;
            _prefixController.text = userProfile.personPrefix ?? "";
            _nameController.text = userProfile.personName ?? "";
            _professionController.text =
                userProfile.profession ?? userProfile.keywords ?? "";
            _addressController.text = userProfile.address ?? "";
            _cityController.text = userProfile.city ?? "";
            _pincodeController.text = userProfile.pincode ?? "";
            _emailController.text = userProfile.email ?? "";
            _landlineCodeController.text = userProfile.landlineCode ?? "";
            _landlineNumberController.text = userProfile.landlineNumber ?? "";
            _whatsappController.text = userProfile.whatsApp ?? "";

            _bPersonNameController.text = userProfile.personName ?? "";
            _bNameController.text = userProfile.businessName ?? "";
            _bDescriptionController.text = userProfile.description ?? "";
            _bAddressController.text = userProfile.businessAddress ?? "";
            _bCityController.text = userProfile.city ?? "";
            _bPincodeController.text = userProfile.pincode ?? "";
            _bEmailController.text = userProfile.email ?? "";
            _bLandlineCodeController.text = userProfile.landlineCode ?? "";
            _bLandlineNumberController.text = userProfile.landlineNumber ?? "";
            _bWhatsappController.text = userProfile.whatsApp ?? "";
            _bPromoCodeController.text = userProfile.promoCode ?? "";
            _bWebSiteController.text = userProfile.webSite ?? "";
            _bProductImagesController.text = userProfile.productImages ?? "";

            if (userProfile.keywords != null &&
                userProfile.keywords!.isNotEmpty) {
              _businessKeywords = userProfile.keywords!
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }

            _isSameAsMobileInd =
                (_whatsappController.text == _mobileNumber &&
                _mobileNumber != "No Number");
            _isSameAsMobileBus =
                (_bWhatsappController.text == _mobileNumber &&
                _mobileNumber != "No Number");
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileData(bool isBusiness) async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> dataToSave;
      String userType = isBusiness ? 'business' : 'person';

      if (isBusiness) {
        List<String> finalKeywords = List.from(_businessKeywords);
        String currentInput = _bProductInputController.text.trim();
        if (currentInput.isNotEmpty && !finalKeywords.contains(currentInput)) {
          finalKeywords.add(currentInput);
        }

        dataToSave = {
          'user_type': userType,
          'person_name': _bPersonNameController.text.trim(),
          'business_name': _bNameController.text.trim(),
          'keywords': finalKeywords.join(', '),
          'description': _bDescriptionController.text.trim(),
          'bussiness_address': _bAddressController.text.trim(),
          'city': _bCityController.text.trim(),
          'pincode': _bPincodeController.text.trim(),
          'email': _bEmailController.text.trim(),
          'landline_code': _bLandlineCodeController.text.trim(),
          'landline_number': _bLandlineNumberController.text.trim(),
          'whats_app': _bWhatsappController.text.trim(),
          'promo_code': _bPromoCodeController.text.trim(),
          'web_site': _bWebSiteController.text.trim(),
          'product_images': _bProductImagesController.text.trim(),
          'is_business': true,
        };
      } else {
        dataToSave = {
          'user_type': userType,
          'person_prefix': _selectedPrefix,
          'person_name': _nameController.text.trim(),
          'keywords': _professionController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          'email': _emailController.text.trim(),
          'landline_code': _landlineCodeController.text.trim(),
          'landline_number': _landlineNumberController.text.trim(),
          'whats_app': _whatsappController.text.trim(),
          'is_business': false,
        };
      }

      dataToSave['mobile_number'] = _mobileNumber;
      await _profileService.updateProfileData(dataToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBusiness
                  ? 'Business Details Saved!'
                  : 'Individual Details Saved!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _bProductInputController.clear();
        _loadProfile();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickAndUploadProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _isUploadingImage = true);
        final newImageUrl = await _profileService.uploadProfileImage(
          File(pickedFile.path),
        );

        if (newImageUrl != null && mounted) {
          await _profileService.updateProfileData({
            'mobile_number': _mobileNumber,
            'profile_image': newImageUrl,
          });
          setState(() {
            if (_user != null) {
              _user!.profileImage = newImageUrl;
            } else {
              _user = UserProfile(
                id: 'current_user',
                profileImage: newImageUrl,
              );
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile Photo Updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _pickAndUploadProductImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _isLoading = true);
        final newImageUrl = await _profileService.uploadProductImage(
          File(pickedFile.path),
        );
        if (newImageUrl != null && mounted) {
          String updatedImages = _bProductImagesController.text;
          if (updatedImages.isNotEmpty)
            updatedImages += ', $newImageUrl';
          else
            updatedImages = newImageUrl;

          setState(() {
            _bProductImagesController.text = updatedImages;
            if (_user != null) _user!.productImages = updatedImages;
          });

          await _profileService.updateProfileData({
            'mobile_number': _mobileNumber,
            'product_images': updatedImages,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product Image Saved!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF1F8EB6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _profileService.signOut();
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _isUploadingImage
                        ? null
                        : _pickAndUploadProfileImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: const Color(0xFF1F8EB6),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                (_user?.profileImage != null &&
                                    _user!.profileImage!.isNotEmpty)
                                ? NetworkImage(_user!.profileImage!)
                                : null,
                            child:
                                (_user?.profileImage == null ||
                                    _user!.profileImage!.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1F8EB6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        if (_isUploadingImage)
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : "Your Name",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: _mobileNumber),
                      );
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mobile Number Copied!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _mobileNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1F8EB6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.copy,
                            size: 16,
                            color: Color(0xFF1F8EB6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isIndividualTab = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _isIndividualTab
                                    ? Color(0xFF1F8EB6)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Individual",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isIndividualTab
                                        ? Colors.white
                                        : Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isIndividualTab = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: !_isIndividualTab
                                    ? Color(0xFF1F8EB6)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Business",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !_isIndividualTab
                                        ? Colors.white
                                        : Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _isIndividualTab
                          ? _buildIndividualForm()
                          : _buildBusinessForm(),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildIndividualForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Individual Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F8EB6),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Prefix",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                ),
                value: _selectedPrefix,
                items: _prefixOptions
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPrefix = newValue;
                    _prefixController.text = newValue ?? "";
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField("Person Name", _nameController)),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField("Profession", _professionController),
        const SizedBox(height: 10),
        _buildTextField(
          "Address",
          _addressController,
          TextInputType.multiline,
          2,
        ),
        const SizedBox(height: 10),
        _buildReadOnlyMobile(),
        const SizedBox(height: 10),
        _buildTextField(
          "WhatsApp Number",
          _whatsappController,
          TextInputType.phone,
        ),
        _buildWhatsAppCheckbox(
          isSameAsMobile: _isSameAsMobileInd,
          controller: _whatsappController,
          onChanged: (val) => setState(() => _isSameAsMobileInd = val),
        ),
        _buildTextField("Email", _emailController, TextInputType.emailAddress),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 80,
              child: _buildTextField(
                "Code",
                _landlineCodeController,
                TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                "Landline Number",
                _landlineNumberController,
                TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField("City", _cityController)),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                "Pincode",
                _pincodeController,
                TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildSaveButton(isBusiness: false),
      ],
    );
  }

  Widget _buildBusinessForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Business Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F8EB6),
          ),
        ),
        const SizedBox(height: 15),
        _buildTextField("Person Name", _bPersonNameController),
        const SizedBox(height: 10),
        _buildTextField("Business Name", _bNameController),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildTextField(
                "Add Product / Service",
                _bProductInputController,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFF1F8EB6),
                size: 40,
              ),
              onPressed: () {
                final text = _bProductInputController.text.trim();
                if (text.isNotEmpty && !_businessKeywords.contains(text)) {
                  setState(() {
                    _businessKeywords.add(text);
                    _bProductInputController.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (_businessKeywords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _businessKeywords
                  .map(
                    (kw) => Chip(
                      label: Text(kw),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      backgroundColor: Colors.indigo.shade50,
                      onDeleted: () {
                        setState(() => _businessKeywords.remove(kw));
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 10),
        _buildTextField(
          "Description",
          _bDescriptionController,
          TextInputType.multiline,
          3,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          "Business Address",
          _bAddressController,
          TextInputType.multiline,
          2,
        ),
        const SizedBox(height: 10),
        _buildReadOnlyMobile(),
        const SizedBox(height: 10),
        _buildTextField(
          "WhatsApp Number",
          _bWhatsappController,
          TextInputType.phone,
        ),
        _buildWhatsAppCheckbox(
          isSameAsMobile: _isSameAsMobileBus,
          controller: _bWhatsappController,
          onChanged: (val) => setState(() => _isSameAsMobileBus = val),
        ),
        _buildTextField("Email", _bEmailController, TextInputType.emailAddress),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 80,
              child: _buildTextField(
                "Code",
                _bLandlineCodeController,
                TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                "Landline Number",
                _bLandlineNumberController,
                TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField("City", _bCityController)),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                "Pincode",
                _bPincodeController,
                TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField("Website URL", _bWebSiteController, TextInputType.url),
        const SizedBox(height: 10),
        _buildTextField("Promo Code", _bPromoCodeController),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildTextField(
                "Product Images (URLs)",
                _bProductImagesController,
                TextInputType.url,
                2,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _pickAndUploadProductImage,
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text("Upload"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F8EB6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildSaveButton(isBusiness: true),
      ],
    );
  }

  Widget _buildReadOnlyMobile() {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Mobile Number",
        hintText: _mobileNumber,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: IconButton(
          icon: const Icon(Icons.copy, color: Color(0xFF1F8EB6)),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: _mobileNumber));
            if (context.mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mobile Number Copied!'),
                  backgroundColor: Colors.green,
                ),
              );
          },
        ),
      ),
    );
  }

  Widget _buildWhatsAppCheckbox({
    required bool isSameAsMobile,
    required TextEditingController controller,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Checkbox(
          value: isSameAsMobile,
          activeColor: const Color(0xFF1F8EB6),
          onChanged: (bool? value) {
            final isChecked = value ?? false;
            onChanged(isChecked);
            if (isChecked) {
              controller.text = _mobileNumber;
            } else {
              controller.clear();
            }
          },
        ),
        const Text(
          "Same as Mobile Number",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSaveButton({required bool isBusiness}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F8EB6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _saveProfileData(isBusiness),
        child: const Text(
          "Save Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, [
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  ]) {
    List<TextInputFormatter> formatters = [];
    int? maxLength;

    if (type == TextInputType.phone || type == TextInputType.number) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);

      if (label.contains("WhatsApp")) {
        maxLength = 10;
      } else if (label.contains("Pincode")) {
        maxLength = 6;
      } else if (label.contains("Code")) {
        maxLength = 5;
      } else if (label.contains("Landline Number")) {
        maxLength = 8;
      }
    } else if (label.contains("Person Name") ||
        label.contains("City") ||
        (label.contains("Profession") && _isIndividualTab)) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')));
    }

    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}
