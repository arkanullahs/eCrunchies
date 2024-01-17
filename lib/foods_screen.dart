import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'food_details_screen.dart';
//import 'food_model.dart';
import 'food_details_screen.dart';
import 'foods_screen.dart';


class FoodsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('foods').snapshots(),
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

                return PageView.builder(
                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final DocumentSnapshot document = documents[index];
                    final String restaurant = document['restaurant'];
                    final String name = document['name'];
                    final double price = document['price'];
                    final String imageUrl = document['image'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailsScreen(
                              food: Food(
                                restaurant: restaurant,
                                name: name,
                                price: price,
                                image: imageUrl,
                                description: 'Will Fix That Later-Saad', restaurantId: '',
                              ),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        shadowColor: Colors.black,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
