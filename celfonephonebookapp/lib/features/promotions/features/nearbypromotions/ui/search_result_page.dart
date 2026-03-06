import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/nearbypromotion_controller.dart';
import '../model/nearbypromotion_model.dart';

class SearchResultsPage extends StatefulWidget {
  final List<NearbyPromotionModel> profiles;
  final String message;
  final NearbyPromotionController controller;

  const SearchResultsPage({
    super.key,
    required this.profiles,
    required this.message,
    required this.controller,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  /// available to select
  List<NearbyPromotionModel> available = [];

  /// selected but not sent yet
  List<NearbyPromotionModel> selected = [];

  /// already sent items
  List<NearbyPromotionModel> sentItems = [];

  @override
  void initState() {
    super.initState();
    available = List.from(widget.profiles);
  }

  /// SELECT ITEM
  void selectItem(NearbyPromotionModel item) {
    if (sentItems.contains(item)) return;

    setState(() {
      available.remove(item);
      selected.add(item);
    });
  }

  /// REMOVE SELECTED ITEM (before sending)
  void unselectItem(NearbyPromotionModel item) {
    setState(() {
      selected.remove(item);
      available.add(item);
    });
  }

  /// SEND SMS
  Future<void> sendSMS() async {
    if (selected.isEmpty) return;

    String phones = selected.map((e) => e.mobileNumber).join(",");

    final uri = Uri.parse(
      "sms:$phones?body=${Uri.encodeComponent(widget.message)}",
    );

    await launchUrl(uri);

    await widget.controller.markAsSent(selected);

    /// move to sentItems
    setState(() {
      sentItems.addAll(selected);
      selected.clear();
    });
  }

  /// CLEAR SENT ITEMS
  void clearSentItems() {
    setState(() {
      /// move all back to available
      available.addAll(sentItems);

      sentItems.clear();
    });
  }

  /// CARD UI
  Widget buildCard(
    NearbyPromotionModel item, {
    required bool isSelected,
    required bool isSent,
  }) {
    return GestureDetector(
      onTap: isSent
          ? null
          : () {
              if (isSelected) {
                unselectItem(item);
              } else {
                selectItem(item);
              }
            },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        margin: const EdgeInsets.symmetric(vertical: 6),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: isSent ? Colors.grey.shade400 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(3, 3)),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.businessName ?? item.personName ?? "Unknown",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,

                    /// STRIKE THROUGH IF SENT
                    decoration: isSent
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),

                Text(
                  widget.controller.maskMobile(item.mobileNumber),

                  style: TextStyle(
                    decoration: isSent
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),

            if (isSent)
              const Icon(Icons.done, color: Colors.green)
            else if (isSelected)
              const Icon(Icons.check_box, color: Colors.green)
            else
              const Icon(Icons.check_box_outline_blank),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Results")),

      body: Column(
        children: [
          /// AVAILABLE SECTION
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Available (${available.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: [
                        /// available
                        ...available.map(
                          (e) => buildCard(e, isSelected: false, isSent: false),
                        ),

                        /// selected but not sent
                        ...selected.map(
                          (e) => buildCard(e, isSelected: true, isSent: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// SENT ITEMS SECTION
          Container(
            height: 250,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Send Items (${sentItems.length})",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: sentItems.isEmpty ? null : clearSentItems,
                      child: const Text("Clear"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    children: sentItems
                        .map(
                          (e) => buildCard(e, isSelected: false, isSent: true),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: ElevatedButton(
                    onPressed: selected.isEmpty ? null : sendSMS,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),

                    child: const Text("Send SMS"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
