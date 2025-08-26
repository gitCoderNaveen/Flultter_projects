import 'package:flutter/material.dart';
import '../supabase/supabase.dart';
import 'homepage_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './signup.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final mobileController  = TextEditingController();
  final passwordController = TextEditingController(text: "signpost");
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final mobile = mobileController.text.trim();
    final emailAlias = "$mobile@celfon5g.com";
    const password = "signpost";

    try {
      // 1️⃣ Check if mobile exists in profiles
      final profile = await SupabaseService.client
          .from("profiles")
          .select("id, business_name, person_name")
          .eq("mobile_number", mobile)
          .maybeSingle();

      if (profile == null) {
        // ❌ Not registered → Show alert and redirect to Signup
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Mobile not registered"),
              content: const Text(
                "Your mobile number is not registered. Please sign up first.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 2️⃣ Try signing in
      AuthResponse response;
      try {
        response = await SupabaseService.client.auth.signInWithPassword(
          email: emailAlias,
          password: password,
        );
      } catch (e) {
        // 3️⃣ If fails → auto create user, then retry login
        debugPrint("⚠️ Sign in failed, trying sign up: $e");
        response = await SupabaseService.client.auth.signUp(
          email: emailAlias,
          password: password,
        );

        response = await SupabaseService.client.auth.signInWithPassword(
          email: emailAlias,
          password: password,
        );
      }

      // 4️⃣ If success → store username and navigate home
      if (response.user != null) {
        final username = profile["business_name"] ?? profile["person_name"] ?? "";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", username);

        debugPrint("✅ Logged in as $username");

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePageShell()),
                (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Login failed, please try again")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }



  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Enter valid Indian mobile number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextFormField(
                      controller: mobileController,
                      decoration: const InputDecoration(labelText: "Mobile Number"),
                      keyboardType: TextInputType.phone,
                      validator: validateMobile,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Sign In",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
