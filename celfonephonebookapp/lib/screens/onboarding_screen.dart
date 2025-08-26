// onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './homepage_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  bool _agree = false;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true); // mark onboarding done

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePageShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(Icons.explore,
          "Explore more industrials\nand connect everywhere"),
      _buildPage(Icons.people, "Connect with your nearby people"),
      _buildPageWithAgree(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) =>
                  setState(() => _currentIndex = index),
              children: pages,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (_currentIndex < pages.length - 1)
                TextButton(
                  onPressed: () {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text("Next"),
                ),
              if (_currentIndex == pages.length - 1)
                ElevatedButton(
                  onPressed: _agree ? _completeOnboarding : null,
                  child: const Text("Get Started"),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPage(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildPageWithAgree() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.layers, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text("Discover more options",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _agree,
                onChanged: (val) => setState(() => _agree = val ?? false),
              ),
              const Text("I agree to Terms & Conditions"),
            ],
          ),
        ],
      ),
    );
  }
}
