import 'dart:ui';
import 'package:flutter/material.dart';
import '../controller/combo_offer_controller.dart';
import '../model/combo_offer_model.dart';

class ComboOfferPage extends StatelessWidget {
  ComboOfferPage({super.key});

  final ComboOfferController controller = ComboOfferController();

  @override
  Widget build(BuildContext context) {
    List<ComboOfferModel> offers = controller.offers;

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
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 30,
                ),

                child: Column(
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 30),

                    ...offers.map(
                      (offer) => Column(
                        children: [
                          _buildGlassCard(offer),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

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

  Widget _buildHeader() {
    return Column(
      children: const [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
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

        SizedBox(height: 8),

        Text(
          "Annual Plans: App + Print + Digital",
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),

        Text(
          "Rates are per annum",
          style: TextStyle(
            color: Color(0xFFE31E24),
            fontSize: 12,
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                        offer.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
                                          fontSize: 15,
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

          child: Container(
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),

            child: Text(offer.emoji, style: const TextStyle(fontSize: 22)),
          ),
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
