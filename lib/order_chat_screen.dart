import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderChatScreen extends StatefulWidget {
  final String restaurantId; // The restaurant ID to send messages to
  final String orderId; // The order ID to tie messages to

  OrderChatScreen({
    required this.restaurantId,
    required this.orderId,
  });

  @override
  _OrderChatScreenState createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('order_chats')
                  .doc(widget.orderId) // Use the order ID as document ID
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
                  var messageText = messageData['message'];
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
                      User? user = _auth.currentUser;

                      if (user != null) {
                        String userId = user.uid;

                        await _firestore
                            .collection('order_chats')
                            .doc(widget.orderId)
                            .collection('messages')
                            .add({
                          'senderId': userId,
                          'message': _messageController.text,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        _messageController.clear();
                      }
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
      alignment:
      senderId == FirebaseAuth.instance.currentUser?.uid
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: senderId == FirebaseAuth.instance.currentUser?.uid
              ? Colors.blue
              : Colors.grey,
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
