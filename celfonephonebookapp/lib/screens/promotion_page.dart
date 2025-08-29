import 'package:celfonephonebookapp/screens/categorywise_promotion.dart';
import 'package:celfonephonebookapp/screens/media_partner_signup.dart';
import 'package:celfonephonebookapp/screens/promotion_card.dart';
import 'package:celfonephonebookapp/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './nearby_promotion.dart';
import './favorites.dart';

class PromotionPage extends StatefulWidget {
  const PromotionPage({super.key});

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  // Reactive login status
  final ValueNotifier<bool> _signedIn = ValueNotifier(false);

  final List<Map<String, dynamic>> promotions = const [
    {
      "title": "Nearby Promotion",
      "icon": Icons.location_on,
      "gradient": LinearGradient(
        colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "page": NearbyPromotionPage(),
    },
    {
      "title": "Categorywise Promotion",
      "icon": Icons.category,
      "gradient": LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "page": CategoryPromotionPage(), // not implemented
    },
    {
      "title": "Favorites",
      "icon": Icons.favorite,
      "gradient": LinearGradient(
        colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "page": FavoritesPage(),
    },
    {
      "title": "Media Partner",
      "icon": Icons.camera_alt,
      "gradient": LinearGradient(
        colors: [Color(0xFF4568DC), Color(0xFFB06AB3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "page": MediaPartnerSignupPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSignedInStatus();
  }

  Future<void> _loadSignedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    _signedIn.value = username != null && username.isNotEmpty;
  }

  void _handlePromotionTap(Map<String, dynamic> promo) {
    if (!_signedIn.value) {
      // Not signed in → navigate to Signin
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SigninPage()),
      ).then((_) {
        // Refresh login status when coming back from Signin
        _loadSignedInStatus();
      });
    } else {
      // Signed in → navigate to promo page if available
      if (promo["page"] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => promo["page"]),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Page not available yet")),
        );
      }
    }
  }

  @override
  void dispose() {
    _signedIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Promotions"),
        backgroundColor: const Color(0xFF306CBC),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _signedIn,
          builder: (context, signedIn, _) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promo = promotions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PromotionCard(
                    title: promo["title"],
                    icon: promo["icon"],
                    gradient: promo["gradient"],
                    onPressed: () => _handlePromotionTap(promo),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
