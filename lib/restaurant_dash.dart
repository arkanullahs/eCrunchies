import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'show_items.dart';

class RestaurantDashboard extends StatefulWidget {
  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  late String imageUrl = '';
  final picker = ImagePicker();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController=TextEditingController();

  int itemCount = 0; // To maintain the count of items

  Future<void> fetchItemCount() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('items').get();

    setState(() {
      itemCount = querySnapshot.docs.length;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchItemCount(); // Fetch the current item count on initialization
  }

  Future<void> addNewItem() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String fileName = pickedFile.path.split('/').last;

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('items/$fileName');

      await ref.putFile(new File(pickedFile.path));
      imageUrl = await ref.getDownloadURL();

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Name, Price, and Description'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  String name = nameController.text;
                  double price = double.tryParse(priceController.text) ?? 0.0;
                  String description = descriptionController.text;

                  // Add a new document without passing a document ID
                  await FirebaseFirestore.instance.collection('items').add({
                    'description': description,
                    'name': name,
                    'price': price,
                    'imageUrl': imageUrl,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  setState(() {
                    imageUrl = '';
                  });

                  nameController.clear();
                  priceController.clear();
                  descriptionController.clear();

                  await fetchItemCount(); // Update the itemCount after adding a new item

                  Navigator.of(context).pop(); // Dismiss the dialog after adding the item
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    } else {
      print('No image selected.');
    }
  }



  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Restaurant Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Current Orders'),
              Tab(text: 'Actions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First Tab: Order Data
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('timeSent', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final orderData = snapshot.data!.docs;

                if (orderData.isEmpty) {
                  return Center(child: Text('No orders available.'));
                }

                return ListView.builder(
                  itemCount: orderData.length,
                  itemBuilder: (context, index) {
                    final foodName = orderData[index]['foodName'];
                    final quantity = orderData[index]['quantity'];
                    final price = orderData[index]['price'];
                    final timeSent =
                    (orderData[index]['timeSent'] as Timestamp)
                        .toDate(); // Convert Timestamp to DateTime

                    return ListTile(
                      title: Text('Food: $foodName'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: $quantity'),
                          Text('Price: $price'),
                          Text('Time Sent: ${_formatDateTime(timeSent)}'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // Second Tab: Buttons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: addNewItem,
                    child: Text('Add New Item'),
                  ),
                  SizedBox(height: 20),
                  imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    height: 200,
                    width: 200,
                  )
                      : Container(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShowItems()),
                      );
                    },
                    child: Text('Show Added Items'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Format DateTime to a human-readable format
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
