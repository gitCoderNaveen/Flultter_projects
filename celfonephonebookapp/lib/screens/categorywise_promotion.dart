import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../supabase/supabase.dart'; // Use your existing supabase.dart

class CategoryPromotionPage extends StatefulWidget {
  const CategoryPromotionPage({Key? key}) : super(key: key);

  @override
  State<CategoryPromotionPage> createState() => _CategoryPromotionPageState();
}

class _CategoryPromotionPageState extends State<CategoryPromotionPage> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(
      text:
      'I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)');

  List<dynamic> allProfiles = [];
  List<dynamic> filteredProfiles = [];
  List<dynamic> selectedClients = [];
  List<String> citySuggestions = [];

  bool isLoading = false;
  int maxSelect = 10;
  int maxLength = 290;

  @override
  void initState() {
    super.initState();
    _fetchAllProfiles();
  }

  Future<void> _fetchAllProfiles() async {
    setState(() => isLoading = true);
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .order('id', ascending: false);
      if (data != null) {
        setState(() {
          allProfiles = data;
          filteredProfiles = List.from(data);
          citySuggestions = [
            ...{for (var e in data) e['city']?.toString() ?? ''}
          ]..removeWhere((element) => element.isEmpty); // unique cities
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterByCity(String city) {
    setState(() {
      filteredProfiles = allProfiles
          .where((p) =>
          (p['city'] ?? '').toString().toLowerCase().contains(city.toLowerCase()))
          .toList();
    });
  }

  void _toggleClientSelection(dynamic client) {
    setState(() {
      if (selectedClients.any((c) => c['id'] == client['id'])) {
        selectedClients.removeWhere((c) => c['id'] == client['id']);
      } else if (selectedClients.length < maxSelect) {
        selectedClients.add(client);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("You can select a maximum of 10 clients."),
        ));
      }
    });
  }

  Future<void> _sendSMS() async {
    if (selectedClients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No clients selected!"),
      ));
      return;
    }

    final numbers =
    selectedClients.map((c) => c['mobile_number'].toString()).join(',');

    final message = _messageController.text;
    final smsUri = Uri.parse("sms:$numbers?body=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      setState(() {
        selectedClients.clear();
        _cityController.clear();
        _messageController.text =
        'I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me. (Sent Through Signpost PHONE BOOK)';
        filteredProfiles = List.from(allProfiles);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to open SMS app."),
      ));
    }
  }

  Widget _buildClientCard(dynamic client) {
    final isSelected = selectedClients.any((c) => c['id'] == client['id']);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        title: Text(client['business_name'] ?? client['person_name'] ?? ''),
        subtitle: Text(client['mobile_number'] ?? ''),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => _toggleClientSelection(client),
        ),
        onTap: () => _toggleClientSelection(client),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Category Promotion"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Message input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _messageController,
              maxLength: maxLength,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Edit/Create Message",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // City input with dropdown suggestions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return citySuggestions.where((city) => city
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (value) {
                _cityController.text = value;
                _filterByCity(value);
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                _cityController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Filter by City',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _filterByCity(value),
                );
              },
            ),
          ),

          // Send SMS button on top
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _sendSMS,
              icon: const Icon(Icons.sms),
              label: const Text("Send SMS"),
            ),
          ),

          // Scrollable list of cards
          Expanded(
            child: ListView.builder(
              itemCount: filteredProfiles.length,
              itemBuilder: (context, index) {
                final client = filteredProfiles[index];
                return _buildClientCard(client);
              },
            ),
          ),

          // Send SMS button at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _sendSMS,
              icon: const Icon(Icons.sms),
              label: const Text("Send SMS"),
            ),
          ),
        ],
      ),
    );
  }
}
