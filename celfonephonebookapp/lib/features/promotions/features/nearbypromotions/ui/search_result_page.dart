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

    final launched = await launchUrl(uri);

    if (launched) {
      await widget.controller.markAsSent(selected);

      setState(() {
        sentItems.addAll(selected);
        selected.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("SMS App Opened Successfully"),
              ],
            ),
          ),
        );
      }
    }
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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      body: Stack(
        children: [
          /// HEADER
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0A7CFF), Color(0xff20C6F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xff0A7CFF),
                          ),
                        ),
                      ),

                      const SizedBox(width: 18),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Search Results",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "Select contacts to send SMS",
                            style: TextStyle(
                              color: Colors.white.withOpacity(.95),
                              fontSize: 14,
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
                      color: Color(0xffF7F9FD),

                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        children: [
                          /// HEADER ROW
                          Row(
                            children: [
                              Text(
                                "Available (${available.length})",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),

                              const Spacer(),

                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (selected.length ==
                                        widget.profiles.length) {
                                      available = List.from(widget.profiles);
                                      selected.clear();
                                    } else {
                                      selected = List.from(widget.profiles);
                                      available.clear();
                                    }
                                  });
                                },

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(30),
                                  ),

                                  child: Row(
                                    children: [
                                      Text(
                                        "Select All",
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Icon(
                                        selected.length == available.length
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        color: Colors.blue.shade700,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Expanded(
                            child: ListView.builder(
                              itemCount: available.length + selected.length,

                              itemBuilder: (context, index) {
                                NearbyPromotionModel item;

                                if (index < available.length) {
                                  item = available[index];
                                } else {
                                  item = selected[index - available.length];
                                }

                                return AnimatedScale(
                                  duration: const Duration(milliseconds: 250),
                                  scale: 1,
                                  child: buildModernCard(
                                    item,
                                    selected.contains(item),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          const SizedBox(height: 15),

                          ///==============================
                          /// SEND ITEMS PANEL
                          ///==============================
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 290,

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(35),
                                topRight: Radius.circular(35),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(20),

                              child: Column(
                                children: [
                                  /// DRAG HANDLE
                                  Container(
                                    width: 55,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  /// TITLE
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Colors.deepPurple.shade100,
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.deepPurple,
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Send Items (${selected.length})",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                              ),
                                            ),

                                            Text(
                                              selected.isEmpty
                                                  ? "No contacts selected"
                                                  : "${selected.length} contacts selected",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            available.addAll(selected);

                                            selected.clear();
                                          });
                                        },

                                        borderRadius: BorderRadius.circular(30),

                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),

                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),

                                              const SizedBox(width: 8),

                                              const Text(
                                                "Clear",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  if (selected.isEmpty)
                                    Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 48,
                                          backgroundColor:
                                              Colors.deepPurple.shade50,

                                          child: Icon(
                                            Icons.sms_outlined,
                                            size: 50,
                                            color: Colors.deepPurple,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        const Text(
                                          "Select contacts from above",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Text(
                                          "Choose one or more contacts to send SMS",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    SizedBox(
                                      height: 90,

                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,

                                        itemCount: selected.length,

                                        itemBuilder: (context, index) {
                                          final item = selected[index];

                                          final name =
                                              item.businessName ??
                                              item.personName ??
                                              "";

                                          return Container(
                                            width: 75,
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),

                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Colors.blue.shade100,
                                                  radius: 24,

                                                  child: Text(
                                                    name[0].toUpperCase(),
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Text(
                                                  name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                  const Spacer(),

                                  SizedBox(
                                    width: 260,
                                    height: 55,

                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xff16A34A),
                                            Color(0xff27C65B),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(
                                              .35,
                                            ),
                                            blurRadius: 18,
                                          ),
                                        ],
                                      ),

                                      child: ElevatedButton.icon(
                                        onPressed: selected.isEmpty
                                            ? null
                                            : sendSMS,

                                        icon: const Icon(Icons.send),

                                        label: const Text(
                                          "Send SMS",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,

                                          disabledBackgroundColor:
                                              Colors.grey.shade300,

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              40,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color getAvatarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.deepPurple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];

    return colors[index % colors.length];
  }

  Widget buildModernCard(NearbyPromotionModel item, bool isSelected) {
    final index = widget.profiles.indexOf(item);

    final color = getAvatarColor(index);

    final name = item.businessName ?? item.personName ?? "Unknown";

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selected.remove(item);

            if (!available.contains(item)) {
              available.add(item);
            }
          } else {
            selected.add(item);
            available.remove(item);
          }
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        margin: const EdgeInsets.only(bottom: 10),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            /// LEFT COLOR BAR
            Container(
              width: 5,
              height: 118,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  children: [
                    /// AVATAR
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withOpacity(.12),

                      child: Text(
                        name[0].toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            widget.controller.maskMobile(item.mobileNumber),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),

                      width: 30,
                      height: 30,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),

                        border: Border.all(color: Colors.blue, width: 2),

                        color: isSelected ? Colors.blue : Colors.white,
                      ),

                      child: Icon(
                        Icons.check,
                        size: 26,
                        color: isSelected ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
