// restaurant_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'food_details_screen.dart';
//import 'food_model.dart';
//import 'food_details_screen.dart';

class RestaurantMenuScreen extends StatelessWidget {
  final String restaurantName;

  RestaurantMenuScreen({required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$restaurantName Menu'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items')
            .where('restaurant', isEqualTo: restaurantName)
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
              final String foodName = document['name'];
              final double price = document['price'];
              final String imageUrl = document['imageUrl'];
              final String description = document['description'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailsScreen(
                        food: Food(
                          restaurant: restaurantName,
                          name: foodName,
                          price: price,
                          image: imageUrl,
                          description: description, restaurantId: '',
                        ),
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(foodName),
                  subtitle: Text('\$$price'),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
