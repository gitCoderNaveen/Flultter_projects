import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:celfonephonebookapp/screens/admin_panel_page.dart';
import 'package:celfonephonebookapp/screens/profile_page.dart';
import './signup.dart';
import './signin.dart';
import 'homepage_shell.dart';

// SettingsPage (main entry)
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? displayName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final cachedUserName = prefs.getString('username');
    setState(() {
      displayName = cachedUserName;
      _isLoading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites_') ?? [];
      await prefs.clear();
      await prefs.setStringList('favorites_', favorites);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePageShell()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSignedIn = displayName != null && displayName!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  (displayName != null && displayName!.isNotEmpty)
                      ? displayName![0].toUpperCase()
                      : "U",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayName ?? "Guest User",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),

          // Auth options for guest
          if (!isSignedIn) ...[
            Card(
              child: ListTile(
                title: const Text("Sign In"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SigninPage()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Sign Up"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
              ),
            ),
            const Divider(),
          ],

          // PROFILE SETTINGS
          Card(
            child: ListTile(
              title: const Text("Profile Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              subtitle: const Text("Update your profile and business details"),
              onTap: () {
                if (isSignedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Not Logged In"),
                      content: const Text(
                          "You need to log in to access Profile Settings."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SigninPage()),
                            );
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // ADMIN PANEL
          Card(
            child: ListTile(
              title: const Text("Admin Panel"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              subtitle: const Text("Access advanced admin features"),
              onTap: () {
                if (isSignedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPanelPage(),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Need to Login"),
                      content: const Text(
                          "You must log in to access the Admin Panel."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SigninPage()),
                            );
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // NOTIFICATION SETTINGS
          Card(
            child: ListTile(
              title: const Text("Notification Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to Notification Settings Page
              },
            ),
          ),

          // NEW: ORDER FORM
          Card(
            child: ListTile(
              title: const Text("Order Form"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              subtitle: const Text("Choose your listing type"),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const OrderFormSheet(),
                );
              },
            ),
          ),
          const Divider(),

          // Logout for logged-in user
          if (isSignedIn)
            Card(
              child: ListTile(
                title: const Text("Logout"),
                trailing: const Icon(Icons.logout, color: Colors.red),
                onTap: () => _logout(context),
              ),
            ),
        ],
      ),
    );
  }
}

// ORDER FORM SHEET WITH ALL THREE CARD TYPES
class OrderFormSheet extends StatelessWidget {
  const OrderFormSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (context, scroll) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scroll,
          children: [
            Text(
              'Choose Listing Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FreeListingCard(onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FreeListingProvisionPage())
              );
            }),
            const SizedBox(height: 18),
            BoldListingCard(onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BoldListingDetailPage())
              );
            }),
            const SizedBox(height: 18),
            PremiumListingCard(onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PremiumListingDetailPage())
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Free Listing Card
class FreeListingCard extends StatelessWidget {
  final VoidCallback onTap;
  const FreeListingCard({required this.onTap, super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sample Business", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("98989 XXXXX", style: TextStyle(fontSize: 17)),
              const SizedBox(height: 4),
              Text("Coimbatore", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(icon: Icon(Icons.call), label: Text("Call"), onPressed: () {}),
                  SizedBox(width: 8),
                  ElevatedButton.icon(icon: Icon(Icons.info_outline), label: Text("Enquiry"), onPressed: () {}),
                  SizedBox(width: 8),
                  IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bold Listing Card
class BoldListingCard extends StatelessWidget {
  final VoidCallback onTap;
  const BoldListingCard({required this.onTap, super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bold Sample Business", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("98989 XXXXX", style: TextStyle(fontSize: 17)),
              const SizedBox(height: 4),
              Text("Chennai", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(icon: Icon(Icons.call), label: Text("Call"), onPressed: () {}),
                  SizedBox(width: 8),
                  ElevatedButton.icon(icon: Icon(Icons.info_outline), label: Text("Enquiry"), onPressed: () {}),
                  SizedBox(width: 8),
                  IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Premium Listing Card
class PremiumListingCard extends StatelessWidget {
  final VoidCallback onTap;
  const PremiumListingCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF6B7), // Light gold
                Color(0xFFD5A800), // Deep gold
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD5A800).withOpacity(0.5),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    "P",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD5A800), // Gold
                    ),
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Premium Sample Biz",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange, // Gold
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.black26,
                              offset: Offset(0, 1),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        "98989 XXXXX",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF8C7000), // Golden brown
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Bangalore",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFC0B283), // Pale gold
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.call, color: Color(0xFFD5A800)),
                            label: Text("Call",
                                style: TextStyle(
                                  color: Color(0xFFD5A800),
                                  fontWeight: FontWeight.bold,
                                )),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shadowColor: Colors.amber,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide(color: Color(0xFFD5A800), width: 1.2),
                              ),
                            ),
                            onPressed: () {},
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.info_outline, color: Color(0xFFD5A800)),
                            label: Text("Enquiry",
                                style: TextStyle(
                                  color: Color(0xFFD5A800),
                                  fontWeight: FontWeight.bold,
                                )),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shadowColor: Colors.amber,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide(color: Color(0xFFD5A800), width: 1.2),
                              ),
                            ),
                            onPressed: () {},
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.favorite, color: Color(0xFFCEAB58), size: 28),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// FREE: Card Tap Opens "provisions over" with Upgrade Button
class FreeListingProvisionPage extends StatelessWidget {
  const FreeListingProvisionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Free Listing")),
      body: Center(
        child: Card(
          elevation: 3,
          margin: EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 46, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text("Free listing provisions over.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Back to order form or upgrade logic
                  },
                  child: Text("Upgrade"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// BOLD: Card Tap Opens Full Digital Visiting Card
class BoldListingDetailPage extends StatelessWidget {
  const BoldListingDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Business Visiting Card")),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text("Bold Sample Business", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("98989 XXXXX", style: TextStyle(fontSize: 18)),
          Text("Chennai", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 24),
          TabBarSection(),
          const SizedBox(height: 14),
          Text("Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("Business activity details displayed here."),
          const SizedBox(height: 14),
          Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("About the business, services, and other information."),
        ],
      ),
    );
  }
}

// A sample TabBar for products (builds a TabBarView with dummy tabs)
class TabBarSection extends StatelessWidget {
  const TabBarSection({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "Product 1"),
              Tab(text: "Product 2"),
              Tab(text: "Product 3"),
            ],
          ),
          Container(
            height: 90,
            child: TabBarView(
              children: [
                Center(child: Text("Product 1 details...")),
                Center(child: Text("Product 2 details...")),
                Center(child: Text("Product 3 details...")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PREMIUM: Card Tap Opens Digital Visiting Card (can expand as needed)
class PremiumListingDetailPage extends StatelessWidget {
  const PremiumListingDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Premium Digital Card")),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Text("P", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ),
              SizedBox(width: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Premium Sample Biz", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  Text("98989 XXXXX", style: TextStyle(fontSize: 18, color: Colors.indigo)),
                  Text("Bangalore", style: TextStyle(fontSize: 16, color: Colors.purple[700])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          TabBarSection(),
          const SizedBox(height: 14),
          Text("Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("Premium business activity goes here."),
          const SizedBox(height: 14),
          Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("Extended information about services, rewards, and more."),
        ],
      ),
    );
  }
}
