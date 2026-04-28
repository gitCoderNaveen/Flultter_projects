import 'dart:ui';
import 'package:flutter/material.dart';
import '../controller/combo_offer_controller.dart';
import '../model/combo_offer_model.dart';

class ComboOfferPage extends StatelessWidget {
  ComboOfferPage({super.key});

  final ComboOfferController controller = ComboOfferController();

  @override
  Widget build(BuildContext context) {
    // 🔥 IMAGE-LA IRUKKURA EXACT DETAILS MATTUM INGA POTTURUKEN
    final List<ComboOfferModel> displayOffers = [
      ComboOfferModel(
        title: "PLATINUM PLAN - Rs 67,500 pa",
        emoji: "👑",
        accentColor: Colors.purple,
        features: [
          "Banner ad in Home Page ( App )",
          "Full page Ad in Directory Book ( Print )",
          "Full Page and in Digital edition",
        ],
      ),
      ComboOfferModel(
        title: "DIAMOND PLAN - Rs 48,000 pa",
        emoji: "💎",
        accentColor: const Color(0xFF00838F),
        features: [
          "Banner ad in Home Page ( App )",
          "Half page Ad in Directory Book ( Print )",
          "Half Page ad in Digital edition",
        ],
      ),
      ComboOfferModel(
        title: "GOLD PLAN - Rs 27,500 pa",
        emoji: "🥇",
        accentColor: const Color(0xFFB8860B),
        features: [
          "Popular Firms (Logo) ad in Home Page ( App )",
          "1/4 page Ad in Directory Book ( Print )",
          "1/4 Page ad in Digital edition",
        ],
      ),
      ComboOfferModel(
        title: "SILVER PLAN - Rs 13,500 pa",
        emoji: "🥈",
        accentColor: const Color(0xFF546E7A),
        features: [
          "One Premium Listing for one keyword ( App )",
          "Colour panel Ad in Directory Book ( Print )",
          "Colour panel Ad in Digital edition",
        ],
      ),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: _buildBlob(250, Colors.blue.withOpacity(0.2)),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: _buildBlob(200, Colors.red.withOpacity(0.1)),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 30,
                ),
                child: Column(
                  children: [
                    _buildFormalHeader(),
                    const SizedBox(height: 25),

                    // Displaying updated details
                    ...displayOffers.map(
                      (offer) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildGlassCard(offer),
                      ),
                    ),

                    // CUSTOM COMBO SECTION (As per Image)
                    const SizedBox(height: 10),
                    _buildCustomComboCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomComboCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: const [
          Text(
            "CUSTOM COMBO -",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Select your Options and get your Special Offers.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormalHeader() {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'images/imglogo.png',
            height: 40,
            width: 160,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.business, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        const Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
            children: [
              TextSpan(
                text: 'CEL',
                style: TextStyle(color: Color(0xFFE31E24)),
              ),
              TextSpan(
                text: 'FON',
                style: TextStyle(color: Color(0xFF0072BC)),
              ),
              TextSpan(
                text: ' COMBINED TARIFF',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Celfon5G+ Directories are published in 3 formats. Printed Directory (23 Editions) is published from 1981. Digital (eBook) Edition is a replica of Print Edition and available from Play Books from 2015. The recent Online Edition CELFON BOOK is a Mobile App, available in Android platform from 2024.",
          textAlign: TextAlign.justify,
          style: TextStyle(color: Colors.black, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 10),
        const Text(
          "Here is a Money Save Offer, when you release your advertisements in all three formats, and be visible to prospects, when they search your products.",
          textAlign: TextAlign.justify,
          style: TextStyle(
            color: Color(0xFFE31E24),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard(ComboOfferModel offer) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.2,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: offer.accentColor.withOpacity(0.85),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        offer.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      child: Column(
                        children: offer.features
                            .map(
                              (feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: offer.accentColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 15,
          child: Text(offer.emoji, style: const TextStyle(fontSize: 22)),
        ),
      ],
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
