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
  bool showResults = false;
  bool clrBtn = false;

  final int maxSelection = 10;
  final int maxLength = 290;

  @override
  void dispose() {
    _pincodeController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  Future<void> fetchBusinesses() async {
    final pincode = _pincodeController.text.trim();
    final prefix = selectedPrefix;

    if (pincode.isEmpty || prefix == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter pincode & select prefix')));
      return;
    }

    setState(() => isLoading = true);

    try {
      // Supabase query
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .or('pincode.eq.$pincode,business_prefix.eq.$prefix,person_prefix.eq.$prefix');

      // Await the builder to get data
      final data = await response;

      if (data == null || (data as List).isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No records found')));
        setState(() {
          datas = [];
          showResults = false;
        });
      } else {
        setState(() {
          datas = data;
          showResults = true;
          clrBtn = true;
          selectedBusinesses = [];
        });
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
      setState(() => isLoading = false);
    } finally {
      setState(() => isLoading = false);
    }
  }


  void clearFilters() {
    _pincodeController.clear();
    selectedPrefix = null;
    datas = [];
    selectedBusinesses = [];
    clrBtn = false;
    showResults = false;
    setState(() {});
  }

  void toggleSelection(dynamic item) {
    final isSelected =
    selectedBusinesses.any((i) => i['id'] == item['id']);
    if (isSelected) {
      setState(() {
        selectedBusinesses.removeWhere((i) => i['id'] == item['id']);
      });
    } else {
      if (selectedBusinesses.length < maxSelection) {
        setState(() {
          selectedBusinesses.add(item);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 10 recipients allowed')));
      }
    }
  }

  void sendSMSBatch() async {
    if (selectedBusinesses.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No clients selected')));
      return;
    }

    final numbers = selectedBusinesses
        .map((e) => e['mobile_number'].toString())
        .join(',');

    final smsUri =
    Uri.parse('sms:$numbers?body=${Uri.encodeComponent(_customMessageController.text)}');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      // Clear after sending
      clearFilters();
      _customMessageController.text =
      'I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)';
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cannot launch SMS app')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Promotion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Message input
            TextField(
              controller: _customMessageController,
              maxLength: maxLength,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Edit/Create Message', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // Prefix selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mr.', 'Ms.', 'M/s.'].map((p) {
                final isSelected = selectedPrefix == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedPrefix = p),
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
                  labelText: 'Enter Pincode', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // Search / Clear button
            ElevatedButton(
              onPressed: clrBtn ? clearFilters : fetchBusinesses,
              child: Text(clrBtn ? 'Clear' : 'Search'),
            ),
            const SizedBox(height: 12),


            if (isLoading) const CircularProgressIndicator(),

            if (showResults)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Send SMS button
                  ElevatedButton(
                    onPressed: selectedBusinesses.isEmpty ? null : sendSMSBatch,
                    child: const Text('Send SMS'),
                  ),
                  const SizedBox(height: 8),
                  Text('Results: ${datas.length}, Selected: ${selectedBusinesses.length}'),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: datas.length,
                    itemBuilder: (context, index) {
                      final item = datas[index];
                      final isSelected = selectedBusinesses.any((i) => i['id'] == item['id']);
                      final name = item['business_name'] ?? item['person_name'] ?? 'No Name';
                      final mobile = item['mobile_number'] ?? '';
                      return Card(
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        child: ListTile(
                          onTap: () => toggleSelection(item),
                          title: Text(name),
                          subtitle: Text(
                            mobile.length > 5
                                ? mobile.substring(0, mobile.length - 5) + 'XXXXX'
                                : mobile,
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (_) => toggleSelection(item),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Bottom Send SMS button (existing)
                  ElevatedButton(
                      onPressed:
                      selectedBusinesses.isEmpty ? null : sendSMSBatch,
                      child: const Text('Send SMS')),
                ],
              ),

          ],
        ),
      ),
    );
  }
}
