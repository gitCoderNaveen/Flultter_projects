import 'package:celfonephonebookapp/screens/%20search_page.dart';
import 'package:celfonephonebookapp/screens/signin.dart';
import 'package:celfonephonebookapp/widgets/carousel_widgets.dart';
import 'package:celfonephonebookapp/widgets/playbook_carousel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../supabase/supabase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String? username;
  String? userId;

  // 🔹 Banner & Festival Animation State
  final SupabaseClient supabase = SupabaseService.client;
  List<Map<String, dynamic>> banners = [];
  bool isLoading = true;
  int currentIndex = 0;

  // 🔹 Categories
  final List<Map<String, String>> categories = [
    {"title": "Suppliers", "icon": "🛠️"},
    {"title": "Textiles", "icon": "🧵"},
    {"title": "Spinning", "icon": "🌀"},
    {"title": "Furniture", "icon": "🪑"},
    {"title": "Foundary", "icon": "🏭"},
    {"title": "Machinery", "icon": "⚙️"},
  ];

  // 🔹 A–Z Letters
  final List<String> letters = List.generate(26, (index) => String.fromCharCode(65 + index));

  @override
  void initState() {
    super.initState();
    _loadCachedUserData();
    _loadBanners();
  }

  Future<void> _loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    userId = prefs.getString("userId");

    if (username == null || username!.isEmpty) {
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Welcome Celfon5G+ Phonebook"),
                content: const Text("Log in for more features"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Later"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SigninPage()),
                      );
                    },
                    child: const Text("Log In"),
                  ),
                ],
              );
            },
          );
        }
      });
    }
  }

  Future<void> _loadBanners() async {
    try {
      final response = await supabase.from('app_banner').select();
      final data = (response as List)
          .map((e) => {
        "image_url": e['image_url'] as String,
        "festival": e['festival'] as String? ?? "default"
      })
          .toList();

      setState(() {
        banners = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching banners: $e");
      setState(() => isLoading = false);
    }
  }

  String _getFestivalAnimation(String festival) {
    switch (festival.toLowerCase()) {
      case "diwali":
        return "assets/animations/fireworks.json"; // 🎆 crackers
      case "pongal":
        return "assets/animations/celebrations.json"; // 🪁 kites
      case "christmas":
        return "assets/animations/modeltwo.json"; // ❄️ snow
      default:
        return "assets/animations/fireworks.json"; // fallback
    }
  }

  void _goToSearch(BuildContext context, {String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 🔹 Fixed Search Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 4,
            title: GestureDetector(
              onTap: () => _goToSearch(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Search...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Top Banner with Festival Animation
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: Stack(
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (banners.isEmpty)
                    const Center(child: Text("No banners available"))
                  else
                    CarouselSlider.builder(
                      itemCount: banners.length,
                      options: CarouselOptions(
                        height: 250,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                      itemBuilder: (context, index, realIdx) {
                        final banner = banners[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            banner['image_url'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),

                  // 🎉 Festival Animation Overlay
                  if (banners.isNotEmpty)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Lottie.asset(
                          _getFestivalAnimation(banners[currentIndex]['festival']),
                          fit: BoxFit.cover,
                          repeat: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 🔹 Rest of the Content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              const CarouselWidget(
                images: [
                  "assets/images/images1.png",
                  "assets/images/images2.png",
                  "assets/images/images3.png",
                ],
              ),

              const SizedBox(height: 24),

              // A-Z Horizontal Scroll
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: letters.length,
                  itemBuilder: (context, index) {
                    final letter = letters[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchPage(
                                selectedLetter: letter, // 🔹 Pass only the letter
                              ),
                            ),
                          );
                        },
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Quick Search
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
                          onTap: () => _goToSearch(context, category: category["title"]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blueAccent.shade100),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(category["icon"]!, style: const TextStyle(fontSize: 24)),
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

              // Play Book
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
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
