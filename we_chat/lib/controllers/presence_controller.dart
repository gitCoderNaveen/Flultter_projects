import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceController {
  final supabase = Supabase.instance.client;

  void trackOnline() {
    final user = supabase.auth.currentUser;

    final channel = supabase.channel('online');

    channel.subscribe((status, [err]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        channel.track({
          'user_id': user!.id,
          'online_at': DateTime.now().toIso8601String()
        });
      }
    });
  }
}