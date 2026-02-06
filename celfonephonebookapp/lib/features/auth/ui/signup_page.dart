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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _isMobileValid = false;
  bool _isPasswordValid = false;

  String _userType = 'individual'; // default

  bool _loading = false;
  String? _error;
  bool _networkError = false;

  bool _validateUsername(String value) {
    return RegExp(r'^[a-zA-Z ]+$').hasMatch(value);
  }

  bool _validateIndianMobile(String value) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(value);
  }

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
      _networkError = false;
    });

    try {
      final authRes = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        emailRedirectTo: 'io.supabase.flutter://login-callback',
      );

      final user = authRes.user;
      if (user == null) throw 'User not created';

      /// 🗄️ Insert profile data
      await Supabase.instance.client.from('s_profiles').insert({
        'id': user.id,
        'full_name': _usernameController.text.trim(),
        'phone': _mobileController.text.trim(),
        'user_type': _userType,
        'password': _passwordController.text.trim(),
      });

      if (!mounted) return;
      context.go('/verify-email');
    } on SocketException {
      setState(() => _networkError = true);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              /// 🔵 Top Curved Header
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
                    /// 📝 Bottom-Left Text
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

                    /// 🖼 Bottom-Right Image
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        'images/signup.png',
                        height: 300, // make it big
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// ✍️ Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ToggleButtons(
                      isSelected: [
                        _userType == 'individual',
                        _userType == 'business',
                      ],
                      onPressed: (index) {
                        setState(() {
                          _userType = index == 0 ? 'individual' : 'business';
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Individual'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Business'),
                        ),
                      ],
                    ),

                    _InputField(
                      hint: 'Username',
                      controller: _usernameController,
                      onChanged: (v) {
                        if (!_validateUsername(v)) {
                          setState(
                            () => _error = 'Username cannot contain numbers',
                          );
                        } else {
                          setState(() => _error = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _mobileController,
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
                        suffixIcon: _isMobileValid
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

                    _InputField(hint: 'Email', controller: _emailController),
                    const SizedBox(height: 16),

                    _InputField(
                      hint: 'Password',
                      controller: _passwordController,
                      obscure: true,
                      onChanged: (v) {
                        setState(() {
                          _isPasswordValid = v.length >= 8;
                        });
                      },
                    ),
                    if (!_isPasswordValid)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Password must be at least 8 characters',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 20),

                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),

                    const SizedBox(height: 30),

                    /// ➡️ Sign Up Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap:
                            (_loading ||
                                !_isMobileValid ||
                                !_isPasswordValid ||
                                !_validateUsername(_usernameController.text))
                            ? null
                            : _signup,

                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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

                    /// 🔁 Login Redirect
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

class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.hint,
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
