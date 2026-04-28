import 'package:celfonephonebookapp/features/admin/ui/profile_detail.dart';
import 'package:celfonephonebookapp/features/clubs/Widgets/card_widget.dart';
import 'package:celfonephonebookapp/features/clubs/lions_club/profile_details.dart';
import 'package:celfonephonebookapp/features/clubs/services/profile_service.dart';
import 'package:flutter/material.dart';

class RcScreens extends StatefulWidget {
  const RcScreens({super.key});

  @override
  State<RcScreens> createState() => _RcScreensState();
}

class _RcScreensState extends State<RcScreens> {
  final ProfileService service = ProfileService();
  List profiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    final data = await service.getrcProfiles();
    setState(() {
      profiles = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

                const SizedBox(height: 20),

                // 🏷 Title
                const Text(
                  "RC",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E86A1),
                  ),
                ),

                const SizedBox(height: 10),

                // 📋 List
                Expanded(
                  child: ListView.builder(
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final p = profiles[index];

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => ProfileDetailPage(profile: p),
                          );
                        },
                        child: ProfileCard(
                          name: p['person_name'] ?? '',
                          post: p['post_of_member'] ?? '',
                          club: p['club'] ?? '',
                          phone: p['mobile_number'] ?? '',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
