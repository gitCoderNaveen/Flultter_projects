import 'package:celfonephonebookapp/screens/media_partner_signup.dart';
import 'package:celfonephonebookapp/screens/promotion_card.dart';
import 'package:celfonephonebookapp/screens/signin.dart'; // <-- add signin page
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './nearby_promotion.dart';
import './favorites.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key});

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
      "page": null, // not implemented
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Promotions"),
        backgroundColor: const Color(0xFF306CBC),
      ),
      body: SafeArea(
        child: ListView.builder(
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
                onPressed: () {
                  final user = Supabase.instance.client.auth.currentUser;

                  if (user == null) {
                    // If not logged in → go to Signin
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SigninPage()),
                    );
                  } else {
                    // If logged in → go to promo page (if available)
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
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
