import 'package:celfonephonebookapp/screens/homepage_shell.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for each onboarding screen
class OnboardingContent {
  final List<InlineSpan> subtitleSpans;
  OnboardingContent({required this.subtitleSpans});
}

final List<OnboardingContent> contentsList = [
  // 1️⃣ First Slide
  OnboardingContent(
    subtitleSpans: [
      const TextSpan(
        text: 'Multi Brand\nMobile Directory.\n',
        style: TextStyle(fontSize: 22, color: Colors.black87, height: 1.5),
      ),
      const TextSpan(
        text: 'Connects for Growth',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    ],
  ),
  // 2️⃣ Second Slide
  OnboardingContent(
    subtitleSpans: [
      const TextSpan(
        text: 'For Targetted\n',
        style: TextStyle(fontSize: 22, color: Colors.black87, height: 1.5),
      ),
      const TextSpan(
        text: 'Digital Marketing\n',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
      const TextSpan(
        text: '* Nearby Promotion\n* Citywide Promotion\n* Favorite Promotion',
        style: TextStyle(fontSize: 22, color: Colors.black87, height: 1.5),
      ),
    ],
  ),
  // 3️⃣ Third Slide
  OnboardingContent(
    subtitleSpans: [
      const TextSpan(
        text:
        'Your Identity in City\n* Priority Listing\n* Bold Listing\nBe Visible, when searched',
        style: TextStyle(fontSize: 22, color: Colors.black87, height: 1.5),
      ),
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _termsAccepted = false; // ✅ track checkbox

  void _onPageChanged(int index) => setState(() => _currentPage = index);

  Future<void> _navigateToNext() async {
    final prefs = await SharedPreferences.getInstance();
    // save flag so onboarding won’t show again
    await prefs.setBool('showOnboarding', false);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePageShell()),
    );
  }

  /// Telco logo widget (no text, slightly bigger)
  Widget _buildTelcoLogo(String asset) {
    return Image.asset(asset, height: 60, width: 60, fit: BoxFit.contain);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == contentsList.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: isLastPage
                  ? const SizedBox(height: 48)
                  : TextButton(
                onPressed: _navigateToNext,
                child: const Text('SKIP'),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: contentsList.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (_, i) {
                  final item = contentsList[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/companylogo.png',
                            height: 100),
                        const SizedBox(height: 20),

                        // Extra heading only on 3rd slide
                        if (i == 2)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text(
                              'Celfon5G+ PHONE BOOK',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                        // RichText subtitle
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: item.subtitleSpans),
                        ),

                        // Telco logos only on 1st slide
                        if (i == 0) ...[
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTelcoLogo('assets/images/BSNL.png'),
                              _buildTelcoLogo('assets/images/airtel.png'),
                              _buildTelcoLogo('assets/images/jio.png'),
                              _buildTelcoLogo('assets/images/vi.png'),
                            ],
                          ),
                        ],

                        // ✅ Checkbox only on 3rd slide
                        if (i == 2) ...[
                          const SizedBox(height: 30),
                          CheckboxListTile(
                            value: _termsAccepted,
                            onChanged: (val) {
                              setState(() => _termsAccepted = val ?? false);
                            },
                            title: const Text(
                              'Accept terms and conditions',
                              style: TextStyle(fontSize: 18),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots + Next/Get Started
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(
                      contentsList.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 10,
                        width: _currentPage == index ? 25 : 10,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  // Next / Get Started
                  ElevatedButton(
                    onPressed: isLastPage
                        ? (_termsAccepted ? _navigateToNext : null)
                        : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text(
                      isLastPage ? 'Get Started' : 'Next',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
