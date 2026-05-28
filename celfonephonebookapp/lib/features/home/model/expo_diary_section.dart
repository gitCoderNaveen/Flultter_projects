import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpoDiarySection extends StatefulWidget {
  const ExpoDiarySection({super.key});

  @override
  State<ExpoDiarySection> createState() => _ExpoDiarySectionState();
}

class _ExpoDiarySectionState extends State<ExpoDiarySection> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  List<dynamic> expos = [];

  @override
  void initState() {
    super.initState();
    fetchExpos();
  }

  Future<void> fetchExpos() async {
    final res = await supabase.from('expo').select();

    setState(() {
      expos = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expos.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expo Diary",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // --- HORIZONTAL TO GRID UPGRADE (3 ITEMS PER ROW) ---
          GridView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 🔥 Ore row-la 3 items set aiyidum bro
              crossAxisSpacing: 10, // Proper side gaps
              mainAxisSpacing: 10, // Proper bottom gaps
              childAspectRatio:
                  0.95, // Accurate frame alignment matching directory
            ),
            itemBuilder: (_, index) {
              final expo = expos[index];

              return GestureDetector(
                onTap: () {
                  context.push('/search?expo_id=${expo['id']}');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.network(
                      expo['expo_image'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
