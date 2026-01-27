import 'package:celfonephonebookapp/features/analytics/payments_page.dart';
import 'package:celfonephonebookapp/features/analytics/search_logs_page.dart';
import 'package:celfonephonebookapp/features/analytics/subscriptions_page.dart';
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
      appBar: AppBar(title: const Text('Menu')),
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
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: const Text('Subscriptions'),
            onTap: () => context.push('/subscription'),
          ),

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
            leading: const Icon(Icons.analytics),
            title: const Text('Search Analytics'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchLogsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payments'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: const Text('Subscription'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Leads & Views'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserSessionsPage()),
            ),
          ),
        ],
      ),
    );
  }
}
