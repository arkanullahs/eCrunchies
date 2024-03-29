import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowOrder {
  Widget buildOrderList(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Order List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timeSent', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final orderData = snapshot.data!.docs;

          if (orderData.isEmpty) {
            return Center(
              child: Text(
                'No orders available.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            );
          }

          // Assuming you want to display stats on the main page, fetch stats here
          int totalOrders = orderData.length;
          double totalAmount = orderData.fold(
            0.0,
                (previous, current) {
              double price = current['price'] ?? 0.0;
              int quantity = current['quantity'] ?? 1;
              return previous + (price * quantity);
            },
          );

          // Now, you can use these stats in the main page
          // ...

          return ListView.builder(
            itemCount: orderData.length,
            itemBuilder: (context, index) {
              final foodName = orderData[index]['foodName'];
              final quantity = orderData[index]['quantity'];
              final price = orderData[index]['price'];
              final timeSent =
              (orderData[index]['timeSent'] as Timestamp).toDate();

              return Card(
                elevation: 2,
                margin: EdgeInsets.all(7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(
                    'Food: $foodName',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity: $quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      Text(
                        'Price: $price',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      Text(
                        'Time Sent: ${_formatDateTime(timeSent)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  // New method to fetch statistics
  Future<Map<String, dynamic>> fetchOrderStatistics() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('orders').get();

    int totalOrders = querySnapshot.docs.length;
    double totalAmount = querySnapshot.docs.fold(
      0.0,
          (previous, current) {
        double price = current['price'] ?? 0.0;
        int quantity = current['quantity'] ?? 1;
        return previous + (price * quantity);
      },
    );

    return {
      'totalOrders': totalOrders,
      'totalAmount': totalAmount,
    };
  }
}
