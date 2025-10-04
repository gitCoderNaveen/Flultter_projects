import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../supabase/supabase.dart'; // Your Supabase client

class NearbyPromotionPage extends StatefulWidget {
  const NearbyPromotionPage({super.key});

  @override
  State<NearbyPromotionPage> createState() => _NearbyPromotionPageState();
}

class _NearbyPromotionPageState extends State<NearbyPromotionPage> {
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _customMessageController = TextEditingController(
    text:
    'I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)',
  );

  String? selectedPrefix;
  List<dynamic> datas = [];
  List<dynamic> selectedBusinesses = [];
  bool isLoading = false;

  final int maxSelection = 10;
  final int maxLength = 290;

  final Map<String, String> prefixMap = {
    'Gents': 'Mr.',
    'Ladies': 'Ms.',
    'Firms': 'M/s.',
  };

  @override
  void dispose() {
    _pincodeController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  /// ✅ Toggle selection by mobile_number
  void toggleSelection(dynamic item) {
    final isSelected = selectedBusinesses.any(
          (i) => i['mobile_number'] == item['mobile_number'],
    );

    if (isSelected) {
      setState(() {
        selectedBusinesses.removeWhere(
              (i) => i['mobile_number'] == item['mobile_number'],
        );
      });
    } else {
      if (selectedBusinesses.length < maxSelection) {
        setState(() {
          selectedBusinesses.add(item);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 10 recipients allowed')),
        );
      }
    }
  }

  /// ✅ Send SMS to selected numbers
  void sendSMSBatch() async {
    if (selectedBusinesses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No clients selected')),
      );
      return;
    }

    final numbers =
    selectedBusinesses.map((e) => e['mobile_number'].toString()).join(',');

    final smsUri = Uri.parse(
      'sms:$numbers?body=${Uri.encodeComponent(_customMessageController.text)}',
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      // Clear after sending
      clearFilters();
      _customMessageController.text =
      'I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch SMS app')),
      );
    }
  }

  /// ✅ Clear filters & selections
  void clearFilters() {
    _pincodeController.clear();
    selectedPrefix = null;
    datas = [];
    selectedBusinesses = [];
    setState(() {});
  }

  /// ✅ Fetch businesses from Supabase
  Future<void> fetchBusinesses() async {
    final pincode = _pincodeController.text.trim();
    final prefix = selectedPrefix;

    if (pincode.isEmpty || prefix == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter pincode & select prefix')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .or(
          'pincode.eq.$pincode,business_prefix.eq.$prefix,person_prefix.eq.$prefix');

      final data = await response;

      if (data == null || (data as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records found')),
        );
      } else {
        datas = data;
        selectedBusinesses = [];

        // ✅ Show results in modal bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    children: [
                      // Top info
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Results: ${datas.length}, Selected: ${selectedBusinesses.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Scrollable list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: datas.length,
                          itemBuilder: (context, index) {
                            final item = datas[index];
                            final isSelected = selectedBusinesses.any(
                                  (i) =>
                              i['mobile_number'] == item['mobile_number'],
                            );
                            final name = item['business_name'] ??
                                item['person_name'] ??
                                'No Name';
                            final mobile = item['mobile_number'] ?? '';

                            return Card(
                              color: isSelected
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              child: ListTile(
                                onTap: () {
                                  toggleSelection(item);
                                  setModalState(() {}); // refresh bottom sheet
                                },
                                title: Text(name),
                                subtitle: Text(
                                  mobile.length > 5
                                      ? mobile.substring(
                                      0, mobile.length - 5) +
                                      'XXXXX'
                                      : mobile,
                                ),
                                trailing: Checkbox(
                                  value: isSelected,
                                  onChanged: (_) {
                                    toggleSelection(item);
                                    setModalState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Bottom buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: selectedBusinesses.isEmpty
                                  ? null
                                  : sendSMSBatch,
                              child: const Text('Send SMS'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                clearFilters();
                                Navigator.pop(context);
                              },
                              child: const Text('Clear'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Promotion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Message input
            TextField(
              controller: _customMessageController,
              maxLength: maxLength,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Edit/Create Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Prefix selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: prefixMap.keys.map((label) {
                final backendValue = prefixMap[label]!;
                final isSelected = selectedPrefix == backendValue;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => selectedPrefix = backendValue),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Pincode input
            TextField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter Pincode',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Search button
            ElevatedButton(
              onPressed: fetchBusinesses,
              child: const Text('Search'),
            ),
            const SizedBox(height: 12),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

