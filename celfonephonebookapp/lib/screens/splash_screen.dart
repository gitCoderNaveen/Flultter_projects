import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../supabase/supabase.dart';

import './onboarding_screen.dart';
import './homepage_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('showOnboarding') ?? true;

    if (showOnboarding) {
      // 🚀 First-time user → Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    // ✅ Already completed onboarding
    final session = SupabaseService.client.auth.currentSession;

    if (session != null) {
      // Logged in → HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePageShell()),
      );
    } else {
      // Not logged in yet → still take to homepage (you can change this to login screen if needed)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePageShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_android,
              size: 120,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              "Celfon5G+ Phonebook",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            LoadingAnimationWidget.threeArchedCircle(
              color: Colors.blueAccent,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
