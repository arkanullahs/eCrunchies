import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_dash_show_items.dart';
import 'restaurant_dash_show_order_list.dart';
//import 'add_offer_page.dart'; // Import the AddOfferPage
import 'chat_screen.dart'; // Import your chat screen

class RestaurantDashboard extends StatefulWidget {
  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  final ShowOrder _showOrder = ShowOrder();
  late String imageUrl = '';
  final picker = ImagePicker();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final nameController2 = TextEditingController();
  final priceController2 = TextEditingController();
  final descriptionController2 = TextEditingController();
  int val=0;

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
                  double price =
                      double.tryParse(priceController.text) ?? 0.0;
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
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepOrangeAccent,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Dashboard'),
      ),
      floatingActionButton: SpeedDial(
        // Replaces the FloatingActionButton with a PopupMenuButton
        //icon: Icons.add,
        animatedIcon: AnimatedIcons.menu_arrow,
        children: [
      SpeedDialChild(
      child: Icon(Icons.add_circle_outline),
      label: 'Add New Item',
      onTap: () async {
        await addNewItem();

      } ),
      SpeedDialChild(
      child: Icon(Icons.local_offer_outlined),
      label: 'Add Offer',
          onTap: () async {
            //await addNewOffer();

          }  ),
        ],
      ),


      body: Center(
        child: Text('WELCOME restaurantOwner'),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.show_chart_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowOrder().buildOrderList(context),
                  ),
                );
              },
            ),
            /*IconButton(
              icon: Icon(Icons.message),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(restaurantId: 'your_restaurant_id_here', orderId: '',),
                  ),
                );
              },
            ),*/
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShowItems()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

