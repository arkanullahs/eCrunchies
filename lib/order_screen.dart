import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food_details_screen.dart';
import 'food_items_screen.dart';
import 'discover_screen.dart';
import 'foods_screen.dart';
import 'restaurant_menu_screen.dart';
import 'order_chat_screen.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Restaurants'),
        actions: [
          GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: RestaurantSearchDelegate(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.search,
                size: 32,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.logout,
                size: 32,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            FoodsScreen(),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            FoodItemsScreen(),
            DiscoverScreen(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMessages();
        },
        tooltip: 'Show Messages',
        child:
        Icon(Icons.message),
      ),
    );
  }

  void _showMessages() async {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    CollectionReference orderChatsCollection =
    FirebaseFirestore.instance.collection('order_chats');

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await orderChatsCollection
          .where('sender', isEqualTo: currentUserEmail)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      List<String> orderIds = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
      in querySnapshot.docs) {
        String orderId = document['orderId'];
        orderIds.add(orderId);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select an Order'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: orderIds.length,
                itemBuilder: (context, index) {
                  String orderId = orderIds[index];

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
                                restaurantId: '', // Provide the restaurant ID here
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
              borderRadius: BorderRadius.circular(16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error fetching order chats: $error');
    }
  }





}

class RestaurantSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResults(searchQuery: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SearchResults(searchQuery: query);
  }
}

class SearchResults extends StatelessWidget {
  final String searchQuery;

  SearchResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: searchQuery + 'z')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot document = documents[index];
            final String name = document['name'];
            final String imageUrl = document['imageUrl'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantMenuScreen(restaurantName: name),
                  ),
                );
              },
              child: RestaurantCard(
                imageUrl: imageUrl,
                name: name,
              ),
            );
          },
        );
      },
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  RestaurantCard({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
