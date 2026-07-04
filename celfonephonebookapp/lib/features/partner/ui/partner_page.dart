import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/partner_controller.dart';
import '../model/partner_model.dart';

class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  final PartnerController controller = PartnerController();

  Future<PartnerModel?>? profileFuture;

  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color successEmerald = Color(0xFF10B981);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color bgGrey = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    profileFuture = controller.getPartnerProfile();
  }

  void protectedNavigation(Widget page) {
    if (controller.isLoggedIn()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please Login First"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      body: FutureBuilder<PartnerModel?>(
        future: profileFuture,

        builder: (context, snapshot) {
          final profile = snapshot.data;

          final displayName = controller.getDisplayName(profile);

          final status = controller.getStatus(profile);

          return Stack(
            children: [
              ///========================
              /// TOP HEADER
              ///========================
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff0B67F6), Color(0xff16C6F8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              /// Decorative Circle
              Positioned(
                right: -40,
                top: 25,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.05),
                  ),
                ),
              ),

              Positioned(
                right: 40,
                top: 60,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.05),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    ///=====================
                    /// LOGO
                    ///=====================
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.08),
                                  blurRadius: 15,
                                ),
                              ],
                            ),

                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Cel",
                                    style: TextStyle(color: Colors.red),
                                  ),

                                  TextSpan(
                                    text: "fon",
                                    style: TextStyle(color: Colors.blue),
                                  ),

                                  TextSpan(
                                    text: " Book",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  indent: 40,
                                  endIndent: 20,
                                  color: Colors.white30,
                                ),
                              ),

                              const Text(
                                "Connects For Growth",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              Expanded(
                                child: Divider(
                                  indent: 20,
                                  endIndent: 40,
                                  color: Colors.white30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Expanded(
                      child: Container(
                        width: double.infinity,

                        decoration: const BoxDecoration(
                          color: Color(0xffF8FAFD),

                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                        ),

                        child: ListView(
                          padding: const EdgeInsets.all(20),

                          children: [
                            buildPartnerCard(
                              title: "Media Partner Form",
                              subtitle: "Submit entries",
                              icon: Icons.edit,
                              iconColor: Colors.deepPurple,
                              onTap: () {
                                context.push('/media-partner');
                              },
                            ),

                            buildPartnerCard(
                              title: "How to Fill Media Partner",
                              subtitle:
                                  "Step-by-step guide to complete your media partner form",
                              icon: Icons.menu_book_rounded,
                              iconColor: Colors.orange,
                              onTap: () {
                                context.push('/media-partner-guide');
                              },
                            ),

                            buildPartnerCard(
                              title: "Revenue Tracker",
                              subtitle: "View earnings",
                              icon: Icons.account_balance_wallet,
                              iconColor: Colors.green,
                              badge: "₹12,450",
                              onTap: () {
                                context.push('/earning_page');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildPartnerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                /// ICON
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff1F2937),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.poppins(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded, size: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatus(String text) {
    final isLoggedIn = controller.isLoggedIn();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: isLoggedIn ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),

        title: Text(title),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: onTap,
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final bool collapsed;
  const _HeaderRow({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final color = collapsed ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: "Cel",
                            style: TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text: "fon",
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(
                            text: " Book",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    "Connects For Growth",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
