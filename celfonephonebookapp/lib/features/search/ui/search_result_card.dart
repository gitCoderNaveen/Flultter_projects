import 'package:celfonephonebookapp/core/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/search_filter.dart';
import '../../../core/utils/model_sheet.dart';

class SearchResultCard extends StatelessWidget {
  final dynamic item;
  final SearchFilter filter;

  const SearchResultCard({super.key, required this.item, required this.filter});

  @override
  Widget build(BuildContext context) {
    final bool isPrime = item['is_prime'] == true;

    final String name =
        item['business_name'] ?? item['person_name'] ?? 'Unknown';

    final String mobile = item['mobile_number'] ?? '';
    final String city = item['city'] ?? '';
    final String product = _extractProduct(item['keywords']);

    final String subtitle = filter == SearchFilter.products ? product : city;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        openProfileModal(context, item); // ✅ OPEN MODAL
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPrime ? const Color(0xFFFFF8E1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrime ? Colors.amber : Colors.grey.shade300,
            width: isPrime ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// LEFT: CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name + premium badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isPrime ? Colors.brown : Colors.black87,
                          ),
                        ),
                      ),
                      if (isPrime)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.workspace_premium,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// City or Product
                  Text(
                    subtitle.isEmpty ? '—' : subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// RIGHT: ACTION ICONS (horizontal)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconAction(
                  icon: Icons.call,
                  color: Colors.green,
                  onTap: () {
                    AnalyticsService.logLead(
                      profileId: item['id'],
                      leadType: 'call',
                    );
                    launchUrl(Uri.parse('tel:$mobile'));
                  },
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.message,
                  color: Colors.blueGrey,
                  onTap: () {
                    final msg =
                        'I found your listing on Phone Book+. Please share details.';
                    launchUrl(
                      Uri.parse(
                        'https://wa.me/$mobile?text=${Uri.encodeComponent(msg)}',
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.favorite_border,
                  color: Colors.pink,
                  onTap: () {
                    // TODO: save to favorites (Supabase)
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Extract first product
  String _extractProduct(dynamic keywords) {
    if (keywords == null) return '';

    if (keywords is String) {
      return keywords.split(',').first.trim();
    }

    if (keywords is List && keywords.isNotEmpty) {
      final first = keywords.first;
      if (first is Map) {
        return first['name'] ?? first['title'] ?? '';
      }
      return first.toString();
    }

    return '';
  }
}

/// 🔹 Compact icon-only action button
class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
