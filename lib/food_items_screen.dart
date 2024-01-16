import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_details_screen.dart';
import 'food_model.dart';
import 'foods_screen.dart';
import 'package:flutter/material.dart';
import 'restaurant_menu_screen.dart'; // Import your
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

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document = documents[index];
                    final String name = document['name'];
                    final double price = document['price'];
                    final String imageUrl = document['imageUrl'];
                    final String description = document['description'];

                    return GestureDetector(
                      onTap: () {
                        // Inside FoodItemsScreen build method
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FoodDetailsScreen(
                                  food: Food(
                                    restaurant: 'Sample Restaurant',
                                    name: name,
                                    price: price,
                                    // Sample price
                                    image: imageUrl,
                                    description: description, // Use the fetched image URL here
                                  ),
                                  restaurantOwnerId: 'yourRestaurantOwnerId', // Pass the required parameter
                                ),
                          ),
                        );
                        child:
                        Container(
                          width: 150,
                          height: 150,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              // Use network image
                              fit: BoxFit.contain,
                            ),
                          ),


                        );
                      }
                    );
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

