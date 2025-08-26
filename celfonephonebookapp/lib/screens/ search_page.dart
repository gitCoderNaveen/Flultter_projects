import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../supabase/supabase.dart'; // import your supabase.dart

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedIndex = 0; // Default "All"
  final List<String> filters = ["All", "Business", "People", "Products"];
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _performSearch(""); // fetch all by default
  }

  // --- Utility to mask mobile number ---
  String maskMobile(String number) {
    if (number.length < 5) return number;
    return number.substring(0, 5) + "XXXXX";
  }

  // --- Highlight text ---
  RichText highlightText(String text, String query,
      {Color color = Colors.blue}) {
    if (query.isEmpty) {
      return RichText(
          text: TextSpan(
              text: text, style: const TextStyle(color: Colors.black)));
    }

    final matches =
    RegExp(RegExp.escape(query), caseSensitive: false).allMatches(text);
    if (matches.isEmpty) {
      return RichText(
          text: TextSpan(
              text: text, style: const TextStyle(color: Colors.black)));
    }

    List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
            text: text.substring(lastIndex, match.start),
            style: const TextStyle(color: Colors.black)));
      }
      spans.add(TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(color: color, fontWeight: FontWeight.bold)));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
          text: text.substring(lastIndex),
          style: const TextStyle(color: Colors.black)));
    }

    return RichText(text: TextSpan(children: spans));
  }

  // --- Fetch Data from Supabase ---
  Future<void> _performSearch(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      String filterType = filters[selectedIndex].toLowerCase();

      var request = SupabaseService.client.from('profiles').select();

      if (filterType == "business") {
        request = request.eq('user_type', 'business');
      } else if (filterType == "people") {
        request = request.eq('user_type', 'person');
      }

      if (query.isNotEmpty) {
        if (filterType == "products") {
          request = request.ilike('keywords', '%$query%');
        } else {
          request = request.or(
              'business_name.ilike.%$query%,person_name.ilike.%$query%,city.ilike.%$query%');
        }
      }

      final results = await request.order('is_prime', ascending: false);

      setState(() {
        searchResults = results as List<dynamic>;
      });
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- Call / Email / WhatsApp / SMS ---
  void _makeCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  void _sendSMS(String number) async {
    final Uri smsUri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
  }

  void _sendWhatsApp(String number) async {
    final Uri waUri = Uri.parse("https://wa.me/$number");
    if (await canLaunchUrl(waUri)) await launchUrl(waUri);
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
  }

  // --- Enquiry function (placeholder) ---
  void _sendEnquiry(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Enquiry sent to $name")),
    );
  }

  // --- Favorite toggle ---
  void _toggleFavorite(Map item) {
    setState(() {
      item['is_favorite'] = !(item['is_favorite'] ?? false);
    });
  }

  // --- Open details modal ---
  void _openDetailsModal(Map item) {
    final name =
        item['business_name'] ?? item['person_name'] ?? "No Name Available";
    final mobile = item['mobile_number'] ?? "";
    final landline = item['landline'] ?? "";
    final email = item['email'] ?? "";
    final city = item['city'] ?? "";
    final address = item['address'] ?? "";
    final pincode = item['pincode'] ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text(name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (mobile.isNotEmpty) Text("Mobile: ${maskMobile(mobile)}"),
              if (landline.isNotEmpty) Text("Landline: $landline"),
              if (email.isNotEmpty) Text("Email: $email"),
              if (address.isNotEmpty) Text("Address: $address"),
              if (city.isNotEmpty) Text("City: $city"),
              if (pincode.isNotEmpty) Text("Pincode: $pincode"),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (mobile.isNotEmpty)
                    ElevatedButton.icon(
                        onPressed: () => _makeCall(mobile),
                        icon: const Icon(Icons.call),
                        label: const Text("Call")),
                  if (mobile.isNotEmpty)
                    ElevatedButton.icon(
                        onPressed: () => _sendSMS(mobile),
                        icon: const Icon(Icons.sms),
                        label: const Text("SMS")),
                  if (mobile.isNotEmpty)
                    ElevatedButton.icon(
                        onPressed: () => _sendWhatsApp(mobile),
                        icon: const Icon(Icons.message_rounded),
                        label: const Text("WhatsApp")),
                  if (landline.isNotEmpty)
                    ElevatedButton.icon(
                        onPressed: () => _makeCall(landline),
                        icon: const Icon(Icons.phone),
                        label: const Text("Landline")),
                  if (email.isNotEmpty)
                    ElevatedButton.icon(
                        onPressed: () => _sendEmail(email),
                        icon: const Icon(Icons.email),
                        label: const Text("Email")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String query = _searchController.text;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Search Page",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // --- Filter Buttons First ---
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = index);
                    _performSearch(_searchController.text);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade700
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // --- Search Bar Second ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _performSearch(value),
              decoration: InputDecoration(
                hintText: "Search here...",
                prefixIcon:
                const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Results Section ---
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                ? const Center(
              child: Text("No results found",
                  style: TextStyle(
                      fontSize: 16, color: Colors.black54)),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final item = searchResults[index];
                final isPrime = item['is_prime'] ?? false;
                final name = item['business_name'] ??
                    item['person_name'] ??
                    "No Name";
                final keywords = item['keywords'] ?? "";

                return GestureDetector(
                  onTap: () => _openDetailsModal(item),
                  child: Card(
                    elevation: isPrime ? 6 : 2,
                    color: isPrime
                        ? Colors.blue.shade50
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isPrime
                          ? BorderSide(
                          color: Colors.blue.shade700,
                          width: 1.5)
                          : BorderSide.none,
                    ),
                    margin:
                    const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: highlightText(name, query),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          if (item['mobile_number'] != null)
                            Text(maskMobile(
                                item['mobile_number'])),
                          if (item['city'] != null)
                            Text(item['city']),
                          if (selectedIndex == 3 &&
                              keywords.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            highlightText(
                                "Keywords: $keywords", query,
                                color: Colors.deepOrange),
                          ]
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.call,
                                  color: Colors.green),
                              onPressed: () => _makeCall(
                                  item['mobile_number'])),
                          IconButton(
                              icon: const Icon(Icons.message,
                                  color: Colors.orange),
                              onPressed: () =>
                                  _sendEnquiry(name)),
                          IconButton(
                            icon: Icon(
                              (item['is_favorite'] ?? false)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () =>
                                _toggleFavorite(item),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
