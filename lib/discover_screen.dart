
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_details_screen.dart';
import 'food_model.dart';
import 'FullRestaurantList.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_details_screen.dart';
import 'food_model.dart';


class DiscoverScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Restaurants',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        LimitedRestaurantList(), // Display a limited list of restaurants
      ],
    );
  }
}



class LimitedRestaurantList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('restaurants').limit(4).snapshots(),
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
            scrollDirection: Axis.horizontal,
            itemCount: documents.length + 1, // Add 1 for the "More" button
            itemBuilder: (context, index) {
              if (index < documents.length) {

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
              } else {
                // Display the "More" button
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullRestaurantList(),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        'More',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }, // Correct placement of the closing parenthesis
      ),
    );
  }
}


class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  RestaurantCard({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.black.withOpacity(0.5),
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



