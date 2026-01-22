import 'package:flutter/material.dart';
import 'package:phonebookupdate/features/home/ui/home_page.dart';
import '../../../core/utils/app_storage.dart';
import '../../onboarding/ui/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final isFirstLaunch = await AppStorage.isFirstLaunch();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isFirstLaunch ? const OnboardingScreen() : const HomePage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(_controller),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/ic_launcher.png', width: 110),
              const SizedBox(height: 16),
              const Text('Celfon5G+', style: TextStyle(fontSize: 14)),
              const Text(
                'Phone Book',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
