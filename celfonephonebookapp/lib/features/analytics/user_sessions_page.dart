import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSessionsPage extends StatelessWidget {
  const UserSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text('My Leads & Views')),
      body: FutureBuilder(
        future: supabase
            .from('user_session')
            .select()
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data as List;

          if (sessions.isEmpty) {
            return const Center(child: Text('No activity found'));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (_, i) {
              final s = sessions[i];
              return ListTile(
                leading: Icon(
                  s['action'] == 'call'
                      ? Icons.call
                      : s['action'] == 'enquiry'
                      ? Icons.message
                      : Icons.visibility,
                ),
                title: Text('Action: ${s['action']}'),
                subtitle: Text('Profile: ${s['profile_id']}'),
                trailing: Text(
                  s['created_at'].toString().split('T').first,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
