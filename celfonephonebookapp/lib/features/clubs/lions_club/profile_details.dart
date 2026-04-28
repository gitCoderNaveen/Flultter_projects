import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDetailPage extends StatelessWidget {
  final Map profile;

  const ProfileDetailPage({super.key, required this.profile});

  void launchUrlHandler(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
  String formatMobile(String? number) {
  if (number == null || number.isEmpty) return '';

  final clean = number.replaceAll(RegExp(r'\D'), '');

  if (clean.length <= 5) return clean;

  return "${clean.substring(0, 5)} XXXXX";
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // 🔷 Custom Header (LIKE DESIGN)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            color: const Color(0xFF2E86A1),
            child: Column(
              children: const [
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

          // 🔽 BODY
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 🔝 Image
                  Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E86A1),
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image:
                              (profile['image_url'] != null &&
                                  profile['image_url'].toString().isNotEmpty)
                              ? NetworkImage(profile['image_url'])
                              : const AssetImage('images/lions_icon.png')
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📞 Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionImage("Mobile", "images/call.png", () {
                        launchUrlHandler("tel:${profile['mobile_number']}");
                      }),

                      _actionImage("Landline", "images/land_line.png", () {
                        launchUrlHandler("tel:${profile['landline']}");
                      }),

                      _actionImage("SMS", "images/sms.png", () {
                        launchUrlHandler("sms:${profile['mobile_number']}");
                      }),

                      _actionImage("WhatsApp", "images/whats_app.png", () {
                        launchUrlHandler(
                          "https://wa.me/${profile['mobile_number']}",
                        );
                      }),

                      if (profile['email'] != null &&
                          profile['email'].toString().isNotEmpty)
                        _actionImage("Mail", "images/email.png", () {
                          launchUrlHandler("mailto:${profile['email']}");
                        }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🧾 Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        profile['person_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 📄 Details
                  if (profile['business_name'] != null &&
                      profile['business_name'].toString().isNotEmpty)
                    _row(Icons.person, profile['business_name']),

                  _row(Icons.phone, profile['mobile_number']),

                  if (profile['email'] != null &&
                      profile['email'].toString().isNotEmpty)
                    _row(Icons.mail, profile['email']),

                  _row(Icons.location_on, profile['address']),

                  const Divider(thickness: 2),

                  // 📊 Bottom Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Mem Num: ${profile['member_num'] ?? ''}"),
                            Text("DoB: ${profile['DOB'] ?? ''}"),
                            Text("DoW: ${profile['DOW'] ?? ''}"),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Spouse: ${profile['spouse'] ?? ''}"),
                            Text(
                              "Blood Group: ${profile['blood_group'] ?? ''}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Image Action Widget
  Widget _actionImage(String label, String assetPath, VoidCallback onTap, ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Image.asset(assetPath, height: 30, width: 30),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // 🔹 Row Widget
  Widget _row(IconData icon, String? text) {
    if (text == null || text.toString().isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
