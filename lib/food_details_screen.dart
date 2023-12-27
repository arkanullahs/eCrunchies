import 'package:flutter/material.dart';
import 'food_model.dart';
import 'server_handler.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Food food;
  final ServerHandler serverHandler = ServerHandler();

  FoodDetailsScreen({
    required this.food,
  });

  @override
  _FoodDetailsScreenState createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final TextEditingController _quantityController = TextEditingController();
  bool _isValid = true;

  Future<void> sendOrderData(int quantity) async {
    Map<String, dynamic> orderData = {
      'foodName': widget.food.name,
      'price': widget.food.price,
      'quantity': quantity,
      // Add other order details as needed
    };

    await widget.serverHandler.sendOrderData(orderData);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> restaurantImages = [
      'assets/restaurant_0.png', // Restaurant 0 image
      'assets/restaurant_1.png', // Restaurant 1 image
      'assets/restaurant_2.png', // Restaurant 2 image
      // Add more restaurant images here as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${widget.food.name}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(widget.food.image),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.food.name,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '\$${widget.food.price}',
                style: TextStyle(fontSize: 22, color: Colors.redAccent),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Indulge in the tantalizing flavors of our Smokey Maple Bacon Bliss Burger. This culinary masterpiece features a juicy, flame-grilled beef patty topped with crispy maple-glazed bacon, smoky gouda cheese, and a dollop of zesty barbecue aioli. All sandwiched between a toasted brioche bun for the perfect blend of sweet, savory, and smoky sensations. Elevate your burger experience with this mouthwatering creation thats sure to leave you craving more.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 100,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isValid ? Colors.grey[400]! : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isValid = int.tryParse(value) != null && int.parse(value) > 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                    int quantity = int.tryParse(_quantityController.text) ?? 0;
                    sendOrderData(quantity);
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    primary: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'Place Order',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
