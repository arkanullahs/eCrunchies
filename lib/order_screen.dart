import 'package:flutter/material.dart';
import 'food_details_screen.dart';
import 'food_items_screen.dart';
import 'discover_screen.dart';
import 'foods_screen.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Restaurants'),
        actions: [
          GestureDetector(
            onTap: () {
              // Implement search functionality
              print('Search button tapped!');
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
            //Padding(
              //padding: const EdgeInsets.all(16.0),
              //child: Text(
                //'Discover',
               // style: TextStyle(
                 // fontWeight: FontWeight.bold,
                 // fontSize: 18,
                //),
              //),
            //),
            DiscoverScreen(),
          ],
        ),
      ),
    );
  }
}
