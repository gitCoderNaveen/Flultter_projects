import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './homepage_shell.dart'; // <--- UPDATED: Imports the Shell page

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  
  // State variables
  String signupType = "business"; // Options: "person" or "business"
  bool isLoading = false;
  
  // --- Controllers ---
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final addressController = TextEditingController();
  final promoCodeController = TextEditingController();

  // Person Specific
  final personNameController = TextEditingController();
  String? personPrefix = "--";
  
  // Business Specific
  final businessNameController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Shared / Contextual
  final keywordsController = TextEditingController(); // Profession (Person) or Products (Business)
  final landlineController = TextEditingController();
  final landlineCodeController = TextEditingController();

  // Focus Nodes & Help Text Logic
  final Map<TextEditingController, FocusNode> _focusNodes = {};
  final Map<TextEditingController, bool> _showHelp = {};

  // Mobile Verification State
  Timer? _debounce;
  bool _isCheckingMobile = false;
  bool _mobileExists = false;
  String? _mobileMsg;
  String _lastCheckToken = "";

  @override
  void initState() {
    super.initState();
    _setupFocusNodes();
  }

  void _setupFocusNodes() {
    // Helper to initialize focus listeners for help text
    void initFocus(TextEditingController ctrl, String help) {
      final node = FocusNode();
      _focusNodes[ctrl] = node;
      _showHelp[ctrl] = false;
      node.addListener(() {
        if (mounted) setState(() => _showHelp[ctrl] = node.hasFocus);
      });
    }

    initFocus(mobileController, "Enter a 10-digit Indian mobile number (starts with 6-9).");
    initFocus(emailController, "Enter a valid email address.");
    initFocus(cityController, "Enter the city name.");
    initFocus(pincodeController, "Enter a 6-digit pincode.");
    initFocus(addressController, "Enter the full address.");
    initFocus(personNameController, "Enter the person's full name.");
    initFocus(businessNameController, "Enter the firm / business name.");
    initFocus(keywordsController, "Enter profession (person) or products (business).");
    initFocus(landlineController, "Enter the landline number (numbers only).");
    initFocus(landlineCodeController, "Enter the STD code (numbers only).");
    initFocus(promoCodeController, "Enter your promo code (if any).");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    mobileController.dispose();
    emailController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    addressController.dispose();
    personNameController.dispose();
    keywordsController.dispose();
    businessNameController.dispose();
    descriptionController.dispose();
    landlineController.dispose();
    landlineCodeController.dispose();
    promoCodeController.dispose();
    super.dispose();
  }

  // --- Logic: Check Mobile Existence ---
  void _onMobileChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _mobileMsg = null;
      _mobileExists = false;
    });

    final trimmed = value.trim();
    // Only check if it matches the pattern 
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) return;

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkMobileExists(trimmed);
    });
  }

  Future<void> _checkMobileExists(String mobile) async {
    final checkToken = mobile;
    setState(() {
      _isCheckingMobile = true;
      _lastCheckToken = checkToken;
    });

    try {
      // Using Standard Supabase Instance
      final res = await Supabase.instance.client
          .from('profiles')
          .select('business_name, person_name')
          .eq('mobile_number', mobile)
          .maybeSingle();

      if (!mounted || _lastCheckToken != checkToken) return;

      if (res != null) {
        final business = (res['business_name'] as String?)?.trim();
        final person = (res['person_name'] as String?)?.trim();
        setState(() {
          _mobileExists = true;
          _mobileMsg = business != null && business.isNotEmpty
              ? "Mobile already registered: $business"
              : "Mobile already registered: ${person ?? '-'}";
        });
      } else {
        setState(() {
          _mobileExists = false;
          _mobileMsg = "Mobile available";
        });
      }
    } catch (e) {
      if (mounted) {
          setState(() {
          _mobileExists = false;
          _mobileMsg = "Couldn’t verify mobile";
        });
      }
    } finally {
      if (mounted && _lastCheckToken == checkToken) {
        setState(() => _isCheckingMobile = false);
      }
    }
  }

  // --- Logic: Submit Form ---
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    
    final mobile = mobileController.text.trim();
    if (_mobileExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mobileMsg ?? "Mobile already registered"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Prepare Data Payload
      final Map<String, dynamic> profileData = {
        "user_type": signupType,
        "mobile_number": mobile,
        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "address": addressController.text.trim(),
        "email": emailController.text.trim(),
        "person_prefix": personPrefix,
        "landline": landlineController.text.trim(),
        "landline_code": landlineCodeController.text.trim(),
        "promo_code": promoCodeController.text.trim(),
      };

      String displayName = "";
      if (signupType == "person") {
        profileData.addAll({
          "person_name": personNameController.text.trim(),
          "business_name": businessNameController.text.trim(), // Optional for person
          "keywords": keywordsController.text.trim(), // Profession
        });
        displayName = personNameController.text.trim();
      } else {
        profileData.addAll({
          "business_name": businessNameController.text.trim(),
          "person_name": personNameController.text.trim(), // Contact person
          "keywords": keywordsController.text.trim(), // Products
        });
        displayName = businessNameController.text.trim();
      }

      // Insert into Supabase Table
      await Supabase.instance.client.from("profiles").insert(profileData);

      if (!mounted) return;

      // Success Dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Registration Successful 🎉"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${displayName.isNotEmpty ? displayName : "User"} registered successfully.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text("Username: $mobile"),
              const Text("Password: signpost"), // Hardcoded based on your requirements
              const SizedBox(height: 16),
              const Text(
                "📌 Note: Please take a screenshot.",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // --- UPDATED NAVIGATION ---
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePageShell()), 
                  (route) => false,
                );
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- UI Builders ---

  // Helper for text fields
  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    // Basic mapping for help text
    String helpText = "";
    if (controller == mobileController) helpText = "Enter 10-digit mobile.";
    else if (controller == pincodeController) helpText = "6-digit Pincode.";
    // ... add others if strict help text matching is needed per controller
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: _focusNodes[controller],
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: controller == mobileController ? _onMobileChanged : null,
        ),
        // Show help text if focused (and we have help text mapped)
        if (_showHelp[controller] == true)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, bottom: 8),
            child: Text(
              "Start typing to see help...", // Or map specific strings
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        else 
          const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPersonForm() {
    return Column(
      children: [
        _field(
          controller: personNameController,
          label: "Person Name",
          validator: (v) => v?.isEmpty ?? true ? "Required" : null,
        ),
        DropdownButtonFormField<String>(
          value: personPrefix,
          decoration: const InputDecoration(labelText: "Prefix", border: OutlineInputBorder()),
          items: ["--", "Mr.", "Ms.", "Mrs.", "Dr."]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => personPrefix = val),
        ),
        const SizedBox(height: 16),
        _field(controller: businessNameController, label: "Firm Name (Optional)"),
        _field(controller: cityController, label: "City"),
        _field(
          controller: pincodeController,
          label: "Pincode",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          validator: (v) => (v?.length != 6) ? "Enter valid 6-digit pincode" : null,
        ),
        _field(controller: addressController, label: "Address", validator: (v) => v!.isEmpty ? "Required" : null),
        _field(controller: keywordsController, label: "Profession", validator: (v) => v!.isEmpty ? "Required" : null),
        _field(controller: emailController, label: "Email", keyboardType: TextInputType.emailAddress),
        Row(
          children: [
            Expanded(child: _field(controller: landlineCodeController, label: "STD Code", keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _field(controller: landlineController, label: "Landline", keyboardType: TextInputType.number)),
          ],
        ),
        _field(controller: promoCodeController, label: "Promo Code"),
      ],
    );
  }

  Widget _buildBusinessForm() {
    return Column(
      children: [
        _field(
          controller: businessNameController,
          label: "Firm Name",
          validator: (v) => v?.isEmpty ?? true ? "Required" : null,
        ),
        _field(controller: personNameController, label: "Contact Person Name"),
        _field(controller: cityController, label: "City", validator: (v) => v!.isEmpty ? "Required" : null),
        _field(
          controller: pincodeController,
          label: "Pincode",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          validator: (v) => (v?.length != 6) ? "Enter valid 6-digit pincode" : null,
        ),
        _field(controller: addressController, label: "Address", validator: (v) => v!.isEmpty ? "Required" : null),
        _field(controller: keywordsController, label: "Products / Services", validator: (v) => v!.isEmpty ? "Required" : null),
        _field(controller: emailController, label: "Email", keyboardType: TextInputType.emailAddress),
        Row(
          children: [
            Expanded(child: _field(controller: landlineCodeController, label: "STD Code", keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _field(controller: landlineController, label: "Landline", keyboardType: TextInputType.number)),
          ],
        ),
        _field(controller: promoCodeController, label: "Promo Code"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = mobileController.text.trim();
    final mobileLooksValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Column(
        children: [
          // --- Type Toggle ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => signupType = "person"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: signupType == "person" ? Colors.indigo : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text("Person", 
                            style: TextStyle(
                              color: signupType == "person" ? Colors.white : Colors.black, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => signupType = "business"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: signupType == "business" ? Colors.indigo : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text("Business", 
                             style: TextStyle(
                              color: signupType == "business" ? Colors.white : Colors.black, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- Scrollable Form ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      controller: mobileController,
                      label: "Mobile Number",
                      hint: "9876543210",
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) => !RegExp(r'^[6-9]\d{9}$').hasMatch(v ?? '') 
                          ? "Invalid mobile number" 
                          : null,
                      suffixIcon: _isCheckingMobile
                          ? const UnconstrainedBox(
                              child: SizedBox(
                                width: 20, height: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2)
                              )
                            )
                          : (mobileLooksValid && _mobileMsg != null)
                              ? Icon(
                                  _mobileExists ? Icons.error : Icons.check_circle,
                                  color: _mobileExists ? Colors.red : Colors.green,
                                )
                              : null,
                    ),
                    if (_mobileMsg != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _mobileMsg!,
                          style: TextStyle(
                            color: _mobileExists ? Colors.red : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    
                    if (signupType == "person") _buildPersonForm(),
                    if (signupType == "business") _buildBusinessForm(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          
          // --- Bottom Button ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Register as ${signupType.toUpperCase()}"),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Utility extension
extension StringExtension on String {
  String capitalize() => isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}