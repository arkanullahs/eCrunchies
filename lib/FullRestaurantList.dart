import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_details_screen.dart';
import 'food_model.dart';
import 'discover_screen.dart';

class FullRestaurantList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Restaurants'),
      ),
      body: FullRestaurantListScreen(),
    );
  }
}

class FullRestaurantListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
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
                    builder: (context) => FoodDetailsScreen(
                      food: Food(
                        restaurant: name,
                        name: 'Sample Food',
                        price: 9.99,
                        image: imageUrl,
                      ),
                    ),
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
