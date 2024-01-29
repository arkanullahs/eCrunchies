import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_chat_screen.dart';
import 'restaurant_dash_show_items.dart';
import 'restaurant_dash_show_order_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'add_offer_page.dart'; // Import the AddOfferPage
import 'chat_screen.dart'; // Import your chat screen
import 'package:loading_overlay/loading_overlay.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RestaurantDashboard extends StatefulWidget {
  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  bool isLoading = false;
  final ShowOrder _showOrder = ShowOrder();
  late String imageUrl = '';
  final picker = ImagePicker();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final nameController2 = TextEditingController();
  final priceController2 = TextEditingController();
  final descriptionController2 = TextEditingController();
  int val = 0;

  int itemCount = 0; // To maintain the count of items
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String restaurantName = '';
  late List<String> orderIds = [];

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
    fetchRestaurantNameAndOrderIds();
    fetchItemCount(); // Fetch the current item count on initialization
  }

  Future<void> fetchRestaurantNameAndOrderIds() async {
    await fetchRestaurantName();
    await fetchOrderIds();
  }

  Future<void> fetchRestaurantName() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String userEmail = user.email ?? '';

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('users').where('email', isEqualTo: userEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          restaurantName = querySnapshot.docs.first.get('restaurantName');
        });
      }
    }
    print(restaurantName);
  }

  Future<void> fetchOrderIds() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await _firestore.collection('orders').where('restaurantName', isEqualTo: restaurantName).get();

    List<String> fetchedOrderIds = querySnapshot.docs.map((doc) => doc.id).toList();

    setState(() {
      orderIds = fetchedOrderIds;
    });
  }


  Future<void> addNewItem() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });

      try {
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
                      'restaurant': restaurantName,
                    });

                    setState(() {
                      imageUrl = '';
                    });

                    nameController.clear();
                    priceController.clear();
                    descriptionController.clear();

                    await fetchItemCount(); // Update the itemCount after adding a new item

                    Fluttertoast.showToast(
                      msg: 'Item added successfully!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );

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
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
  Widget build(BuildContext context) { return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
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
    /*SpeedDialChild(
            child: Icon(Icons.local_offer_outlined),
            label: 'Message',
            onTap: () async {
              // Fetch the current user's email
              //String userEmail = 'user0@gmail.com'; // Replace with actual user email retrieval logic

              // Open the chat screen for the current user's email
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderChatScreen(
                    restaurantId: restaurantName, // Use the user's email as the restaurant ID
                    orderId: 'dummy', // You can provide an order ID if needed
                  ),
                ),
              );
            },
          ),*/
          SpeedDialChild(
            child: Icon(Icons.message_rounded),
            label: 'Messages',
            onTap: () async {
              // Fetch orderIds that match the restaurantName
              QuerySnapshot<Map<String, dynamic>> ordersSnapshot = await FirebaseFirestore.instance
                  .collection('orders')
                  .where('restaurantName', isEqualTo: restaurantName)
                  .get();
              print(restaurantName);

              List<String> orderIds = ordersSnapshot.docs.map((doc) => doc.id).toList();

              // Show a dialog with a list of orderIds
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FutureBuilder(
                    future: Future.delayed(Duration(seconds: 2)), // Simulating a delay, replace it with your actual data fetching logic
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Return a loading indicator while data is being fetched
                        return AlertDialog(
                          content: Container(
                            width: 5,
                            height: 35,// Adjust the width as needed
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      } else {
                        // Data has been loaded, display the dialog
                        return AlertDialog(
                          title: Text('Select an Order'),
                          content: Container(
                            width: double.maxFinite,
                            child: ListView.builder(
                              itemCount: orderIds.length,
                              itemBuilder: (context, index) {
                                String orderId = orderIds[index];
                                print("dummy:$orderId");
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        'Order ID: $orderId',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OrderChatScreen(
                                              restaurantId: restaurantName,
                                              orderId: orderId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16), // Adjust the radius as needed
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.deepOrangeAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              );
            },
          ),


        ],
      ),
    //);
 // }

      body: Center(
        child: Text('WELCOME $restaurantName'),
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
            ///////////////////
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
    )
  );
  }
}

