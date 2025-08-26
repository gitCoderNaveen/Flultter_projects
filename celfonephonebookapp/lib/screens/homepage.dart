import 'package:celfonephonebookapp/screens/signin.dart';
import 'package:flutter/material.dart';
import '../supabase/supabase.dart';
import '../widgets/ carousel_widget.dart';
import '../widgets/playbook_carousel.dart';
import './ search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;

  final List<Map<String, String>> categories = [
    {"title": "Suppliers", "icon": "🛠️"},
    {"title": "Textiles", "icon": "🧵"},
    {"title": "Spinning", "icon": "🌀"},
    {"title": "Furniture", "icon": "🪑"},
    {"title": "Foundary", "icon": "🏭"},
    {"title": "Machinery", "icon": "⚙️"},
  ];

  @override
  void initState() {
    super.initState();
    _loadCachedUsername();   // Load from SharedPreferences first
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        Future.delayed(const Duration(seconds: 10), () {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Welcome Celfon5G+ Phonebook"),
                  content: const Text("Log in for more features"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // dismiss only
                      child: const Text("Later"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 👉 Navigate to login screen here
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SigninPage()));
                      },
                      child: const Text("Log In"),
                    ),
                  ],
                );
              },
            );
          }
        });
        return;
      }

      final userId = user.id;

      final response = await SupabaseService.client
          .from('profiles')
          .select('business_name, person_name')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final businessName = response['business_name'] as String?;
        final personName = response['person_name'] as String?;

        final resolvedName = businessName?.isNotEmpty == true
            ? businessName!
            : (personName?.isNotEmpty == true ? personName! : "User");

        // 🔹 Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", resolvedName);

        setState(() {
          username = resolvedName;
        });

        debugPrint("✅ Username fetched & stored: $resolvedName");
      } else {
        debugPrint("⚠️ No profile found for user $userId");
      }
    } catch (e, st) {
      debugPrint("❌ Error fetching profile: $e\n$st");
    }
  }

  /// Call this in `initState()` before hitting Supabase
  Future<void> _loadCachedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString("username");
    if (cachedName != null && cachedName.isNotEmpty) {
      setState(() {
        username = cachedName;
      });
      debugPrint("📦 Loaded cached username: $cachedName");
    }
  }

  void _goToSearch(BuildContext context, {String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // 🔹 Top Section
          Container(
            color: const Color(0xFF306CBC),
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      username != null ? "Welcome, $username 👋" : "Welcome Guest👋",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {
                        // TODO: Notifications screen
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tagline
                const Text(
                  "Find Anyone! AnyWhere!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Grow your business with your nearby customers.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Search Box
                GestureDetector(
                  onTap: () => _goToSearch(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text("Search", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Advertisement carousel
          const CarouselWidget(
            images: [
              "assets/images/images1.png",
              "assets/images/images2.png",
              "assets/images/images3.png",
            ],
          ),

          const SizedBox(height: 24),


          // 🔹 Category Tiles
          // 🔹 Quick Search Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Search",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () =>
                          _goToSearch(context, category: category["title"]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blueAccent.shade100),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(category["icon"]!,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 6),
                            Text(
                              category["title"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),


          const SizedBox(height: 24),

          // 🔹 PlayBook carousel (taller)
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
              "Play Book",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 400,
          child: PlayBookWidget(
            images: [
              "assets/images/book1.png",
              "assets/images/book2.png",
              "assets/images/book3.png",
            ],
            links: [
              "https://play.google.com/store/books/details/Lion_Dr_Er_J_Shivakumaar_Chief_Editor_COIMBATORE_N?id=nCpLDwAAQBAJ",
              "https://play.google.com/store/books/details/Lion_Dr_Er_J_Shivakumaar_COIMBATORE_2025_26_Indust?id=sCE6EQAAQBAJ",
              "https://play.google.com/store/books/details/Lion_Dr_Er_J_Shivakumaar_COIMBATORE_2024_Industria?id=kwgSEQAAQBAJ",
            ],
          ),
        ),
      ],
    )
        ],
      ),
    );
  }


}
