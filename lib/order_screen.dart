import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_details_screen.dart';
import 'food_items_screen.dart';
import 'discover_screen.dart';
import 'foods_screen.dart';
import 'restaurant_menu_screen.dart';
import 'chat_screen.dart'; // Import the chat screen

class OrderScreen extends StatefulWidget {
  // Add the restaurantOwnerId parameter to pass to the ChatScreen
  final String restaurantOwnerId;

  OrderScreen({required this.restaurantOwnerId});

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
                delegate: RestaurantSearchDelegate(), // Use custom search delegate
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
              Navigator.pushReplacementNamed(context, '/'); // Navigate to login screen
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.logout, // Use a logout icon here
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
          /////////////////  //  a button to place an order
          /*  ElevatedButton(
              onPressed: () {
                // Perform order logic

                // Now, navigate to the ChatScreen after placing the order
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(restaurantOwnerId: widget.restaurantOwnerId),
                  ),
                );
              },
             // child: Text('Place Order'),
            ),*/
            FoodsScreen(), // Food page view
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            FoodItemsScreen(),
            DiscoverScreen(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Replace 'restaurantOwnerId' with the actual ID of the restaurant owner
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(restaurantOwnerId: 'restaurantOwnerId'),
                  ),
                );
              },
              child: Text('Chat with Restaurant Owner'),
            ),
          ],
        ),
      ),
    );
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
      stream: FirebaseFirestore.instance.collection('restaurants')
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
