import 'package:supabase_flutter/supabase_flutter.dart';

class ChatController {
  final supabase = Supabase.instance.client;

  /// 🔥 Send Message + Trigger Notification
  Future<void> sendMessage(String content, String receiverId) async {
    final user = supabase.auth.currentUser;

    if (user == null || content.trim().isEmpty) return;

    /// 1️⃣ Insert message
    await supabase.from('messages').insert({
      'user_id': user.id,
      'receiver_id': receiverId,
      'content': content,
    });

    /// 2️⃣ Get receiver FCM token
    final res = await supabase
        .from('msg_profiles')
        .select('fcm_token')
        .eq('id', receiverId)
        .maybeSingle();

    final token = res?['fcm_token'];

    if (token == null) return;

    /// 3️⃣ Call Edge Function
    await supabase.functions.invoke(
      'send-notification',
      body: {
        'token': token,
        'title': 'New Message',
        'body': content,
      },
    );
  }

  /// 📡 Real-time messages
  Stream<List<Map<String, dynamic>>> getMessages() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at');
  }
}