import 'package:celfonephonebookapp/features/clubs/lions_club/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LionsOfficialsScreen extends StatelessWidget {
  const LionsOfficialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
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

            // 🏛 Titles
            const Text(
              "Lions Clubs International",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "District 3242C",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Lions Officials",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // 📦 Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  MenuCard(
                    title: "Cabinet",
                    onTap: () => context.push('/cabinet_screen'),
                  ),
                  MenuCard(
                    title: "RC",
                    onTap: () => context.push('/rc_screen'),
                  ),
                  MenuCard(
                    title: "ZC",
                    onTap: () => context.push('/zc_screen'),
                  ),
                  MenuCard(
                    title: "DC",
                    onTap: () => context.push('/dc_screen'),
                  ),
                  MenuCard(
                    title: "xx1",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("This feature will be updated soon"),
                        ),
                      );
                    },
                  ),
                  MenuCard(
                    title: "xx2",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("This feature will be updated soon"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔽 Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => context.push('/club_members'),
                child: Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E86A1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Club Members",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
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
