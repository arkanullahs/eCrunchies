import 'package:flutter/material.dart';
import 'food_model.dart';
//import 'chat_screen.dart';
import 'order_chat_screen.dart';
import 'food_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderConfirmationPage extends StatefulWidget {
  final String orderId;
  final Food food;
  final int quantity;
  final String userEmail;
  final String restaurant;
  final String messageId;

  OrderConfirmationPage({
    required this.orderId,
    required this.food,
    required this.quantity,
    required this.restaurant,
    required this.userEmail,
    required this.messageId,
    req
  });

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Thanks for your order!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Card(
                elevation: 8, // Increased elevation for a more modern look
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Food: ${widget.food.name}'),
                      SizedBox(height: 10),
                      Image.network(
                        widget.food.image,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 10),
                      Text('Quantity: ${widget.quantity}'),
                      SizedBox(height: 10),
                      Text(
                        'Total Price: \$${(widget.food.price * widget.quantity).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ScaleTransition(
                scale: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {


                    Navigator.push(

                      context,
                      MaterialPageRoute(

                        builder: (context) => OrderChatScreen(

                          restaurantId: widget.food.restaurantId,
                          orderId: widget.orderId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.primary,
                    elevation: 10, // Increased elevation for a more prominent button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'Chat with Restaurant',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
