import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String senderId, String receiverId, String orderId, String message) async {
    await _firestore.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'orderId': orderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
