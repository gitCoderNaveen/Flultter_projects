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

  bool _loading = false;
  String? _error;
  bool _networkError = false;

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
      _networkError = false;
    });

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        emailRedirectTo: 'io.supabase.flutter://login-callback',
      );

      if (!mounted) return;
      context.go('/verify-email');
    }
    /// 🌐 Network / Internet Error
    on SocketException {
      setState(() => _networkError = true);
    }
    /// 🔐 Supabase Auth Error
    on AuthException catch (e) {
      setState(() => _error = e.message);
    }
    /// ❌ Unknown Error
    catch (_) {
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _networkError
              ? _NetworkErrorView(onRetry: _signup)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    /// App Icon
                    Center(
                      child: Image.asset('images/ic_launcher.png', width: 90),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'Sign up to continue',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 32),

                    /// Email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),

                    const SizedBox(height: 24),

                    /// Signup Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signup,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Sign Up'),
                      ),
                    ),

                    const Spacer(),

                    /// Login Redirect
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Already have an account? Login'),
                      ),
                    ),
                  ],
                ),
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
