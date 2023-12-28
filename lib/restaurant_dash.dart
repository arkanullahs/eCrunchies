import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RestaurantDashboard extends StatefulWidget {
  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  List<dynamic> orders = []; // Store received orders
  late Timer _timer; // Timer instance for periodic updates

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Fetch orders when the screen initializes

    // Start a periodic timer to update orders every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchOrders();
    });
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    try {
      // Make an HTTP GET request to fetch orders from the server
      var response = await http.get(Uri.parse('http://saadserver.eastasia.cloudapp.azure.com:3000/api/orders'));

      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body); // Update orders list with fetched data
        });
      } else {
        print('Failed to fetch orders');
      }
    } catch (error) {
      print('Error fetching orders: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: fetchOrders, // Trigger the fetchOrders function on button press
              child: Text('Update Orders'),
            ),
            SizedBox(height: 20),
            Text(
              'Received Orders:',
              style: TextStyle(fontSize: 24),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  // Display orders in a list or other UI as needed
                  return ListTile(
                    title: Text('Food: ${orders[index]['foodName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${orders[index]['quantity']}'),
                        Text('Price: \$${orders[index]['price']}'),
                      ],
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
