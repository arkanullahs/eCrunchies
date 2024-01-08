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
              fontFamily: 'SF Pro Display'),
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
                    fontFamily: 'SF Pro Display'),
              ),
            );
          }

          return ListView.builder(
            itemCount: orderData.length,
            itemBuilder: (context, index) {
              final foodName = orderData[index]['foodName'];
              final quantity = orderData[index]['quantity'];
              final price = orderData[index]['price'];
              final timeSent =
              (orderData[index]['timeSent'] as Timestamp).toDate();

              return Card(
                elevation: 5,
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    'Food: $foodName',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display'),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity: $quantity',
                        style: TextStyle(
                            fontSize: 16, fontFamily: 'SF Pro Display'),
                      ),
                      Text(
                        'Price: $price',
                        style: TextStyle(
                            fontSize: 16, fontFamily: 'SF Pro Display'),
                      ),
                      Text(
                        'Time Sent: ${_formatDateTime(timeSent)}',
                        style: TextStyle(
                            fontSize: 16, fontFamily: 'SF Pro Display'),
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
}
