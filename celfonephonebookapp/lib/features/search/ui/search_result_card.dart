import 'package:celfonephonebookapp/core/services/auth_service.dart';
import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:celfonephonebookapp/features/favorites/controller/favorite_controller.dart';
import 'package:celfonephonebookapp/features/favorites/view/favorite_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/search_filter.dart';

class SearchResultCard extends StatelessWidget {
  final Map item;
  final SearchFilter filter;

  const SearchResultCard({super.key, required this.item, required this.filter});

  @override
  Widget build(BuildContext context) {
    final bool isPrime = item['is_prime'] ?? false;
    final bool isBusiness = item['is_business'] ?? false;
    final bool discount = item['discount'] ?? false;
    final bool normal = item['normal_list'] ?? false;

    final String name =
        (item['business_name'] != null &&
            item['business_name'].toString().trim().isNotEmpty)
        ? item['business_name']
        : (item['person_name'] ?? "");

    final String mobileRaw = item['mobile_number'] ?? "";
    final String mobile = _formatMobile(mobileRaw);

    final String city = item['city'] ?? "";
    final String product = _extractProduct(item['keywords']);

    final String subtitle = filter == SearchFilter.products ? product : city;

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey;

    if (isPrime) {
      bgColor = Colors.white;
      borderColor = Colors.orange;
    } else if (isBusiness) {
      bgColor = Colors.white;
      borderColor = Colors.pink;
    } else if (normal) {
      borderColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        final id = item['id'].toString();
        final isPrime = item['is_prime'] == true;
        final isBusiness =
            item['is_business'] == true || item['normal_list'] == true;

        if (isBusiness) {
          context.push('/business_model', extra: id);
        } else if (isPrime) {
          context.push('/model_page', extra: id);
        } else {
          context.push('/free_model', extra: id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Row(
          children: [
            /// LEFT SIDE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      if (isPrime)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Image(
                            image: AssetImage("images/crown.png"),
                            width: 16,
                            height: 16,
                          ),
                        ),

                      if (discount)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Discount",
                            style: TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  /// MOBILE
                  Text(mobile, style: const TextStyle(fontSize: 12)),

                  /// CITY / PRODUCT
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            /// RIGHT SIDE
            Column(
              children: [
                Row(
                  children: [
                    /// CALL BUTTON
                    InkWell(
                      onTap: () {
                        _checkLogin(context, () {
                          _makeCall(mobileRaw);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.call, color: Colors.green, size: 20),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// FAVORITE BUTTON
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => FavoriteDialog(
                            onSelected: (groupName) async {
                              await FavoriteController().addToFavorite(
                                groupName: groupName,
                                businessName: item['business_name'],
                                personName: item['person_name'],
                                mobileNumber: item['mobile_number'],
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Added to favorites"),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// ENQUIRY BUTTON
                SizedBox(
                  height: 26,
                  width: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      _checkLogin(context, () {
                        _showEnquiryDialog(context);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                    child: const Text("Enquiry"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// LOGIN CHECK
  void _checkLogin(BuildContext context, VoidCallback onLoggedIn) {
    if (AuthService.isLoggedIn) {
      onLoggedIn();
    } else {
      context.push('/login');
    }
  }

  /// CALL
  void _makeCall(String mobile) {
    launchUrl(Uri.parse("tel:$mobile"));
  }

  /// ENQUIRY DIALOG (unchanged)
  void _showEnquiryDialog(BuildContext context) {
    const String defaultMessage =
        "I Saw Your Listing in SIGNPOST PHONE BOOK. "
        "I am Interested in your Products. Please Send Details/Call Me. "
        "(Sent Through Signpost PHONE BOOK)";
    final TextEditingController controller = TextEditingController(
      text: defaultMessage,
    );
    final String mobile = item['mobile_number'] ?? "";
    final String email = item['email'] ?? "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Send Enquiry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TEXTBOX WITH DEFAULT MESSAGE
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              /// ICON BUTTONS ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// WHATSAPP
                  _iconButton(
                    imagePath: "images/whats_app.png",
                    color: Colors.green,
                    onTap: () {
                      final msg = controller.text;
                      final url =
                          "https://wa.me/$mobile?text=${Uri.encodeComponent(msg)}";
                      launchUrl(Uri.parse(url));
                    },
                  ),

                  /// MAIL (only if exists)
                  if (email.isNotEmpty)
                    _iconButton(
                      icon: Icons.email,
                      color: Colors.blue,
                      onTap: () {
                        final msg = controller.text;
                        launchUrl(
                          Uri.parse(
                            "mailto:$email?subject=Enquiry&body=${Uri.encodeComponent(msg)}",
                          ),
                        );
                      },
                    ),

                  /// CALL
                  _iconButton(
                    icon: Icons.call,
                    color: Colors.green,
                    onTap: () {
                      launchUrl(Uri.parse("tel:$mobile"));
                    },
                  ),

                  /// SMS
                  _iconButton(
                    icon: Icons.sms,
                    color: Colors.orange,
                    onTap: () {
                      final msg = controller.text;
                      launchUrl(
                        Uri.parse(
                          "sms:$mobile?body=${Uri.encodeComponent(msg)}",
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _iconButton({
    IconData? icon,
    String? imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: imagePath != null
            ? Image.asset(imagePath, width: 24, height: 24)
            : Icon(icon, color: color, size: 24),
      ),
    );
  }

  String _formatMobile(String mobile) {
    if (mobile.length != 10) return mobile;
    return "${mobile.substring(0, 5)} XXXXX";
  }

  String _extractProduct(dynamic keywords) {
    if (keywords == null) return '';
    if (keywords is String) {
      return keywords.split(',').first.trim();
    }
    if (keywords is List && keywords.isNotEmpty) {
      return keywords.first.toString();
    }
    return '';
  }
}
