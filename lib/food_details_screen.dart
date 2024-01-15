import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Food food;

  FoodDetailsScreen({
    required this.food,
  });

  @override
  _FoodDetailsScreenState createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final TextEditingController _quantityController = TextEditingController();
  bool _isValid = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendOrderData(int quantity) async {
    Map<String, dynamic> orderData = {
      'foodName': widget.food.name,
      'price': widget.food.price,
      'quantity': quantity,
      'timeSent': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection('orders').add(orderData);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    image: NetworkImage(widget.food.image),
                    fit: BoxFit.contain,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      spreadRadius: 6,
                      blurRadius: 50,
                      offset: Offset(0, 8),
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
                  widget.food.description,
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
                    // **************************************************Uncomment the following lines if you want to navigate to ChatScreen
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => ChatScreen(restaurantOwnerId: 'yourActualRestaurantOwnerId'),
                       ),
                     );
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
