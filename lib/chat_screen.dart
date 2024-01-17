import 'package:flutter/material.dart';
import 'message_model.dart';
import 'chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChatScreen extends StatefulWidget {
  final String restaurantId;
  final String orderId;

  ChatScreen({
    required this.restaurantId,
    required this.orderId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add this line


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Restaurant'),
      ),
      body: Column(
        children: [
          // Your chat messages display area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.restaurantId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs;

                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageData = message.data() as Map<String, dynamic>;
                  var messageText = messageData['content'];
                  var senderId = messageData['senderId'];

                  var messageWidget = MessageWidget(
                    senderId: senderId,
                    content: messageText,
                  );
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          // Your message input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      // Get the current user
                      User? user = FirebaseAuth.instance.currentUser;

                      // Check if the user is signed in
                      if (user != null) {
                        String userId = user.uid;

                        // Replace 'user_id' with the actual user ID
                        await _chatService.sendMessage(
                          userId,
                          widget.restaurantId,
                          widget.orderId,
                          _messageController.text,
                        );

                        _messageController.clear();
                      }
                    }
                  },
                  icon: Icon(Icons.send),
                ),
                IconButton(
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      User? user;
                      await _chatService.sendMessage(
                       'user_id', // Replace 'user_id' with the actual user ID
                      //  User? user = FirebaseAuth.instance.currentUser
                          // Check if the user is signed in
                          //if (user != null) {
                      //  String userId = user.uid;
                        // Now, you can use 'userId' in place of 'user_id' in your code.
                      //}

                        widget.restaurantId,
                        widget.orderId,
                        _messageController.text,
                      );

                      _messageController.clear();
                    }
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

  Future<void> _sendMessage() async {
    var _messageController;
    String content = _messageController.text.trim();
    if (content.isNotEmpty) {
      Message message = Message(
        senderId: 'user_id_here', // Replace with the actual user ID from authentication
        content: content,
        timestamp: DateTime.now(),
        receiverId: '',
        orderId: '',
        message: '',
      );
      final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add this line

      try {
        await _firestore
            .collection('chats')
            .doc('your_document_id_here')
            .set({
          'senderId': message.senderId,
          'content': message.content,
          'timestamp': message.timestamp,
        });


        var _messageController;
        _messageController.clear();
      } catch (e) {
        // Handle any errors if necessary
        print('Error sending message: $e');
      }
    }
  }


class MessageWidget extends StatelessWidget {
  final String senderId;
  final String content;

  MessageWidget({
    required this.senderId,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      alignment: senderId == 'user_id' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: senderId == 'user_id' ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          content,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
