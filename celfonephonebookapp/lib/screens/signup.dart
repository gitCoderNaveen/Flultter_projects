import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase.dart';
import './homepage_shell.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String signupType = "business"; // default
  bool isLoading = false;

  // Controllers
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final addressController = TextEditingController();

  // Person
  final personNameController = TextEditingController();
  String? personPrefix = "--"; // ✅ default
  final keywordsController = TextEditingController(); // profession/products

  // Business
  final businessNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final landlineController = TextEditingController();
  final landlineCodeController = TextEditingController();

  Timer? _debounce;
  bool _isCheckingMobile = false;
  bool _mobileExists = false;
  String? _mobileMsg;
  String _lastCheckToken = "";

  @override
  void dispose() {
    _debounce?.cancel();
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
    super.dispose();
  }

  // ===== Mobile Check (same as before) =====
  void _onMobileChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _mobileMsg = null;
      _mobileExists = false;
    });

    final trimmed = value.trim();
    final isPatternOk = RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed);
    if (!isPatternOk) return;

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
      final res = await SupabaseService.client
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
              ? "Mobile already registered with Business: $business"
              : "Mobile already registered with Person: ${person ?? '-'}";
        });
      } else {
        setState(() {
          _mobileExists = false;
          _mobileMsg = "Mobile available ✓";
        });
      }
    } catch (e) {
      setState(() {
        _mobileExists = false;
        _mobileMsg = "Couldn’t verify mobile (check RLS/connection)";
      });
    } finally {
      if (mounted && _lastCheckToken == checkToken) {
        setState(() => _isCheckingMobile = false);
      }
    }
  }

  // ===== Validators =====
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Enter valid Indian mobile number";
    }
    return null;
  }
  String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) return "Enter city";
    return null;
  }


  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Enter pincode";
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return "Enter valid 6-digit pincode";
    return null;
  }

  // ===== Person Form =====
  Widget _buildPersonForm() => Column(
    children: [
      TextFormField(
        controller: personNameController,
        decoration: const InputDecoration(labelText: "Person Name"),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      DropdownButtonFormField<String>(
        value: personPrefix,
        items: const [
          DropdownMenuItem(value: "--", child: Text("--")),
          DropdownMenuItem(value: "Mr.", child: Text("Mr.")),
          DropdownMenuItem(value: "Ms.", child: Text("Ms.")),
        ],
        onChanged: (val) => setState(() => personPrefix = val),
        decoration: const InputDecoration(labelText: "Prefix"),
      ),
      TextFormField(
        controller: businessNameController,
        decoration: const InputDecoration(labelText: "Firm Name"),
      ),
      TextFormField(
        controller: cityController,
        decoration: const InputDecoration(labelText: "City"),
      ),
      TextFormField(
        controller: pincodeController,
        decoration: const InputDecoration(labelText: "Pincode"),
        validator: validatePincode,
      ),
      TextFormField(
        controller: addressController,
        decoration: const InputDecoration(labelText: "Address"),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      TextFormField(
        controller: keywordsController,
        decoration: const InputDecoration(labelText: "Profession"),
        // validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      TextFormField(
        controller: emailController,
        decoration: const InputDecoration(labelText: "Email"),
      ),
      TextFormField(
        controller: landlineController,
        decoration: const InputDecoration(labelText: "Land Line"),
      ),
      TextFormField(
        controller: landlineCodeController,
        decoration: const InputDecoration(labelText: "STD Code"),
      ),
    ],
  );

  // ===== Business Form =====
  Widget _buildBusinessForm() => Column(
    children: [
      TextFormField(
        controller: businessNameController,
        decoration: const InputDecoration(labelText: "Firm Name"),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      TextFormField(
        controller: personNameController,
        decoration: const InputDecoration(labelText: "Director / Prop / Partner Name"),
      ),
      DropdownButtonFormField<String>(
        value: personPrefix,
        items: const [
          DropdownMenuItem(value: "--", child: Text("--")),
          DropdownMenuItem(value: "Mr.", child: Text("Mr.")),
          DropdownMenuItem(value: "Ms.", child: Text("Ms.")),
        ],
        onChanged: (val) => setState(() => personPrefix = val),
        decoration: const InputDecoration(labelText: "Prefix"),
      ),
      TextFormField(
        controller: cityController,
        decoration: const InputDecoration(labelText: "City"),
        validator: validateCity,
      ),
      TextFormField(
        controller: pincodeController,
        decoration: const InputDecoration(labelText: "Pincode"),
        validator: validatePincode,
      ),
      TextFormField(
        controller: addressController,
        decoration: const InputDecoration(labelText: "Address"),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      TextFormField(
        controller: keywordsController,
        decoration: const InputDecoration(labelText: "Products"),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
      TextFormField(
        controller: emailController,
        decoration: const InputDecoration(labelText: "Email"),
      ),
      TextFormField(
        controller: landlineController,
        decoration: const InputDecoration(labelText: "Land Line"),
      ),
      TextFormField(
        controller: landlineCodeController,
        decoration: const InputDecoration(labelText: "STD Code"),
      ),
    ],
  );

  // ===== Signup Submit (same as before) =====
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final mobile = mobileController.text.trim();

    if (_mobileExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mobileMsg ?? "Mobile already registered")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final Map<String, dynamic> profile = {
        "user_type": signupType,
        "mobile_number": mobile,
        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "address": addressController.text.trim(),
        "email": emailController.text.trim(),
        "person_prefix": personPrefix,
        "landline": landlineController.text.trim(),
        "landline_code": landlineCodeController.text.trim(),
      };

      String displayName = "";

      if (signupType == "person") {
        profile.addAll({
          "person_name": personNameController.text.trim(),
          "business_name": businessNameController.text.trim(),
          "keywords": keywordsController.text.trim(),
        });
        displayName = personNameController.text.trim().isNotEmpty
            ? personNameController.text.trim()
            : businessNameController.text.trim();
      } else {
        profile.addAll({
          "business_name": businessNameController.text.trim(),
          "person_name": personNameController.text.trim(),
          "keywords": keywordsController.text.trim(),
        });
        displayName = businessNameController.text.trim().isNotEmpty
            ? businessNameController.text.trim()
            : personNameController.text.trim();
      }

      await SupabaseService.client.from("profiles").insert(profile);

      if (!mounted) return;

      // ✅ Success popup
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Registration Successful 🎉"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${displayName.isNotEmpty ? displayName : "User"} Registered successfully.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text("Username: $mobile"),
              const Text("Password: signpost"),
              const SizedBox(height: 16),
              const Text(
                "📌 Note: Take Screenshot and Save/Note.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
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
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final mobile = mobileController.text.trim();
    final mobileLooksValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);

    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ToggleButtons(
              isSelected: [signupType == "person", signupType == "business"],
              onPressed: (index) =>
                  setState(() => signupType = index == 0 ? "person" : "business"),
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [Icon(Icons.person), SizedBox(width: 8), Text("Person")]),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [Icon(Icons.business), SizedBox(width: 8), Text("Business")]),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Mobile always first
                    TextFormField(
                      controller: mobileController,
                      decoration: InputDecoration(
                        labelText: "Mobile Number",
                        suffixIcon: _isCheckingMobile
                            ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                            : (mobileLooksValid && _mobileMsg != null)
                            ? (_mobileExists
                            ? const Icon(Icons.error, color: Colors.red)
                            : const Icon(Icons.check_circle, color: Colors.green))
                            : null,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: validateMobile,
                      onChanged: _onMobileChanged,
                    ),
                    if (_mobileMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _mobileMsg!,
                            style: TextStyle(
                              color: _mobileExists ? Colors.red : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (signupType == "person") _buildPersonForm(),
                    if (signupType == "business") _buildBusinessForm(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: _signup,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.check_circle),
              label: Text("Sign Up as ${signupType.capitalize()}"),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}
