import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessCategoryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isBusiness = false;
  bool _isMobile = true;

  bool _isMobileValid = false;
  bool _isPasswordValid = false;

  bool _loading = false;
  bool _networkError = false;
  String? _error;

  bool _validateIndianMobile(String value) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(value);
  }

  Future<void> _signup() async {
    if (_phoneController.text.isEmpty || _passwordController.text.length < 8) {
      setState(() => _error = 'Phone and password are required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _networkError = false;
    });

    try {
      /// 🔑 Prepare phone number (NO validation, just prefix +)
      String phone = _phoneController.text.trim();
      if (!phone.startsWith('+')) {
        phone = '+$phone';
      }

      /// ✅ PHONE + PASSWORD SIGNUP
      final authRes = await Supabase.instance.client.auth.signUp(
        phone: phone,
        password: _passwordController.text.trim(),
      );

      final user = authRes.user;
      if (user == null) {
        throw 'User not created';
      }

      /// 🗄️ Save profile data
      await Supabase.instance.client.from('s_profiles').insert({
        'id': user.id,
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(), // raw phone (no +)
        'city': _cityController.text.trim(),
        'user_type': _isBusiness ? 'business' : 'individual',
        'business_name': _isBusiness
            ? _businessNameController.text.trim()
            : null,
        'business_category': _isBusiness
            ? _businessCategoryController.text.trim()
            : null,
      });

      if (!mounted) return;
      context.go('/home');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Signup failed');
    } finally {
      setState(() => _loading = false);
    }
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
                    /// USER TYPE
                    ToggleButtons(
                      isSelected: [_isBusiness == false, _isBusiness == true],
                      onPressed: (index) {
                        setState(() => _isBusiness = index == 1);
                      },
                      borderRadius: BorderRadius.circular(12),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Person'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Business'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _InputField(
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                    ),

                    const SizedBox(height: 16),

                    ToggleButtons(
                      isSelected: [_isMobile, !_isMobile],
                      onPressed: (index) {
                        setState(() {
                          _isMobile = index == 0;
                          _isMobileValid = !_isMobile;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Mobile'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Landline'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: _isMobile ? 10 : null,
                      onChanged: (v) {
                        if (_isMobile) {
                          setState(() {
                            _isMobileValid = _validateIndianMobile(v);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: _isMobile
                            ? 'Mobile Number'
                            : 'Landline Number',
                        counterText: '',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        suffixIcon: _isMobile && _isMobileValid
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _InputField(
                      hint: 'City',
                      icon: Icons.location_city_outlined,
                      controller: _cityController,
                    ),

                    const SizedBox(height: 16),

                    if (_isBusiness) ...[
                      _InputField(
                        hint: 'Business Name',
                        icon: Icons.store_outlined,
                        controller: _businessNameController,
                      ),
                      const SizedBox(height: 16),
                      _InputField(
                        hint: 'Business Category',
                        icon: Icons.category_outlined,
                        controller: _businessCategoryController,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // _InputField(
                    //   hint: 'Email',
                    //   icon: Icons.email_outlined,
                    //   controller: _emailController,
                    // ),
                    const SizedBox(height: 16),

                    _InputField(
                      hint: 'Set Password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: true,
                      onChanged: (v) {
                        setState(() => _isPasswordValid = v.length >= 8);
                      },
                    ),

                    if (!_isPasswordValid &&
                        _passwordController.text.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Password must be at least 8 characters',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
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

                    /// SIGN UP BUTTON
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
                      onPressed: () => context.go('/login'),
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
