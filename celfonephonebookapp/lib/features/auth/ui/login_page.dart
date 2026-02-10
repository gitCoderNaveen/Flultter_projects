import 'package:celfonephonebookapp/core/services/auth_service.dart';
import 'package:celfonephonebookapp/features/auth/ui/signup_page.dart';
import 'package:celfonephonebookapp/features/home/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    if (_identifierController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final identifier = _identifierController.text.trim();

      if (identifier.contains('@')) {
        /// ✅ Email login
        await Supabase.instance.client.auth.signInWithPassword(
          email: identifier,
          password: _passwordController.text.trim(),
        );
      } else {
        /// ✅ Phone login (must include country code)
        await Supabase.instance.client.auth.signInWithPassword(
          phone: identifier.startsWith('+') ? identifier : '+$identifier',
          password: _passwordController.text.trim(),
        );
      }

      if (!mounted) return;
      context.go('/home');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const Positioned(
                      bottom: 32,
                      left: 24,
                      child: Text(
                        'Welcome\nBack',
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
                        height: 300,
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
                    _InputField(
                      hint: 'Mobile Number',
                      icon: Icons.phone_outlined,
                      controller: _identifierController,
                    ),
                    const SizedBox(height: 16),

                    _InputField(
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: true,
                    ),

                    const SizedBox(height: 8),

                    /// 🔐 Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: navigate to forgot password
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 30),

                    /// ➡️ Login Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _loading ? null : _handleLogin,
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
                                'Login',
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

                    /// 🔁 Signup Redirect
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      child: const Text(
                        'Create new account',
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

/// 🔹 Reusable Input Field
class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final IconData icon;

  const _InputField({
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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
