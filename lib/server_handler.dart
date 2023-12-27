import 'package:http/http.dart' as http;
import 'dart:convert';

class ServerHandler {
  Future<void> sendOrderData(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.112:3000/api/orders'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> receivedData = jsonDecode(response.body);
      print(receivedData); // Display received order data (for demo purposes)
    } else {
      print('Failed to send order data');
    }
  }
}
