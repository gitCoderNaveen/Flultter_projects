import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _messageController = TextEditingController(
    text:
    "I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)",
  );
  int _remainingChars = 160;

  List<dynamic> groups = [];
  String? selectedGroupId;

  List<dynamic> members = [];
  Set<String> selectedMembers = {}; // store mobile numbers

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _remainingChars = 160 - _messageController.text.length;
    _messageController.addListener(() {
      setState(() {
        _remainingChars = 160 - _messageController.text.length;
      });
    });
  }

  /// Load favorite groups for logged-in user
  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    try {
      setState(() => isLoading = true);
      final result = await Supabase.instance.client
          .from('favorites_groups')
          .select()
          .eq('user_id', userId);

      setState(() {
        groups = result as List<dynamic>;
      });
    } catch (e) {
      debugPrint("Error fetching groups: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Load members for selected group
  Future<void> _loadMembers(String groupId) async {
    try {
      setState(() => isLoading = true);
      final result = await Supabase.instance.client
          .from('group_members')
          .select()
          .eq('group_id', groupId);

      setState(() {
        members = result as List<dynamic>;
        selectedMembers.clear();
      });
    } catch (e) {
      debugPrint("Error fetching members: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Mask mobile number
  String _maskMobile(String mobile) {
    if (mobile.length < 5) return mobile;
    return "${mobile.substring(0, 5)} XXXXX";
  }

  /// Send SMS to selected members
  Future<void> _sendSMS() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message cannot be empty")),
      );
      return;
    }

    if (selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one member")),
      );
      return;
    }

    final numbers = selectedMembers.join(",");
    final uri = Uri.parse(
        "sms:$numbers?body=${Uri.encodeComponent(_messageController.text)}");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch SMS app")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction message
            const Text(
              "Based on the firms Shortlisted while browsing, respective groups will be displayed below. Select desired Group to send message",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Top message input
            TextField(
              controller: _messageController,
              maxLength: 160,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: "$_remainingChars characters left",
              ),
            ),
            const SizedBox(height: 16),

            // Groups list
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Select Group",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...groups.map((group) {
                    final groupId = group['id'].toString();
                    return CheckboxListTile(
                      title: Text(group['group_name'] ?? "Unnamed Group"),
                      value: selectedGroupId == groupId,
                      onChanged: (val) {
                        if (val == true) {
                          setState(() {
                            selectedGroupId = groupId;
                          });
                          _loadMembers(groupId);
                        } else {
                          setState(() {
                            selectedGroupId = null;
                            members.clear();
                          });
                        }
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // Members list
                  if (members.isNotEmpty) ...[
                    const Text(
                      "Select Members (Max 10)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...members.map((member) {
                      final mobile = member['mobile_number'] ?? "";
                      final name = member['member_name'] ?? "Unknown";
                      final masked = _maskMobile(mobile);

                      return CheckboxListTile(
                        title: Text("$name ($masked)"),
                        value: selectedMembers.contains(mobile),
                        onChanged: (val) {
                          if (val == true) {
                            if (selectedMembers.length >= 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "You can select up to 10 members only",
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              selectedMembers.add(mobile);
                            });
                          } else {
                            setState(() {
                              selectedMembers.remove(mobile);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),

            // Send SMS button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendSMS,
                icon: const Icon(Icons.sms),
                label: const Text("Send SMS"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
