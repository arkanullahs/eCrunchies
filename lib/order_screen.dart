import 'package:flutter/material.dart';
import 'food_model.dart'; // Import your Food model here

class OrderScreen extends StatelessWidget {
  final List<Food> foods = [
    Food(restaurant: 'Restaurant A', name: 'Pizza', price: 9.99, image: 'assets/foods/food_0.png'),
    Food(restaurant: 'Restaurant A', name: 'Burger', price: 7.99, image: 'assets/foods/food_1.png'),
    Food(restaurant: 'Restaurant B', name: 'Sushi', price: 12.99, image: 'assets/foods/food_2.png'),
    // Add more food items as needed
  ];

  List<String> restaurantImages = [
    'assets/restaurants/restaurant_0.png', // Restaurant 0 image
    'assets/restaurants/restaurant_1.png', // Restaurant 1 image
    'assets/restaurants/restaurant_2.png', // Restaurant 2 image
    // Add more restaurant images here as needed
  ];

  List<String> itemImages = [
    'assets/items/item_0.png', // Item 0 image
    'assets/items/item_1.png', // Item 1 image
    'assets/items/item_2.png', // Item 2 image
    // Add more item images here as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Food'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Carousel with Food Images
            SizedBox(height: 10),
            Container(
              height: 220,
              child: PageView.builder(
                itemCount: foods.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle food item tap
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
                        child: Image.asset(
                          foods[index].image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Section 2: Items
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
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle item tap
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          itemImages[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Section 3: Discover
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Discover',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: restaurantImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle restaurant tap
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: AssetImage(restaurantImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

