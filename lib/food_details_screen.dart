import 'package:flutter/material.dart';
import 'food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class Food {
  final String name;
  final double price;
  final String restaurantId; // Add this property
  final String image;
  final String description;

  Food({
    required this.name,
    required this.price,
    required this.restaurantId,
    required this.image,
    required this.description, required String restaurant,
  });
}

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
      'restaurantId':widget.food.restaurantId,
    };

    try {
      DocumentReference orderRef =
      await _firestore.collection('orders').add(orderData);
      String orderId = orderRef.id;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            restaurantId: widget.food.restaurantId,
            orderId: orderId,
          ),
        ),
      );
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
                          _isValid =
                              int.tryParse(value) != null && int.parse(value) > 0;
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
                      ? () async {
                    int quantity =
                        int.tryParse(_quantityController.text) ?? 0;
                    await sendOrderData(quantity);

                    // Open the chat screen after placing the order
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          restaurantId: widget.food.restaurantId,
                          orderId: '',
                        ),
                      ),
                    );*/
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
