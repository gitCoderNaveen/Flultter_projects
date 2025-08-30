import 'package:celfonephonebookapp/screens/admin_panel_page.dart';
import 'package:celfonephonebookapp/screens/profile_page.dart';
import 'package:flutter/material.dart';
import './signup.dart';
import './signin.dart';
import 'homepage_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? displayName; // business_name or person_name
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final cachedUserName = prefs.getString('username'); // Check username key

    setState(() {
      displayName = cachedUserName;
      _isLoading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the favorites first
      final favorites = prefs.getStringList('favorites_') ?? [];

      // Clear everything
      await prefs.clear();

      // Restore favorites
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
          // Profile header
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

          // Settings Options
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
                      content: const Text("You need to log in to access Profile Settings."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SigninPage()),
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

          // Admin Panel
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
                      content: const Text("You must log in to access the Admin Panel."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SigninPage()),
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

          Card(
            child: ListTile(
              title: const Text("Notification Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to Notification Settings Page
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
