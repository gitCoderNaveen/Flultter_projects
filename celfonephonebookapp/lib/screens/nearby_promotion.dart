import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../supabase/supabase.dart'; // Your Supabase client file

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
  bool isExpanded = false;
  bool isLoading = false;
  bool isPincodeValid = false;

  final int maxSelection = 10;
  final int maxLength = 290;

  final Map<String, String> prefixMap = {
    'Gents': 'Mr.',
    'Ladies': 'Ms.',
    'Firms': 'M/s.',
  };

  @override
  void initState() {
    super.initState();
    _pincodeController.addListener(_validatePincode);
  }

  void _validatePincode() {
    final value = _pincodeController.text.trim();
    setState(() {
      isPincodeValid = RegExp(r'^\d{6}$').hasMatch(value);
    });
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  /// ✅ Toggle business selection
  void toggleSelection(dynamic item) {
    final isSelected = selectedBusinesses.any(
            (i) => i['mobile_number'] == item['mobile_number']);

    setState(() {
      if (isSelected) {
        selectedBusinesses
            .removeWhere((i) => i['mobile_number'] == item['mobile_number']);
      } else {
        if (selectedBusinesses.length < maxSelection) {
          selectedBusinesses.add(item);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 10 recipients allowed')),
          );
        }
      }
    });
  }

  /// ✅ Send SMS to selected businesses
  Future<void> sendSMSBatch() async {
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
      clearFilters();
      _customMessageController.text =
      'I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch SMS app')),
      );
    }
  }

  /// ✅ Reset all filters
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
    final prefixValue = selectedPrefix;

    if (pincode.isEmpty || prefixValue == null || !isPincodeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid pincode & select prefix')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      dynamic response;

      if (prefixValue == "Mr." || prefixValue == "Ms.") {
        // Person profiles
        response = await SupabaseService.client
            .from('profiles')
            .select('person_prefix, person_name, mobile_number')
            .eq('pincode', int.tryParse(pincode) ?? pincode)
            .eq('person_prefix', prefixValue)
            .not('person_name', 'is', null)
            .neq('person_name', '');
      } else if (prefixValue == "M/s.") {
        // Business profiles
        response = await SupabaseService.client
            .from('profiles')
            .select('business_prefix, business_name, mobile_number')
            .eq('pincode', int.tryParse(pincode) ?? pincode)
            .eq('business_prefix', prefixValue)
            .not('business_name', 'is', null)
            .neq('business_name', '');
      }

      final data = await response;
      debugPrint("✅ Query Result: $data");

      if (data == null || (data as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records found')),
        );
      } else {
        datas = data;
        selectedBusinesses = [];

        // ✅ Bottom sheet with results
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Results: ${datas.length}, Selected: ${selectedBusinesses.length}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: datas.length,
                          itemBuilder: (context, index) {
                            final item = datas[index];
                            final isSelected = selectedBusinesses.any(
                                    (i) =>
                                i['mobile_number'] ==
                                    item['mobile_number']);

                            final name = item['person_name'] ??
                                item['business_name'] ??
                                'No Name';
                            final mobile = item['mobile_number'] ?? '';

                            return Card(
                              color: isSelected
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              child: ListTile(
                                onTap: () {
                                  toggleSelection(item);
                                  setModalState(() {});
                                },
                                title: Text(name),
                                subtitle: Text(
                                  mobile.length > 5
                                      ? '${mobile.substring(0, mobile.length - 5)}XXXXX'
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
      debugPrint('❌ Fetch error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Promotion')),
      body: SingleChildScrollView( // 👈 wrap in scroll view to allow expansion
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔽 Expandable Help Section
            ExpansionTile(
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() => isExpanded = expanded);
              },
              title: const Text(
                'How to use Nearby Promotion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Text messages to Mobile Users in desired Pincode Area\n',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text('1️⃣ First edit / create message to be sent. Minimum 1 Count (145 characters), Maximum 2 counts (290 characters).'),
                      SizedBox(height: 6),
                      Text('2️⃣ Select type of Recipient (Males / Females / Business Firms).'),
                      SizedBox(height: 6),
                      Text('3️⃣ Type Pincode Number of Targeted area for Promotion.'),
                      SizedBox(height: 6),
                      Text('4️⃣ For error-free delivery of messages, send in batches of 10 nos. each time.'),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message Input
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

            // Prefix Chips
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

            // Pincode Input
            TextField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Enter Pincode',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isPincodeValid ? Colors.green : Colors.red,
                  ),
                ),
                suffixIcon: Icon(
                  isPincodeValid ? Icons.check_circle : Icons.cancel,
                  color: isPincodeValid ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search Button
            ElevatedButton(
              onPressed: isPincodeValid ? fetchBusinesses : null,
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
