import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Added Items'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.network(
                    items[index]['imageUrl'],
                    height: 50,
                    width: 50,
                  ),
                  title: Text(
                    items[index]['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '\$${_formatPrice(items[index]['price'])}',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _deleteItem(context, items[index].id);
                    },
                    child: Text('Delete'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatPrice(dynamic price) {
    return '$price';
  }




  Future<void> _deleteItem(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(documentId).delete();
    } catch (e) {
      print('Error deleting item: $e');
    }
  }
}
