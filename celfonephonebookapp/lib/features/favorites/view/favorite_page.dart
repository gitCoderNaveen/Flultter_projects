import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/favorite_controller.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteController controller = FavoriteController();

  /// selected favorites map
  /// key = favorite_id
  /// value = true/false
  final Map<String, bool> selectedFavorites = {};

  /// SMS dialog
  void showSmsDialog(List<Map<String, dynamic>> favorites) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const _HeaderRow(collapsed: true),

          content: TextField(
            controller: textController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Enter your message",
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                sendSms(textController.text, favorites);

                Navigator.pop(context);
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  /// Send SMS
  Future<void> sendSms(
    String message,
    List<Map<String, dynamic>> favorites,
  ) async {
    final selectedIds = selectedFavorites.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one contact")),
      );

      return;
    }

    final numbers = favorites
        .where((fav) => selectedIds.contains(fav['id']))
        .map((fav) => fav['mobile_number'])
        .join(',');

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: numbers,
      queryParameters: {'body': message},
    );

    await launchUrl(smsUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: controller.favoritesStream(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No favorites yet"));
          }

          final favorites = snapshot.data!;

          /// GROUP favorites by group_name
          Map<String, List<Map<String, dynamic>>> grouped = {};

          for (var fav in favorites) {
            final groupName = fav['group_name'] ?? "Others";

            grouped.putIfAbsent(groupName, () => []);

            grouped[groupName]!.add(fav);
          }

          return Column(
            children: [
              /// GROUPED LIST
              Expanded(
                child: ListView(
                  children: grouped.entries.map((entry) {
                    final groupName = entry.key;

                    final groupFavorites = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        /// GROUP HEADER
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            groupName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),

                        /// FAVORITES
                        ...groupFavorites.map((fav) {
                          final favId = fav['id'];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),

                            child: CheckboxListTile(
                              value: selectedFavorites[favId] ?? false,

                              onChanged: (value) {
                                setState(() {
                                  selectedFavorites[favId] = value!;
                                });
                              },

                              title: Text(
                                fav['business_name'] ??
                                    fav['person_name'] ??
                                    '',
                              ),

                              subtitle: Text(fav['mobile_number'] ?? ''),

                              secondary: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),

                                onPressed: () async {
                                  await controller.deleteFavorite(favId);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Deleted")),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),

              /// SEND SMS BUTTON
              Padding(
                padding: const EdgeInsets.all(12),

                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      showSmsDialog(favorites);
                    },

                    child: const Text("Send SMS"),
                  ),
                ),
              ),
            ],
          );
        },
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
