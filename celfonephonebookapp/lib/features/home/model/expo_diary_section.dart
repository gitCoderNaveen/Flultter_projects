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
    final res = await supabase
        .from('expo')
        .select();

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "Expo Diary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: expos.length,
            itemBuilder: (_, index) {
              final expo = expos[index];

              return GestureDetector(
                onTap: () {
                  context.push(
                    '/search?expo_id=${expo['id']}',
                  );
                },

                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(left: 16, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            expo['expo_image'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          expo['expo_name'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}