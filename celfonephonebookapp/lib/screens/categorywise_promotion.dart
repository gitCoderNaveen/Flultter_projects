import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../supabase/supabase.dart';

class CategoryPromotionPage extends StatefulWidget {
  const CategoryPromotionPage({Key? key}) : super(key: key);

  @override
  State<CategoryPromotionPage> createState() => _CategoryPromotionPageState();
}

class _CategoryPromotionPageState extends State<CategoryPromotionPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(
    text:
    'I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)',
  );

  bool isLoading = false;
  List<dynamic> profiles = [];
  List<dynamic> selectedProfiles = [];
  int maxSelect = 10;
  int maxLength = 290;
  bool isValidCategory = false;

  // Suggestions
  List<String> keywordSuggestions = [];

  void _validateCategoryInput(String value) {
    setState(() {
      isValidCategory = value.trim().length >= 3;
    });

    if (value.trim().isNotEmpty) {
      _fetchKeywordSuggestions(value.trim());
    } else {
      setState(() => keywordSuggestions.clear());
    }
  }

  Future<void> _fetchKeywordSuggestions(String query) async {
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select('keywords')
          .ilike('keywords', '%$query%');

      final suggestions = <String>{};
      for (var row in data) {
        final kws = (row['keywords'] ?? '').toString().split(',');
        for (var kw in kws) {
          if (kw.toLowerCase().contains(query.toLowerCase())) {
            suggestions.add(kw.trim());
          }
        }
      }

      setState(() => keywordSuggestions = suggestions.toList());
    } catch (e) {
      debugPrint("Keyword suggestion error: $e");
    }
  }

  Future<void> _searchCategory(String keyword) async {
    if (keyword.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter at least 3 characters to search."),
      ));
      return;
    }

    setState(() => isLoading = true);
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .or('keywords.ilike.%$keyword%');

      final validProfiles = data.where((p) {
        final bName = (p['business_name'] ?? '').toString().trim();
        final pName = (p['person_name'] ?? '').toString().trim();
        return bName.isNotEmpty || pName.isNotEmpty;
      }).toList();

      setState(() => profiles = validProfiles);

      if (context.mounted) _openBottomSheet();
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              void toggleSelection(dynamic client) {
                setModalState(() {
                  if (selectedProfiles.any((c) => c['id'] == client['id'])) {
                    selectedProfiles.removeWhere((c) => c['id'] == client['id']);
                  } else if (selectedProfiles.length < maxSelect) {
                    selectedProfiles.add(client);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("You can select a maximum of 10 users."),
                    ));
                  }
                });
              }

              void clearSelection() {
                setModalState(() => selectedProfiles.clear());
              }

              void closeModal() {
                Navigator.pop(context);
              }

              Future<void> sendSMS() async {
                if (selectedProfiles.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("No users selected!"),
                  ));
                  return;
                }

                final numbers = selectedProfiles
                    .map((c) => c['mobile_number'].toString())
                    .join(',');

                final message = _messageController.text;
                final smsUri =
                Uri.parse("sms:$numbers?body=${Uri.encodeComponent(message)}");

                if (await canLaunchUrl(smsUri)) {
                  await launchUrl(smsUri);
                  Navigator.pop(context);
                  setState(() {
                    selectedProfiles.clear();
                    _categoryController.clear();
                    _cityController.clear();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Failed to open SMS app."),
                  ));
                }
              }

              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      "Results: ${profiles.length} | Selected: ${selectedProfiles.length}"),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: closeModal,
                    )
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: profiles.isEmpty
                          ? const Center(child: Text("No results found."))
                          : ListView.builder(
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final client = profiles[index];
                          final bName =
                          (client['business_name'] ?? '').toString().trim();
                          final pName =
                          (client['person_name'] ?? '').toString().trim();
                          final name =
                          bName.isNotEmpty ? bName : pName.isNotEmpty ? pName : '';

                          if (name.isEmpty) return const SizedBox.shrink();

                          final keywords = client['keywords'] ?? '';
                          final mobile = client['mobile_number'] ?? '';
                          final masked =
                          mobile.length >= 5 ? '${mobile.substring(0, 5)} XXXX' : mobile;

                          final isSelected =
                          selectedProfiles.any((c) => c['id'] == client['id']);

                          return Card(
                            color: isSelected
                                ? Colors.lightBlue.shade50
                                : Colors.white,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text("$keywords\n$masked"),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (_) => toggleSelection(client),
                              ),
                              onTap: () => toggleSelection(client),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: clearSelection,
                            icon: const Icon(Icons.clear),
                            label: const Text("Clear"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent),
                          ),
                          ElevatedButton.icon(
                            onPressed: closeModal,
                            icon: const Icon(Icons.close),
                            label: const Text("Close"),
                            style:
                            ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          ),
                          ElevatedButton.icon(
                            onPressed: sendSMS,
                            icon: const Icon(Icons.sms),
                            label: const Text("Send SMS"),
                            style:
                            ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryField() {
    return Column(
      children: [
        TextField(
          controller: _categoryController,
          onChanged: _validateCategoryInput,
          decoration: InputDecoration(
            labelText: "Category* (min 3 chars)",
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isValidCategory ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            suffixIcon: isValidCategory
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.close, color: Colors.red),
          ),
        ),
        if (keywordSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: keywordSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = keywordSuggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    _categoryController.text = suggestion;
                    setState(() => keywordSuggestions.clear());
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Category Wise Promotion"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // HELP DROPDOWN
            Card(
              elevation: 2,
              child: ExpansionTile(
                title: const Text(
                  "How to use Category Wise Promotion",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: const [
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Send Text messages to all Mobile Users dealing in a specific product / keyword, all over the selected city.\n\n"
                          "1) First edit / create message to be sent. Minimum 1 Count (145 characters), Maximum 2 counts (290 characters)\n"
                          "2) Type specific Category / product / keyword\n"
                          "3) For error free delivery of messages, send in batches 10 each time.",
                      style: TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // MESSAGE INPUT
            TextField(
              controller: _messageController,
              maxLength: maxLength,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Edit/Create Message",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // CATEGORY INPUT WITH SUGGESTIONS
            _buildCategoryField(),
            const SizedBox(height: 12),

            // CITY SEARCH (DUMMY)
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: "City (Optional)",
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 12),

            // SEARCH BUTTON
            ElevatedButton.icon(
              onPressed: () =>
                  _searchCategory(_categoryController.text.trim()),
              icon: const Icon(Icons.search),
              label: const Text("Search"),
            ),
          ],
        ),
      ),
    );
  }
}
