import 'package:flutter/material.dart';

class PrivacyOptOutPage extends StatelessWidget {
  const PrivacyOptOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ultra-Premium Dark & Light Palette
    const Color canvasColor = Color(0xFFF1F5F9);
    const Color surfaceColor = Colors.white;
    const Color textPrimary = Color(0xFF0F172A);
    const Color textSecondary = Color(0xFF475569);
    const Color accentBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: textPrimary,
              size: 16,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'PRIVACY POLICY',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2.0, // Luxury tracking
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Decorative Element
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: accentBlue.withOpacity(0.05),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                const Text(
                  'Privacy & \nOpt-Out Terms',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: accentBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),

                // Main Content Cards
                _buildEliteCard(
                  title: 'Core Commitment',
                  description:
                      'In creating the CELFON BOOK Mobile App, utmost care is taken to protect member privacy. We do not collect Aadhar, PAN, GST, or Date of Birth. Only commonly shared info like Name and Address is utilized.',
                  icon: Icons.verified_user_rounded,
                ),

                _buildEliteCard(
                  title: 'Data Compilation',
                  description:
                      'Our directory is a multi-brand service. Profiles are voluntarily provided by firms and the public. We also integrate data from associations and field surveys for accuracy.',
                  icon: Icons.dataset_linked_outlined,
                ),

                _buildEliteCard(
                  title: 'Provider Neutrality',
                  description:
                      'We do not represent any Mobile Service provider. User data is not sourced from providers directly or indirectly. Listing remains free for all owners in India.',
                  icon: Icons.language_rounded,
                ),

                // THE HIGHLIGHTED OPT-OUT INSTRUCTION
                _buildOptOutHighlight(accentBlue),

                _buildEliteCard(
                  title: 'Chargeable Services',
                  description:
                      'Business Listings are chargeable as per Tariff, determined by keywords and selected facilities.',
                  icon: Icons.account_balance_wallet_outlined,
                ),

                _buildEliteCard(
                  title: 'Verification Notice',
                  description:
                      'Data accuracy can vary over time. Publishers do not guarantee absolute correctness. Users are advised to contact firms directly for the latest info.',
                  icon: Icons.rule_rounded,
                ),

                _buildEliteCard(
                  title: 'Listing Order',
                  description:
                      'Order of information does not reflect quality or preference. Listings are strictly based on keywords and time of posting.',
                  icon: Icons.sort_by_alpha_rounded,
                ),

                const SizedBox(height: 60),

                // Footer
                Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Column(
                      children: [
                        const Text(
                          'CELFON BOOK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'CONNECTS FOR GROWTH',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEliteCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Extra round for modern feel
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 22),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF475569),
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptOutHighlight(Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Premium Dark Slate
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          const Text(
            'Any member listed in the database can Opt Out of the services by applying by email',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}