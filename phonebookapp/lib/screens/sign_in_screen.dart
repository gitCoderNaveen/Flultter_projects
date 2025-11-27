import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _handleLogin(bool isSignup) async {
    setState(() => _loading = true);
    try {
      if (isSignup) {
        await _auth.signUpWithMobile(_mobileCtrl.text, _passCtrl.text);
      } else {
        await _auth.signInWithMobile(_mobileCtrl.text, _passCtrl.text);
      }
      final isAdmin = await _auth.isAdmin();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          isAdmin ? AdminDashboardScreen() : DashboardScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login / Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _mobileCtrl,
              decoration: InputDecoration(labelText: 'Mobile number'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_loading)
              CircularProgressIndicator()
            else
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _handleLogin(false),
                    child: Text('Login'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _handleLogin(true),
                    child: Text('Sign Up'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
