import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchLogsPage extends StatelessWidget {
  const SearchLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Activity')),
      body: FutureBuilder(
        future: supabase
            .from('search_logs')
            .select()
            .eq('user_id', user!.id)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data as List;

          if (logs.isEmpty) {
            return const Center(child: Text('No searches yet'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (_, i) {
              final log = logs[i];
              return ListTile(
                leading: const Icon(Icons.search),
                title: Text(log['query']),
                subtitle: Text('Filter: ${log['filter']}'),
                trailing: Text(
                  log['created_at'].toString().split('T').first,
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
