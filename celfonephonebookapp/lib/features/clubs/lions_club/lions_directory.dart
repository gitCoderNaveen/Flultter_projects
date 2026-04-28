import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:celfonephonebookapp/features/clubs/services/image_service.dart';
import 'package:celfonephonebookapp/features/promotions/features/categorywisepromotions/service/categorywise_pro_services.dart';
import 'package:celfonephonebookapp/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:celfonephonebookapp/features/clubs/lions_club/image_card.dart';
import 'package:go_router/go_router.dart';

class LionsDirectory extends StatefulWidget {
  const LionsDirectory({super.key});

  @override
  State<LionsDirectory> createState() => _LionsDirectoryState();
}

class _LionsDirectoryState extends State<LionsDirectory> {
  final SupbaseService service = SupbaseService();
  List<Map<String, dynamic>> presidents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPresidents();
  }

  Future<void> fetchPresidents() async {
    final data = await ImageService().getPresidents();
    setState(() {
      presidents = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 🔷 Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    color: const Color(0xFF2E86A1),
                    child: const Column(
                      children: [
                        Text(
                          "Celfon Book",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Connects for Growth",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🏛 Title
                  const Text(
                    "Lions Clubs International",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "District 3242C",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  // 🖼 Center Card
                  if (presidents.isNotEmpty)
                    Builder(
                      builder: (context) {
                        final centerSize =
                            MediaQuery.of(context).size.width * 0.45;
                        return ImageCard(
                          size: centerSize,
                          imageUrl: presidents[0]['image_url'] ?? '',
                          name: presidents[0]['name'] ?? '',
                          position: presidents[0]['position'] ?? '',
                        );
                      },
                    ),

                  const SizedBox(height: 30),

                  // 🖼 Bottom Row
                  if (presidents.length > 2) ...[
                    Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final cardSize = screenWidth * 0.35;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ImageCard(
                              size: cardSize,
                              imageUrl: presidents[1]['image_url'] ?? '',
                              name: presidents[1]['name'] ?? '',
                              position: presidents[1]['position'] ?? '',
                            ),
                            ImageCard(
                              size: cardSize,
                              imageUrl: presidents[2]['image_url'] ?? '',
                              name: presidents[2]['name'] ?? '',
                              position: presidents[2]['position'] ?? '',
                            ),
                          ],
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 50),

                  // 📘 Footer
                  const Text(
                    "Members Directory",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "2026-27",
                    style: TextStyle(
                      fontSize: 26,
                      color: Color(0xFF2E86A1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E86A1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => context.push("/menu_page"),
                        child: const Text(
                          "Next Page",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
