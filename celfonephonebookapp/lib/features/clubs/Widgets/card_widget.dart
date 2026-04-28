import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String post;
  final String club;
  final String phone;

  const ProfileCard({
    super.key,
    required this.name,
    required this.post,
    required this.club,
    required this.phone,
  });

  void makeCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // 🧾 Text Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(post, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Text(club, style: const TextStyle(fontSize: 16)),
            ],
          ),

          // 📞 ❤️ Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.call, size: 28),
                onPressed: () => makeCall(phone),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, size: 28),
                onPressed: () {
                  // TODO: add favorite logic
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}