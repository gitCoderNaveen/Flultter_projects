import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelPage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ModelPage({super.key, required this.profile});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Helper to format mobile number
  String formatMobile(String number) {
    if (number.length >= 5) {
      return number.substring(0, 5) + " " + "X" * (number.length - 5);
    }
    return number;
  }

  /// Launchers
  Future<void> _makePhoneCall(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String number) async {
    final Uri uri = Uri.parse("https://wa.me/$number");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendSMS(String number) async {
    final Uri uri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    // Images list
    List<String> images =
        (profile["images"] as List?)?.map((e) => e.toString()).toList() ?? [];

    final mobile = profile["mobile"] ?? "";
    final email = profile["email"];
    final keywords = profile["keywords"];
    final address = profile["address"];
    final city = profile["city"];
    final pincode = profile["pincode"];
    final person_name = profile["person_name"];
    final landline = profile['landline'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// ---------- Top Image Section ----------
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  if (images.isNotEmpty)
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  else
                    Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.camera_alt,
                            size: 50, color: Colors.grey),
                      ),
                    ),

                  /// Back button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  /// Page Dots
                  if (images.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                              (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 10 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.blue
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// ---------- Content ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Profile Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              (() {
                                // Get the name
                                final name = (profile["business_name"] ?? profile["person_name"] ?? "UK").toString().trim();
                                // Return first character if not empty, else "U"
                                return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "UK";
                              })(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile["business_name"] ?? profile["person_name"] ?? "No Name",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (profile["keywords"] != null)
                                  Text(
                                    profile["keywords"],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    //Person name
                    if (person_name.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            person_name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    /// Mobile
                    if (mobile.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            formatMobile(mobile),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    /// Keywords
                    if (keywords.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.label, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              keywords,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    /// Address
                    if (address != null || city != null || pincode != null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${address ?? ""}, ${city ?? ""}, ${pincode ?? ""}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    /// Buttons: Call, Email, WhatsApp, SMS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () => _makePhoneCall(mobile),
                          tooltip: "Call",
                        ),
                        if (email.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.email,
                                color: Colors.redAccent),
                            onPressed: () => _sendEmail(email),
                            tooltip: "Email",
                          ),
                        if (mobile.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.message_sharp,
                                color: Colors.green),
                            onPressed: () => _openWhatsApp(mobile),
                            tooltip: "WhatsApp",
                          ),
                        if (mobile.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.sms, color: Colors.blue),
                            onPressed: () => _sendSMS(mobile),
                            tooltip: "SMS",
                          ),
                      ],
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
