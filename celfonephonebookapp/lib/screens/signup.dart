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
  String signupType = "business"; // default = business
  bool isLoading = false;

  // Controllers
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  // Person
  final personNameController = TextEditingController();
  String? personPrefix = "Mr."; // dropdown default
  final professionController = TextEditingController();

  // Business
  final businessNameController = TextEditingController();
  String? businessPrefix = "M/s."; // dropdown default
  final keywordsController = TextEditingController();
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
    personNameController.dispose();
    professionController.dispose();
    businessNameController.dispose();
    keywordsController.dispose();
    descriptionController.dispose();
    landlineController.dispose();
    landlineCodeController.dispose();
    super.dispose();
  }

  // ========== LIVE MOBILE CHECK ==========
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

  // ========== SIGNUP ==========
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final mobile = mobileController.text.trim();
    final isPatternOk = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);
    if (!isPatternOk) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid Indian mobile number")));
      return;
    }

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
        "email": emailController.text.trim(),
        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
      };

      if (signupType == "person") {
        profile.addAll({
          "person_name": personNameController.text.trim(),
          "person_prefix": personPrefix,
          "profession": professionController.text.trim(),
        });
      } else {
        profile.addAll({
          "business_name": businessNameController.text.trim(),
          "business_prefix": businessPrefix,
          "keywords": keywordsController.text
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          "description": descriptionController.text.trim(),
          "landline": landlineController.text.trim(),
          "landline_code": landlineCodeController.text.trim(),
        });
      }

      await SupabaseService.client.from("profiles").insert(profile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful ✅")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePageShell()),
            (route) => false,
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

  // ========== Validators ==========
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Enter valid Indian mobile number";
    }
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Enter pincode";
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return "Enter valid 6-digit pincode";
    return null;
  }

  // ========== Forms ==========
  Widget _buildPersonForm() => Column(
    children: [
      TextFormField(
          controller: personNameController,
          decoration: const InputDecoration(labelText: "Person Name")),
      DropdownButtonFormField<String>(
        value: personPrefix,
        items: const [
          DropdownMenuItem(value: "Mr.", child: Text("Mr.")),
          DropdownMenuItem(value: "Ms.", child: Text("Ms.")),
          DropdownMenuItem(value: "Lions", child: Text("Lions")),
          DropdownMenuItem(value: "Others", child: Text("Others")),
        ],
        onChanged: (val) => setState(() => personPrefix = val),
        decoration: const InputDecoration(labelText: "Prefix"),
      ),
      TextFormField(
          controller: professionController,
          decoration: const InputDecoration(labelText: "Profession")),
    ],
  );

  Widget _buildBusinessForm() => Column(
    children: [
      TextFormField(
          controller: businessNameController,
          decoration: const InputDecoration(labelText: "Business Name")),
      DropdownButtonFormField<String>(
        value: businessPrefix,
        items: const [
          DropdownMenuItem(value: "M/s.", child: Text("M/s.")),
        ],
        onChanged: (val) => setState(() => businessPrefix = val),
        decoration: const InputDecoration(labelText: "Prefix"),
      ),
      TextFormField(
          controller: keywordsController,
          decoration:
          const InputDecoration(labelText: "Products (comma separated)")),
      TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: "Description")),
      TextFormField(
          controller: landlineController,
          decoration: const InputDecoration(labelText: "Landline")),
      TextFormField(
          controller: landlineCodeController,
          decoration: const InputDecoration(labelText: "Landline Code")),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final mobile = mobileController.text.trim();
    final mobileLooksValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);

    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Column(
        children: [
          // Toggle buttons
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
                  child: Row(
                      children: [Icon(Icons.person), SizedBox(width: 8), Text("Person")]),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Icon(Icons.business),
                    SizedBox(width: 8),
                    Text("Business")
                  ]),
                ),
              ],
            ),
          ),

          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                          begin: const Offset(0.2, 0), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(signupType),
                    children: [
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
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)),
                          )
                              : (mobileLooksValid && _mobileMsg != null)
                              ? (_mobileExists
                              ? const Icon(Icons.error, color: Colors.red)
                              : const Icon(Icons.check_circle,
                              color: Colors.green))
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
                                  color:
                                  _mobileExists ? Colors.red : Colors.green,
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: "Email")),
                      TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(labelText: "City")),
                      TextFormField(
                        controller: pincodeController,
                        decoration:
                        const InputDecoration(labelText: "Pincode"),
                        validator: validatePincode,
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
          ),

          // Fixed Sign Up button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: _signup,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
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
  String capitalize() =>
      isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}
