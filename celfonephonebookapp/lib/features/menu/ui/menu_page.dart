import 'package:celfonephonebookapp/features/analytics/payments_page.dart';
import 'package:celfonephonebookapp/features/analytics/search_logs_page.dart';
import 'package:celfonephonebookapp/features/analytics/user_sessions_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const _HeaderRow(collapsed: true)),
      body: ListView(
        children: [
          /// Profile (only if logged in)
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () => context.push('/profile'),
            ),

          /// Subscriptions (optional: you may keep public or gated)
          // ListTile(
          //   leading: const Icon(Icons.workspace_premium),
          //   title: const Text('Subscriptions'),
          //   onTap: () => context.push('/subscription'),
          // ),
          const Divider(),

          /// 🔑 AUTH ACTION (LOGIN / LOGOUT)
          user == null
              ? ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login'),
                  onTap: () => context.push('/login'),
                )
              : ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout'),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();

                    if (!context.mounted) return;
                    context.go('/home');
                  },
                ),

          // Analytics
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Reverse Number Finder'),
            onTap: () => context.push('/reverse_number_finder'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Subscription Plans'),
            onTap: () => context.push('/subscription'),
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Combo Offers'),
            onTap: () => context.push('/combo_offers'),
          ),
          // ListTile(
          //   leading: const Icon(Icons.workspace_premium),
          //   title: const Text('Subscription'),
          //   onTap: () => context.push('/subscription'),
          // ),
          // ListTile(
          //   leading: const Icon(Icons.trending_up),
          //   title: const Text('Leads & Views'),
          //   onTap: () => context.push('/user_sessions'),
          // ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final bool collapsed;
  const _HeaderRow({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final color = collapsed ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: "Cel",
                            style: TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text: "fon",
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(
                            text: " Book",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    "Connects For Growth",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
