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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(title: const _HeaderRow(collapsed: true)),

      body: FutureBuilder<PartnerModel?>(
        future: profileFuture,

        builder: (context, snapshot) {
          final profile = snapshot.data;

          final displayName = controller.getDisplayName(profile);
          final status = controller.getStatus(profile);

          return CustomScrollView(
            slivers: [
              // SliverAppBar(
              //   expandedHeight: 200,
              //   backgroundColor: darkSlate,
              //   pinned: true,

              //   flexibleSpace: FlexibleSpaceBar(
              //     background: Container(
              //       padding: const EdgeInsets.all(20),

              //       decoration: const BoxDecoration(
              //         gradient: LinearGradient(
              //           colors: [darkSlate, primaryDark],
              //         ),
              //       ),

              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.end,
              //         crossAxisAlignment: CrossAxisAlignment.start,

              //         children: [
              //           const CircleAvatar(
              //             radius: 28,
              //             backgroundColor: Colors.white24,
              //             child: Icon(Icons.person, color: Colors.white),
              //           ),

              //           const SizedBox(height: 10),

              //           Text(
              //             "Hello,",
              //             style: GoogleFonts.plusJakartaSans(
              //               color: Colors.white70,
              //             ),
              //           ),

              //           Text(
              //             displayName,
              //             style: GoogleFonts.plusJakartaSans(
              //               color: Colors.white,
              //               fontSize: 26,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),

              //           const SizedBox(height: 10),

              //           buildStatus(status),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      buildTile(
                        title: "Media Partner Form",
                        subtitle: "Submit entries",
                        icon: Icons.edit,
                        color: primaryIndigo,
                        onTap: () {
                          context.push('/media-partner');
                        },
                      ),

                      const SizedBox(height: 20),

                      /// 🔹 HOW TO USE (NEW)
                      GestureDetector(
                        onTap: () {
                          context.push('/media-partner-guide'); // 👈 route
                        },
                        child: const Text(
                          "How to Fill Media partner!*",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      buildTile(
                        title: "Revenue Tracker",
                        subtitle: "View earnings",
                        icon: Icons.wallet,
                        color: successEmerald,
                        onTap: () {
                          context.push('/earning_page');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
