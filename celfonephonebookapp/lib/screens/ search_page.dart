import 'package:celfonephonebookapp/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../supabase/supabase.dart'; // keep for fetch

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedIndex = 0;
  final List<String> filters = ["All", "Business", "People", "Products"];
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> searchResults = [];
  bool isLoading = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _performSearch("");
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    setState(() {
      isLoggedIn = username != null && username.isNotEmpty;
    });
  }

  String maskMobile(String number) {
    if (number.length < 5) return number;
    return number.substring(0, 5) + "XXXXX";
  }

  RichText highlightText(String text, String query,
      {Color color = Colors.blue}) {
    if (query.isEmpty) return RichText(
        text: TextSpan(text: text, style: const TextStyle(color: Colors.black)));

    final matches = RegExp(RegExp.escape(query), caseSensitive: false).allMatches(text);

    if (matches.isEmpty) return RichText(
        text: TextSpan(text: text, style: const TextStyle(color: Colors.black)));

    List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start), style: const TextStyle(color: Colors.black)));
      }
      spans.add(TextSpan(text: text.substring(match.start, match.end),
          style: TextStyle(color: color, fontWeight: FontWeight.bold)));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: const TextStyle(color: Colors.black)));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Future<void> _performSearch(String query) async {
    setState(() => isLoading = true);
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
          request = request.or('business_name.ilike.%$query%,person_name.ilike.%$query%,city.ilike.%$query%');
        }
      }

      final results = await request.order('is_prime', ascending: false);
      setState(() => searchResults = results as List<dynamic>);
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSigninAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Signin Required"),
        content: const Text("You need to sign in to access this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SigninPage()));
            },
            child: const Text("Signin"),
          ),
        ],
      ),
    );
  }

  void _makeCall(String number) async {
    if (!isLoggedIn) return _showSigninAlert();
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  void _sendSMS(String number) async {
    if (!isLoggedIn) return _showSigninAlert();
    final Uri smsUri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
  }

  void _sendWhatsApp(String number) async {
    if (!isLoggedIn) return _showSigninAlert();
    final Uri waUri = Uri.parse("https://wa.me/$number");
    if (await canLaunchUrl(waUri)) await launchUrl(waUri);
  }

  void _sendEmail(String email) async {
    if (!isLoggedIn) return _showSigninAlert();
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
  }

  void _sendEnquiry(String name) {
    if (!isLoggedIn) return _showSigninAlert();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Enquiry sent to $name")),
    );
  }

  void _toggleFavorite(Map item) {
    if (!isLoggedIn) return _showSigninAlert();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Category to Save Favorite",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: ["Suppliers", "Buyers", "Friends & Family", "Others"].map((category) {
                  return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          item['is_favorite'] = true;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "${item['business_name'] ?? item['person_name']} saved under $category")),
                        );
                      },
                      child: Text(category));
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget highlightKeywords(String keywords, String query) {
    if (query.isEmpty) return Text(keywords, style: const TextStyle(color: Colors.black));

    List<InlineSpan> spans = [];
    final splitKeywords = keywords.split(','); // Split by comma

    for (int i = 0; i < splitKeywords.length; i++) {
      final word = splitKeywords[i];
      final matches = RegExp(RegExp.escape(query), caseSensitive: false).allMatches(word);

      if (matches.isEmpty) {
        spans.add(TextSpan(text: word, style: const TextStyle(color: Colors.black)));
      } else {
        int lastIndex = 0;
        for (final match in matches) {
          if (match.start > lastIndex) {
            spans.add(TextSpan(text: word.substring(lastIndex, match.start), style: const TextStyle(color: Colors.black)));
          }
          spans.add(TextSpan(
              text: word.substring(match.start, match.end),
              style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)));
          lastIndex = match.end;
        }
        if (lastIndex < word.length) {
          spans.add(TextSpan(text: word.substring(lastIndex), style: const TextStyle(color: Colors.black)));
        }
      }

      if (i != splitKeywords.length - 1) spans.add(const TextSpan(text: ", "));
    }

    return RichText(text: TextSpan(children: spans));
  }


  void _openDetailsModal(Map item) {
    if (!isLoggedIn) return _showSigninAlert();

    final name = item['business_name'] ?? item['person_name'] ?? "No Name";
    final mobile = item['mobile_number'] ?? "";
    final landline = item['landline'] ?? "";
    final email = item['email'] ?? "";
    final city = item['city'] ?? "";
    final address = item['address'] ?? "";
    final pincode = item['pincode'] ?? "";
    final keywords = item['keywords'] ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                    height: 5,
                    width: 50,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8)),
                  )),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              if (mobile.isNotEmpty) Text("Mobile: ${maskMobile(mobile)}"),
              if (landline.isNotEmpty) Text("Landline: $landline"),
              if (email.isNotEmpty) Text("Email: $email"),
              if (address.isNotEmpty) Text("Address: $address"),
              if (city.isNotEmpty) Text("City: $city"),
              if (pincode.isNotEmpty) Text("Pincode: $pincode"),
              if (selectedIndex == 3 && keywords.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: highlightText("keywords: $keywords", _searchController.text, color: Colors.deepOrange),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
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
                  if (email.isNotEmpty)
                    ElevatedButton.icon(
                        onPressed: () => _sendEmail(email),
                        icon: const Icon(Icons.email),
                        label: const Text("Email")),
                  ElevatedButton.icon(
                      onPressed: () => _sendEnquiry(name),
                      icon: const Icon(Icons.message),
                      label: const Text("Enquiry")),
                  ElevatedButton.icon(
                      onPressed: () => _toggleFavorite(item),
                      icon: const Icon(Icons.star),
                      label: const Text("Favorite")),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
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
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade700 : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(filters[index],
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 15)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _performSearch(value),
              decoration: InputDecoration(
                hintText: "Search here...",
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                ? const Center(child: Text("No results found", style: TextStyle(color: Colors.black54, fontSize: 16)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final item = searchResults[index];
                final isPrime = item['is_prime'] ?? false;
                final name = item['business_name'] ?? item['person_name'] ?? "No Name";
                final keywords = item['keywords'] ?? "";

                return GestureDetector(
                  onTap: () => _openDetailsModal(item),
                  child: Card(
                    elevation: isPrime ? 6 : 2,
                    color: isPrime ? Colors.blue.shade50 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isPrime ? BorderSide(color: Colors.blue.shade700, width: 1.5) : BorderSide.none,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: highlightText(name, query),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          if (item['mobile_number'] != null)
                            Text(maskMobile(item['mobile_number'])),
                          if (item['city'] != null)
                            Text(item['city']),
                          if (selectedIndex == 3 && keywords.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Keywords: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(child: highlightKeywords(keywords, _searchController.text)),
                              ],
                            ),
                          ]
                        ],
                      ),

                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(icon: const Icon(Icons.call, color: Colors.green), onPressed: () => _makeCall(item['mobile_number'])),
                          IconButton(icon: const Icon(Icons.message, color: Colors.orange), onPressed: () => _sendEnquiry(name)),
                          IconButton(
                              icon: Icon((item['is_favorite'] ?? false) ? Icons.star : Icons.star_border, color: Colors.amber),
                              onPressed: () => _toggleFavorite(item)),
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
