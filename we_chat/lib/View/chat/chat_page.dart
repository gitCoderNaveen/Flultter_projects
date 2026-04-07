import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/chat_controller.dart';

class ChatPage extends StatefulWidget {
  final String receiverId; // 👈 IMPORTANT

  const ChatPage({super.key, required this.receiverId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController controller = ChatController();
  final TextEditingController textController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

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
                  return (msg['user_id'] == currentUser!.id &&
                          msg['receiver_id'] == widget.receiverId) ||
                      (msg['user_id'] == widget.receiverId &&
                          msg['receiver_id'] == currentUser.id);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['user_id'] == currentUser!.id;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['content'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ✏️ Input box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = textController.text.trim();

                    if (text.isEmpty) return;

                    await controller.sendMessage(
                      text,
                      widget.receiverId, // 👈 REQUIRED
                    );

                    textController.clear();
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