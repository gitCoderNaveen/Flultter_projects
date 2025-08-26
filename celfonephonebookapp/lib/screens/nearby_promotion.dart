import 'package:flutter/material.dart';
import '../supabase/supabase.dart';

class NearbyPromotionPage extends StatefulWidget {
  const NearbyPromotionPage({super.key});

  @override
  State<NearbyPromotionPage> createState() => _NearbyPromotionPageState();
}

class _NearbyPromotionPageState extends State<NearbyPromotionPage> {
  // Guidance information dropdown
  final List<String> infoOptions = [
    'Select Information',
    'Promotional Guidance 1',
    'Promotional Guidance 2'
  ];
  String? selectedInfo;

  // Pincode & Prefix
  List<String> pincodeList = [];
  String? selectedPincode;

  List<String> prefixList = [];
  String? selectedPrefix;

  // SMS text
  final TextEditingController _smsController = TextEditingController();
  final int smsCharLimit = 145;

  // Search results
  List<Map<String, dynamic>> results = [];
  List<String> selectedMobileNumbers = [];
  bool isLoading = false;
  int page = 0;
  final int pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPincodeList();
    _fetchPrefixList();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchPincodeList() async {
    try {
      final response =
      await SupabaseService.client.from('profiles').select('DISTINCT pincode');
      setState(() {
        pincodeList = List<String>.from(response.map((e) => e['pincode']));
      });
    } catch (e) {
      debugPrint("Error fetching pincode list: $e");
    }
  }

  Future<void> _fetchPrefixList() async {
    try {
      final businessPrefixes =
      await SupabaseService.client.from('business_prefix').select('prefix');
      final personPrefixes =
      await SupabaseService.client.from('person_prefix').select('prefix');

      final combined = [
        ...businessPrefixes.map((e) => e['prefix']),
        ...personPrefixes.map((e) => e['prefix'])
      ];

      setState(() {
        prefixList = List<String>.from(combined);
      });
    } catch (e) {
      debugPrint("Error fetching prefix list: $e");
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchMoreResults();
    }
  }

  Future<void> _searchResults({bool reset = true}) async {
    if (reset) {
      page = 0;
      results.clear();
    }

    if (selectedPincode == null || selectedPrefix == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select pincode and prefix")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('business_name, person_name, mobile_number')
          .ilike('mobile_number', '$selectedPrefix%')
          .eq('pincode', selectedPincode!)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      setState(() {
        results.addAll(List<Map<String, dynamic>>.from(response));
        page++;
      });
    } catch (e) {
      debugPrint("Error fetching results: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching results: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchMoreResults() async {
    if (!isLoading && results.length >= page * pageSize) {
      await _searchResults(reset: false);
    }
  }

  void _toggleSelection(String mobile) {
    if (selectedMobileNumbers.contains(mobile)) {
      selectedMobileNumbers.remove(mobile);
    } else {
      if (selectedMobileNumbers.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can select up to 10 contacts only")),
        );
        return;
      }
      selectedMobileNumbers.add(mobile);
    }
    setState(() {});
  }

  void _sendSms() {
    if (_smsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a message")),
      );
      return;
    }
    if (selectedMobileNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one contact")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Message sent to ${selectedMobileNumbers.length} contacts successfully!"),
      ),
    );

    // Reset selection
    selectedMobileNumbers.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _smsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Promotion")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information dropdown
            DropdownButtonFormField<String>(
              value: selectedInfo,
              hint: const Text("Select Information"),
              items: infoOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedInfo = v),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Information",
              ),
            ),
            const SizedBox(height: 10),

            // Pincode input (autocomplete)
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return pincodeList.where((p) => p.contains(textEditingValue.text));
              },
              onSelected: (val) {
                selectedPincode = val;
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: "Pincode",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    selectedPincode = val;
                  },
                );
              },
            ),
            const SizedBox(height: 10),

            // Prefix dropdown
            DropdownButtonFormField<String>(
              value: selectedPrefix,
              hint: const Text("Select Prefix"),
              items: prefixList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedPrefix = v),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Prefix"),
            ),
            const SizedBox(height: 10),

            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text("Search"),
                onPressed: _searchResults,
              ),
            ),
            const SizedBox(height: 10),

            // SMS input
            TextField(
              controller: _smsController,
              maxLength: smsCharLimit,
              maxLines: null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Message",
                counterText: "${_smsController.text.length}/$smsCharLimit",
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            // Send SMS button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Send SMS"),
                onPressed: _sendSms,
              ),
            ),
            const SizedBox(height: 10),

            // Results list
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: results.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= results.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final item = results[index];
                final mobile = item['mobile_number'] ?? '';
                final maskedMobile = mobile.length >= 10
                    ? '${mobile.substring(0, 5)}XXXX'
                    : mobile;

                final isSelected = selectedMobileNumbers.contains(mobile);

                return Card(
                  child: ListTile(
                    title: Text(item['business_name'] ?? item['person_name'] ?? ''),
                    subtitle: Text(maskedMobile),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(mobile),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
