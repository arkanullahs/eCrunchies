import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String restaurantOwnerId;

  ChatScreen({required this.restaurantOwnerId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Restaurant Owner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.restaurantOwnerId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = (snapshot.data as QuerySnapshot<Map<String, dynamic>>?)?.docs ?? [];

                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageText = message['text'];
                  var messageSender = message['sender'];

                  var messageWidget = MessageWidget(
                    sender: messageSender,
                    text: messageText,
                  );
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  children: messageWidgets,
                );
              },
            ),
          ),
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
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    var messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.restaurantOwnerId)
          .collection('messages')
          .add({
        'text': messageText,
        'sender': 'user', // You can customize sender information
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;

  MessageWidget({required this.sender, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: sender == 'user' ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: sender == 'user' ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
