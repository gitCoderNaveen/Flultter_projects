import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MediaPartnerPage extends StatefulWidget {
  const MediaPartnerPage({super.key});

  @override
  State<MediaPartnerPage> createState() => _MediaPartnerPageState();
}

class _MediaPartnerPageState extends State<MediaPartnerPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  bool isPersonTab = true;
  String selectedPrefix = 'Mr.';
  String contactType = 'Mobile';
  bool _isLoading = false;
  File? _imageFile;

  bool? _isMobileAvailable;
  bool _isCheckingMobile = false;
  String? _existingName;

  bool? _isLandlineAvailable;
  bool _isCheckingLandline = false;
  String? _existingLandlineName;

  final List<String> _selectedProducts = [];
  final TextEditingController _productInputController = TextEditingController();

  final RegExp _nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
  final RegExp _emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

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
    _mobileController.addListener(_checkMobileExisting);
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

  void _onFieldTap() {
    if (contactType == 'Mobile' &&
        _mobileController.text.length == 10 &&
        _isMobileAvailable == false) {
      setState(() {
        _mobileController.clear();
        _existingName = null;
        _isMobileAvailable = null;
      });
    } else if (contactType == 'Landline' &&
        _landlineController.text.isNotEmpty &&
        _isLandlineAvailable == false) {
      setState(() {
        _landlineController.clear();
        _existingLandlineName = null;
        _isLandlineAvailable = null;
      });
    }
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
      selectedPrefix = 'Mr.';
      contactType = 'Mobile';
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
        "Please enter either Mobile or Landline Number!",
        Colors.red,
      );
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
      String startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String();
      String endOfDay = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      ).toIso8601String();

      await supabase.from('profiles').insert({
        'user_type': isPersonTab ? 'person' : 'business',
        'person_name': isPersonTab
            ? _personNameController.text.trim()
            : _contactPersonController.text.trim(),
        'business_name': isPersonTab
            ? null
            : _businessNameController.text.trim(),
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
        'entry_type': isPersonTab
            ? 'Person Profile Entry'
            : 'Business Profile Entry',
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

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
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
              /// PERSON / BUSINESS TOGGLE
              _buildTabSelector(),

              const SizedBox(height: 20),

              /// MOBILE
              _buildMobileField(),

              /// IDENTITY
              if (isPersonTab) ...[
                _buildPrefixDropdown(),
                _underlineField("name", _personNameController, "Name", true),
                _underlineField(
                  "profession",
                  _professionController,
                  "Profession",
                  false,
                ),
              ] else ...[
                _underlineField(
                  "business",
                  _businessNameController,
                  "Business Name",
                  true,
                ),
                _buildPrefixDropdown(),
                _underlineField(
                  "contactPerson",
                  _contactPersonController,
                  "Contact Person",
                  false,
                ),
                _underlineField(
                  "product",
                  _productInputController,
                  "Product / Service",
                  true,
                ),
              ],

              /// ADDRESS
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

              /// Landline
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

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F8EB6),
                  ),
                  onPressed: _isLoading ? null : _validateAndSave,
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

  Widget _buildPrefixDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        focusNode: _prefixFocusNode,
        value: selectedPrefix,
        decoration: InputDecoration(
          labelText: "Prefix",
          helperText: _prefixFocusNode.hasFocus
              ? "Select Mr. For Gents and Ms. for Ladies."
              : null,
          helperStyle: const TextStyle(color: Colors.red, fontSize: 14),
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 20),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        items: [
          'Mr.',
          'Ms.',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) {
          setState(() => selectedPrefix = val!);
        },
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
          if (required && (v == null || v.isEmpty)) {
            return "Required";
          }
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
              helperText: _activeField == 'mobile'
                  ? _getHelpText('mobile')
                  : null,
              helperStyle: const TextStyle(color: Colors.red, fontSize: 14),
              hintText: "Mobile Number",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 20),
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_isMobileAvailable == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
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

        /// Already Existing Name Warning
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
