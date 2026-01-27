import 'package:celfonephonebookapp/core/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelPage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ModelPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final bool isPrime = profile['is_prime'] == true;
    final String subscription = (profile['subscription'] ?? 'free')
        .toString()
        .toLowerCase();

    final String name =
        profile['business_name'] ?? profile['person_name'] ?? 'User';

    final String mobile = profile['mobile_number'] ?? '';
    final String city = profile['city'] ?? '';
    final String address = profile['address'] ?? '';
    final String description = profile['description'] ?? '';
    final String keywords = profile['keywords'] ?? '';

    final String profileId = profile['id']?.toString() ?? '';

    if (profileId.isNotEmpty) {
      AnalyticsService.logProfileView(profileId);
    }

    final Color primaryColor = isPrime
        ? Colors.amber
        : subscription == 'business'
        ? Colors.pink
        : Colors.grey;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (city.isNotEmpty)
                          Text(
                            city,
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  if (isPrime)
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.amber,
                      size: 28,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 Action buttons (horizontal)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (mobile.isNotEmpty)
                    _ActionIcon(
                      icon: Icons.call,
                      label: 'Call',
                      color: Colors.green,
                      onTap: () {
                        AnalyticsService.logLead(
                          profileId: profile['id'],
                          leadType: 'call',
                        );
                        launchUrl(Uri.parse('tel:$mobile'));
                      },
                    ),
                  if (mobile.isNotEmpty)
                    _ActionIcon(
                      icon: Icons.message,
                      label: 'Enquiry',
                      color: Colors.blue,
                      onTap: () {
                        AnalyticsService.logLead(
                          profileId: profile['id'],
                          leadType: 'whatsapp',
                        );
                        final msg =
                            'I found your listing in Phone Book+. Please share details.';
                        launchUrl(
                          Uri.parse(
                            'https://wa.me/$mobile?text=${Uri.encodeComponent(msg)}',
                          ),
                        );
                      },
                    ),
                  _ActionIcon(
                    icon: Icons.favorite_border,
                    label: 'Favorite',
                    color: Colors.pink,
                    onTap: () {
                      AnalyticsService.logLead(
                        profileId: profile['id'],
                        leadType: 'enquiry',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 🔹 Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (address.isNotEmpty)
                      _InfoRow(icon: Icons.location_on, text: address),

                    if (keywords.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Products / Services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: -6,
                        children: keywords
                            .split(',')
                            .map(
                              (k) => Chip(
                                label: Text(
                                  k.trim(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(height: 1.5, fontSize: 14),
                      ),
                    ],

                    const SizedBox(height: 40),
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

/// 🔹 Reusable widgets

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
