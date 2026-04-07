import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:we_chat/core/services/fcm_service.dart';
import '../controllers/chat_controller.dart';
import 'chat/widgets/message_bubble.dart';

class HomePage extends StatefulWidget {
  final String receiverId; // 👈 REQUIRED

  const HomePage({super.key, required this.receiverId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatController controller = ChatController();
  final textCtrl = TextEditingController();
  final supabase = Supabase.instance.client;
  final FCMService fcmService = FCMService();

  @override
  void initState() {
    super.initState();
    fcmService.init(); // ✅ FCM init
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          /// 💬 Messages
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allMessages = snapshot.data!;

                /// 🔥 Filter only this chat
                final messages = allMessages.where((msg) {
                  return (msg['user_id'] == currentUser.id &&
                          msg['receiver_id'] == widget.receiverId) ||
                      (msg['user_id'] == widget.receiverId &&
                          msg['receiver_id'] == currentUser.id);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['user_id'] == currentUser.id;

                    return MessageBubble(
                      message: msg['content'],
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          /// ✏️ Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = textCtrl.text.trim();

                    if (text.isEmpty) return;

                    await controller.sendMessage(
                      text,
                      widget.receiverId, // ✅ REQUIRED
                    );

                    textCtrl.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}