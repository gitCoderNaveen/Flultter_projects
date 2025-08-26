import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Map<String, List<Map<String, dynamic>>> favorites = {};
  Map<String, Set<int>> selected = {}; // track selected indexes per category
  TextEditingController smsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = ["Suppliers", "Buyers", "Friends & Family", "Others"];
    Map<String, List<Map<String, dynamic>>> data = {};

    for (var cat in categories) {
      List<String> stored = prefs.getStringList("favorites_$cat") ?? [];
      data[cat] = stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    }

    setState(() {
      favorites = data;
      selected = {for (var cat in categories) cat: {}};
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in favorites.entries) {
      List<String> encoded = entry.value.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList("favorites_${entry.key}", encoded);
    }
  }

  void _deleteSelected() {
    setState(() {
      for (var entry in selected.entries) {
        final category = entry.key;
        final indexes = entry.value.toList()..sort((a, b) => b.compareTo(a)); // delete backwards
        for (var i in indexes) {
          favorites[category]?.removeAt(i);
        }
        selected[category]?.clear();
      }
    });
    _saveFavorites();
  }

  Future<void> _sendSMS() async {
    List<String> numbers = [];
    for (var entry in selected.entries) {
      final category = entry.key;
      for (var i in entry.value) {
        final contact = favorites[category]?[i];
        if (contact != null && contact["mobile_number"] != null) {
          numbers.add(contact["mobile_number"]);
        }
      }
    }
    if (numbers.isEmpty) return;

    final message = Uri.encodeComponent(smsController.text.trim());
    final recipients = numbers.join(",");
    final smsUri = Uri.parse("sms:$recipients?body=$message");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch SMS app")),
      );
    }
  }

  String _maskMobile(String? number) {
    if (number == null || number.length < 5) return number ?? "";
    final visible = number.substring(0, number.length - 5);
    return "${visible}XXXXX";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelected,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: favorites.entries.map((entry) {
                return ExpansionTile(
                  title: Text(entry.key),
                  children: entry.value.asMap().entries.map((item) {
                    final index = item.key;
                    final data = item.value;
                    final isSelected = selected[entry.key]?.contains(index) ?? false;

                    return ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selected[entry.key]?.add(index);
                            } else {
                              selected[entry.key]?.remove(index);
                            }
                          });
                        },
                      ),
                      title: Text(data["name"] ?? ""),
                      subtitle: Text(_maskMobile(data["mobile_number"])),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            favorites[entry.key]?.removeAt(index);
                          });
                          _saveFavorites();
                        },
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: smsController,
                  decoration: const InputDecoration(
                    hintText: "Enter SMS message",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Send SMS"),
                  onPressed: _sendSMS,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
