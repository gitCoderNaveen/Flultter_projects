import 'dart:io';
import 'dart:math';

import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:celfonephonebookapp/features/auth/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();

  bool _isMobileValid = false;

  bool _loading = false;
  bool _networkError = false;
  String? _error;

  bool _validateIndianMobile(String value) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(value);
  }
  bool loading = false;

  String generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }


  Future<void> sendOtp(String phone) async {
    if (phone.isEmpty) return;

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final otp = generateOtp();

    setState(() => loading = true);

    try {
      // 🔥 CALL YOUR SMS API HERE
      final response = await http.post(
        Uri.parse("http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$cleanPhone&text=Your%20OTP%20for%20Signpost%20Celfon5G%20is:$otp.%20Use%20this%20OTP%20to%20verify%20your%20account.%20Do%20not%20share%20OTP%20with%20anyone.&priority=ndnd&stype=normal"),
        body: {"phone": cleanPhone, "otp": otp},
      ); 

      if (response.statusCode == 200) {
        // 🔥 Delete old OTPs (important)
        await Supabase.instance.client
            .from('otp_verifications')
            .delete()
            .eq('phone', cleanPhone);
        // 🔥 Insert new OTP
        await Supabase.instance.client.from('otp_verifications').insert({
          'phone': cleanPhone,
          'otp': otp,
        });

        // ✅ Navigate
        context.go('/otp_verification', extra: cleanPhone);
      } else {
        throw Exception("Failed to send OTP");
      }
    } catch (e) {
      debugPrint("Error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
    }

    setState(() => loading = false);
  }

  Future<void> _signup() async {
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _error = 'Phone number is required');
      return;
    }

    if (!_validateIndianMobile(_phoneController.text.trim())) {
      setState(() => _error = 'Enter valid mobile number');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Full name is required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      String phone = _phoneController.text.trim();
      String name = _nameController.text.trim();
  

      /// 🔐 DEFAULT PASSWORD
      const String defaultPassword = 'celfonbook';

      final AuthResponse authRes = await SupabaseService.client.auth.signUp(
        phone: phone,
        password: defaultPassword,
      );

      final user = authRes.user;
      if (user == null) {
        throw Exception('User not created');
      }

      /// Save profile
      await SupabaseService.client.from('s_profiles').insert({
        'id': user.id,
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'promo_code': _promoController.text.trim(),
      });

      if (!mounted) return;
     await sendOtp(phone); 
      // _showSuccessPopup(phone, name);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Signup failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSuccessPopup(String phone, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ TITLE
                const Text(
                  "Registration Successful",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "You Are Successfully Registered.",
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 16),

                /// ✅ DETAILS
                const Text(
                  "App : CELFON BOOK",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Name : $name",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "UN : $phone",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "PW: celfonbook",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                /// 📸 NOTE
                const Center(
                  child: Text(
                    "Please take a Screen Shot & save",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                /// ℹ️ INFO
                const Text(
                  "If you are a Businessman, then fill your Business Details in the Menu > My Profile and get Trade Enquiries FREE",
                  style: TextStyle(fontSize: 15),
                ),

                const SizedBox(height: 20),

                /// 🔘 ACTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// COPY BUTTON
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                "App: CELFON BOOK\nName: $name\nUN: $phone\nPW: celfonbook",
                          ),
                        );

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text("Copied")));
                      },
                    ),

                    /// OK BUTTON
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/home');
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_networkError) {
      return Scaffold(body: _NetworkErrorView(onRetry: _signup));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// 🔵 Header
              Container(
                height: 260,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 23, 128, 198),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      bottom: 32,
                      left: 24,
                      child: Text(
                        'Create\nAccount',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        'images/signup.png',
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 📱 Mobile Number
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      onChanged: (v) {
                        setState(() {
                          _isMobileValid = _validateIndianMobile(v);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Mobile Number',
                        counterText: '',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        suffixIcon: _isMobileValid
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 👤 Full Name
                    _InputField(
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                    ),

                    const SizedBox(height: 20),

                    /// 🎁 Promo Code
                    _InputField(
                      hint: 'Promo Code (Optional)',
                      icon: Icons.card_giftcard_outlined,
                      controller: _promoController,
                    ),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 30),

                    /// 🚀 SIGN UP BUTTON (Full Width Now)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _loading ? null : _signup,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔹 Reusable Input
class _InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _NetworkErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _NetworkErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/ic_launcher.png', width: 100),
          const SizedBox(height: 20),
          const Text(
            'Check your network connection',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
