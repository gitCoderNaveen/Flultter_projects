import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class MediaPartnerPage extends StatefulWidget {
  final bool returnedVerified;
  const MediaPartnerPage({super.key, this.returnedVerified = false});

  @override
  State<MediaPartnerPage> createState() => _MediaPartnerPageState();
}

class _MediaPartnerPageState extends State<MediaPartnerPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  bool isPersonTab = true;
  String contactType = 'Mobile';
  bool _isLoading = false;
  File? _imageFile;

  bool? _isMobileAvailable;
  bool _isCheckingMobile = false;
  String? _existingName;
  String selectedPrefix = '';

  bool? _isLandlineAvailable;
  bool _isCheckingLandline = false;
  String? _existingLandlineName;

  bool _isVerified = false;
  bool _isSendingOtp = false;

  final List<String> _selectedProducts = [];
  final TextEditingController _productInputController = TextEditingController();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _areaCodeController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();

  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _prefixFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.returnedVerified) {
      _isVerified = true;
    }
    _mobileController.addListener(_checkMobileExisting);
    _mobileController.addListener(_resetVerifiedOnMobileChange);
    _landlineController.addListener(_checkLandlineExisting);
    _focusNodes.forEach((key, node) {
      node.addListener(() {
        if (node.hasFocus) {
          setState(() {
            _activeField = key;
          });
        }
      });
    });
    _prefixFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _mobileController.removeListener(_checkMobileExisting);
    _mobileController.removeListener(_resetVerifiedOnMobileChange);
    _landlineController.removeListener(_checkLandlineExisting);
    _mobileFocusNode.dispose();
    _productInputController.dispose();
    _focusNodes.forEach((key, node) {
      node.dispose();
    });
    _prefixFocusNode.dispose();

    for (var c in [
      _mobileController,
      _cityController,
      _pincodeController,
      _addressController,
      _emailController,
      _areaCodeController,
      _landlineController,
      _personNameController,
      _professionController,
      _businessNameController,
      _contactPersonController,
    ]) {
      c.dispose();
    }

    super.dispose();
  }

  void _resetVerifiedOnMobileChange() {
    if (_isVerified) {
      setState(() {
        _isVerified = false;
      });
    }
  }

  String? _getHelpText(String field) {
    switch (field) {
      case 'mobile':
        return "Type 10 digits without country code (+91) without gap. Don't type Landline";
      case 'name':
        return "Type Initial at the end.";
      case 'profession':
        return "Mention profession (Doctor, Engineer, etc.)";
      case 'product':
        return "Type Correct & Specific Name of Product/Service offered. Separate Each Keyword By Comma. For example: Plumber, Electrician, Carpenter";
      case 'business':
        return "Type Your Business Name";
      case 'contactPerson':
        return "Person responsible for communication";
      case 'address':
        return "Type Door Number, Street, Flat No, Appartment Name, Landmark, Area Name etc.";
      case 'city':
        return "Enter city name";
      case 'pincode':
        return "Enter 6 digit postal code";
      case 'landlineCode':
        return "Type STD Code if Landline number is provided.";
      case 'landline':
        return "Type Only Landline, if Available. Don't Type Mobile Number here";
      case 'email':
        return "Enter valid email address only if available.";
      default:
        return null;
    }
  }

  void _addProduct() {
    final String product = _productInputController.text.trim();
    if (product.isNotEmpty && !_selectedProducts.contains(product)) {
      setState(() {
        _selectedProducts.add(product);
        _productInputController.clear();
      });
    }
  }

  void _removeProduct(String product) {
    setState(() {
      _selectedProducts.remove(product);
    });
  }

  Future<void> _checkMobileExisting() async {
    if (contactType != 'Mobile') return;
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      setState(() {
        _isMobileAvailable = null;
        _existingName = null;
      });
      return;
    }
    setState(() => _isCheckingMobile = true);
    try {
      final response = await supabase
          .from('profiles')
          .select('business_name, person_name')
          .eq('mobile_number', mobile)
          .maybeSingle();
      setState(() {
        _isMobileAvailable = (response == null);
        if (response != null) {
          _existingName =
              (response['business_name'] != null &&
                  response['business_name'].toString().isNotEmpty)
              ? response['business_name']
              : response['person_name'];
        } else {
          _existingName = null;
        }
        _isCheckingMobile = false;
      });
    } catch (e) {
      setState(() => _isCheckingMobile = false);
    }
  }

  Future<void> _checkLandlineExisting() async {
    if (contactType != 'Landline') return;
    final landline = _landlineController.text.trim();
    final areaCode = _areaCodeController.text.trim();
    if (landline.isEmpty || areaCode.isEmpty) return;
    final fullNumber = "$areaCode-$landline";
    setState(() => _isCheckingLandline = true);
    try {
      final response = await supabase
          .from('profiles')
          .select('business_name, person_name')
          .eq('landline', fullNumber)
          .maybeSingle();
      setState(() {
        _isLandlineAvailable = (response == null);
        if (response != null) {
          _existingLandlineName =
              (response['business_name'] != null &&
                  response['business_name'].toString().isNotEmpty)
              ? response['business_name']
              : response['person_name'];
        } else {
          _existingLandlineName = null;
        }
        _isCheckingLandline = false;
      });
    } catch (e) {
      setState(() => _isCheckingLandline = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _selectedProducts.clear();
    for (var c in [
      _mobileController,
      _cityController,
      _pincodeController,
      _addressController,
      _emailController,
      _areaCodeController,
      _landlineController,
      _personNameController,
      _professionController,
      _productInputController,
      _businessNameController,
      _contactPersonController,
    ]) {
      c.clear();
    }
    setState(() {
      _imageFile = null;
      _isMobileAvailable = null;
      _isLandlineAvailable = null;
      _existingName = null;
      _existingLandlineName = null;
      selectedPrefix = '';
      contactType = 'Mobile';
      _isVerified = false;
    });
  }

  final Map<String, FocusNode> _focusNodes = {
    'mobile': FocusNode(),
    'name': FocusNode(),
    'profession': FocusNode(),
    'product': FocusNode(),
    'business': FocusNode(),
    'contactPerson': FocusNode(),
    'address': FocusNode(),
    'city': FocusNode(),
    'pincode': FocusNode(),
    'landlineCode': FocusNode(),
    'landline': FocusNode(),
    'email': FocusNode(),
  };

  String? _activeField;

  String _generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSharePopup(String mobile) {
    String nameText = isPersonTab
        ? "$selectedPrefix ${_personNameController.text.trim()}"
        : "M/s. ${_businessNameController.text.trim()}";
    String businessName = _businessNameController.text.trim();
    String link =
        "https://play.google.com/store/apps/details?id=com.celfonphonebookapp&pcampaignid=web_share";
    String keywords = _productInputController.text.trim();
    String profession = _professionController.text.trim();

    TextEditingController messageController = TextEditingController(
      text: isPersonTab
          ? "Dear $nameText, CELFON BOOK is a Mobile App, with profiles of lakhs of mobile users. Your Details are also added based on field survay, online data, You are listed under your profession ${profession.toUpperCase()}. Kindly verify your details by clicking CELFON BOOK App at $link. "
          : "Dear $nameText CELFON BOOK is a Mobile App, with profiles of lakhs of mobile users. Your Firm $businessName is also added based on field survay, online data. You are listed under keywords ${keywords.toUpperCase()}. Kindly verify your details by clicking CELFON BOOK App at $link.",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Share Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Message",
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final message =
                          Uri.encodeComponent(messageController.text);
                      final mobileNumber = mobile;
                      if (mobileNumber.isEmpty) {
                        _showSnackBar(
                            "Mobile number not available", Colors.red);
                        return;
                      }
                      final Uri smsUri =
                          Uri.parse("sms:$mobileNumber?body=$message");
                      if (await canLaunchUrl(smsUri)) {
                        await launchUrl(smsUri);
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('images/sms.png', height: 45, width: 45),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreview() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Preview Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _previewRow("Type", isPersonTab ? "Person" : "Business"),
                _previewRow("Prefix", selectedPrefix),
                if (isPersonTab) ...[
                  _previewRow("Name", _personNameController.text),
                  _previewRow("Profession", _professionController.text),
                ] else ...[
                  _previewRow("Business Name", _businessNameController.text),
                  _previewRow("Contact Person", _contactPersonController.text),
                  _previewRow("Products", _productInputController.text),
                ],
                _previewRow("Mobile", _mobileController.text),
                _previewRow("Landline", _landlineController.text),
                _previewRow("City", _cityController.text),
                _previewRow("Pincode", _pincodeController.text),
                _previewRow("Address", _addressController.text),
                _previewRow("Email", _emailController.text),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Edit"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {
                Navigator.pop(context);
                _validateAndSave();
              },
              child: const Text("Confirm & Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _previewRow(String label, String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text("$label: $value", style: const TextStyle(fontSize: 14)),
    );
  }

  Future<void> _validateAndSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (contactType == 'Mobile' &&
        _mobileController.text.trim().isNotEmpty &&
        _isMobileAvailable == false) {
      _showSnackBar("Mobile number already exists!", Colors.red);
      return;
    }
    if (contactType == 'Landline' && _isLandlineAvailable == false) {
      _showSnackBar("Landline already exists!", Colors.red);
      return;
    }
    if (_landlineController.text.trim().isEmpty &&
        _mobileController.text.trim().isEmpty) {
      _showSnackBar(
          "Please enter either Mobile or Landline Number!", Colors.red);
      return;
    }
    if (selectedPrefix.isEmpty) {
      _showSnackBar("Please Select The Prefix Mr. or Mrs.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showSnackBar("Session expired.", Colors.red);
      setState(() => _isLoading = false);
      return;
    }
    try {
      String? imageUrl = await _uploadImage(user.id);
      DateTime now = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd').format(now);
      String startOfDay =
          DateTime(now.year, now.month, now.day).toIso8601String();
      String endOfDay =
          DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      // ✅ FIX: Use _isVerified so that if user verified via OTP,
      // verified = true is saved to DB. Otherwise verified = false.
      await supabase.from('profiles').insert({
        'user_type': isPersonTab ? 'person' : 'business',
        'person_name': isPersonTab
            ? _personNameController.text.trim()
            : _contactPersonController.text.trim(),
        'business_name':
            isPersonTab ? null : _businessNameController.text.trim(),
        'mobile_number': _mobileController.text.trim(),
        'landline': _landlineController.text.trim(),
        'landline_code': _areaCodeController.text.trim(),
        'person_prefix': selectedPrefix,
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'address': _addressController.text.trim(),
        'keywords': isPersonTab
            ? _professionController.text.trim()
            : _productInputController.text.trim(),
        'description': isPersonTab ? null : _selectedProducts.join(', '),
        'email': _emailController.text.trim(),
        'profile_image': imageUrl,
        'verified': _isVerified, // ✅ true if OTP verified, false otherwise
        'updated_at': DateTime.now().toIso8601String(),
      });

      final sProfileResponse = await supabase
          .from('s_profiles')
          .select('id, full_name')
          .eq('user_id', user.id)
          .single();
      final String sProfileId = sProfileResponse['id'];
      final String sProfileFullName = sProfileResponse['full_name'];

      await supabase.from('data_entry_name').insert({
        'user_id': sProfileId,
        'user_name': sProfileFullName,
        'entryname': isPersonTab
            ? _personNameController.text.trim()
            : _businessNameController.text.trim(),
        'entry_type':
            isPersonTab ? 'Person Profile Entry' : 'Business Profile Entry',
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      final countResponse = await supabase
          .from('data_entry_name')
          .select('id')
          .eq('user_id', sProfileId)
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay);
      final int todayCount = (countResponse as List).length;
      final int todayEarnings = todayCount * 2;

      await supabase.from('data_entry_table').upsert({
        'user_id': sProfileId,
        'user_name': sProfileFullName,
        'count': todayCount,
        'earnings': todayEarnings,
        'entry_date': todayDate,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,entry_date');

      _showSnackBar("Details saved successfully!", const Color(0xFF1F8EB6));
      final mobile = _mobileController.text.trim();
      _showSharePopup(mobile);
      _clearForm();
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_imageFile == null) return null;
    try {
      final fileExt = _imageFile!.path.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      await supabase.storage.from('partner').upload(fileName, _imageFile!);
      return supabase.storage.from('partner').getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  /// ✅ CORS-safe OTP send:
  /// 1. Generate OTP
  /// 2. Save to Supabase otp_verifications
  /// 3. Try SMS (ignore CORS error on web — works on real device)
  /// 4. Navigate to verify page regardless
  Future<void> _sendOtpAndNavigate() async {
    final phone = _mobileController.text.trim();

    if (phone.length != 10) {
      _showSnackBar("Enter a valid 10-digit mobile number", Colors.red);
      return;
    }

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final otp = _generateOtp();

    setState(() => _isSendingOtp = true);

    try {
      // Step 1: Delete old OTPs for this phone
      await Supabase.instance.client
          .from('otp_verifications')
          .delete()
          .eq('phone', cleanPhone);

      // Step 2: Save new OTP to Supabase
      await Supabase.instance.client.from('otp_verifications').insert({
        'phone': cleanPhone,
        'otp': otp,
      });

      // Step 3: Try SMS (fire and forget — CORS error on web is expected, works on real device)
      final smsUrl =
          "http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$cleanPhone&text=Your%20OTP%20for%20Signpost%20Celfon5G%20is:$otp.%20Use%20this%20OTP%20to%20verify%20your%20account.%20Do%20not%20share%20OTP%20with%20anyone.&priority=ndnd&stype=normal";

      http.get(Uri.parse(smsUrl)).catchError((e) {
        // CORS error on web browser — ignore, SMS will work on real Android/iOS device
        debugPrint("SMS send note (expected on web): $e");
        return http.Response('', 0);
      });

      // Step 4: Navigate to OTP verification and await result
      if (mounted) {
        final result =
            await context.push('/media_otp_verification', extra: cleanPhone);
        // ✅ If user verified successfully, mark _isVerified = true
        if (result == true && mounted) {
          setState(() {
            _isVerified = true;
          });
        }
      }
    } catch (e) {
      debugPrint("OTP Error: $e");
      _showSnackBar("Failed to prepare OTP. Check connection.", Colors.red);
    }

    if (mounted) setState(() => _isSendingOtp = false);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Media Partner"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F8EB6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabSelector(),
              const SizedBox(height: 20),
              _buildMobileField(),

              if (isPersonTab) ...[
                _buildPrefixRadio(),
                _underlineField("name", _personNameController, "Name", true),
                _underlineField(
                    "profession", _professionController, "Profession", false),
              ] else ...[
                _underlineField("business", _businessNameController,
                    "Business Name", true),
                _buildPrefixRadio(),
                _underlineField("contactPerson", _contactPersonController,
                    "Contact Person", false),
                _underlineField("product", _productInputController,
                    "Product / Service", true),
              ],

              _underlineField("address", _addressController, "Address", true),
              _underlineField("city", _cityController, "City", true),
              _underlineField(
                "pincode",
                _pincodeController,
                "Pincode",
                true,
                keyboard: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
              ),
              _underlineField(
                "landlineCode",
                _areaCodeController,
                "Landline code",
                false,
                keyboard: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 5,
              ),
              _underlineField(
                "landline",
                _landlineController,
                "Landline number",
                false,
                keyboard: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 15,
              ),
              _underlineField(
                "email",
                _emailController,
                "Email",
                false,
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 30),

              /// VERIFY NUMBER BUTTON
              _buildVerifyButton(),

              const SizedBox(height: 16),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F8EB6),
                  ),
                  onPressed: _isLoading ? null : _showPreview,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    if (_isVerified) {
      return Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade400),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: Colors.green, size: 22),
            SizedBox(width: 8),
            Text(
              "Verified",
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1F8EB6)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _isSendingOtp ? null : _sendOtpAndNavigate,
        icon: _isSendingOtp
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1F8EB6),
                ),
              )
            : const Icon(Icons.phone_android, color: Color(0xFF1F8EB6)),
        label: Text(
          _isSendingOtp ? "Sending..." : "Verify Number",
          style: const TextStyle(fontSize: 16, color: Color(0xFF1F8EB6)),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isPersonTab = true),
              child: Container(
                decoration: BoxDecoration(
                  color: isPersonTab
                      ? const Color(0xFF1F8EB6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Person",
                    style: TextStyle(
                      color: isPersonTab ? Colors.white : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isPersonTab = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isPersonTab
                      ? const Color(0xFF1F8EB6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Business",
                    style: TextStyle(
                      color: !isPersonTab ? Colors.white : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefixRadio() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Prefix",
              style: TextStyle(fontSize: 16, color: Colors.black)),
          if (_prefixFocusNode.hasFocus)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Select Mr. For Gents and Ms. for Ladies.",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  value: 'Mr.',
                  groupValue: selectedPrefix,
                  onChanged: (val) => setState(() => selectedPrefix = val!),
                  title: const Text("Mr."),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  value: 'Ms.',
                  groupValue: selectedPrefix,
                  onChanged: (val) => setState(() => selectedPrefix = val!),
                  title: const Text("Ms."),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _underlineField(
    String fieldKey,
    TextEditingController controller,
    String hint,
    bool required, {
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        focusNode: _focusNodes[fieldKey],
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          helperText: _activeField == fieldKey ? _getHelpText(fieldKey) : null,
          helperStyle: const TextStyle(color: Colors.redAccent),
          counterText: "",
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        validator: (v) {
          if (required && (v == null || v.isEmpty)) return "Required";
          return null;
        },
      ),
    );
  }

  Widget _buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: TextFormField(
            controller: _mobileController,
            focusNode: _focusNodes['mobile'],
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              helperText:
                  _activeField == 'mobile' ? _getHelpText('mobile') : null,
              helperStyle:
                  const TextStyle(color: Colors.red, fontSize: 14),
              hintText: "Mobile Number",
              hintStyle:
                  const TextStyle(color: Colors.grey, fontSize: 20),
              counterText: "",
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              suffixIcon: _isCheckingMobile
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_isMobileAvailable == true
                        ? const Icon(Icons.check_circle,
                            color: Colors.green)
                        : (_isMobileAvailable == false
                              ? const Icon(Icons.error, color: Colors.red)
                              : null)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              if (v.length != 10) return "Enter 10 digits";
              if (_isMobileAvailable == false) return "Already exists";
              return null;
            },
          ),
        ),
        if (_existingName != null && _mobileController.text.length == 10)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "⚠ Already Exist Name: $_existingName",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
