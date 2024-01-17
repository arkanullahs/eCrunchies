class Message {
  final String senderId;
  final String receiverId;
  final String orderId;
  final String message;
  final DateTime timestamp;
  final String content;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.orderId,
    required this.message,
    required this.timestamp,
    required this.content,

  });
}
