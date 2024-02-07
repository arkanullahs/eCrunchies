import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_model.dart';
import 'food_details_screen.dart';
import 'foods_screen.dart';

class FoodItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('items').snapshots(),
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

                // Display only the first 4 items
                final List<DocumentSnapshot> displayedDocuments = documents.take(4).toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayedDocuments.length + 1, // Add 1 for the "More" button
                  itemBuilder: (context, index) {
                    if (index < displayedDocuments.length) {
                      final DocumentSnapshot document = displayedDocuments[index];
                      final String name = document['name'];
                      final double price = document['price'];
                      final String imageUrl = document['imageUrl'];
                      final String description = document['description'];
                      final String restaurant = document['restaurant'];
                      final String restaurantId = document['restaurant'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodDetailsScreen(
                                food: Food(
                                  name: name,
                                  price: price,
                                  image: imageUrl,
                                  description: description,
                                  restaurantId: restaurantId,
                                  restaurant: restaurant,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // If the image is fully loaded, display it
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(), // Display a loading indicator while the image is loading
                                    );
                                  }
                                },
                              ),
                              Positioned(
                                bottom: 14,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(0),
                                  color: Colors.black.withOpacity(0.5),
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Display the "More" button
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllFoodItemsScreen(documents: documents),
                            ),
                          );
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AllFoodItemsScreen extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  AllFoodItemsScreen({required this.documents});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Available Items'),
      ),
      body: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final DocumentSnapshot document = documents[index];
          final String name = document['name'];
          final double price = document['price'];
          final String imageUrl = document['imageUrl'];
          final String description = document['description'];
          final String restaurant = document['restaurant'];
          final String restaurantId = document['restaurant'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailsScreen(
                    food: Food(
                      name: name,
                      price: price,
                      image: imageUrl,
                      description: description,
                      restaurantId: restaurantId,
                      restaurant: restaurant,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              width: 150,
              height: 150,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // If the image is fully loaded, display it
                      } else {
                        return Center(
                          child: CircularProgressIndicator(), // Display a loading indicator while the image is loading
                        );
                      }
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 00,
                    child: Container(
                      padding: EdgeInsets.all(0),
                      color: Colors.black.withOpacity(0.3),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
