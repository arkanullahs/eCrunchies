import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'order_screen.dart'; // Import the OrderScreen file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCrunchies',
      theme: ThemeData(
        primarySwatch: Colors.orange, // Choose a primary color swatch
        //accentColor: Colors.orange, // Set accent color to orange
      ),
      debugShowCheckedModeBanner: false, // Hide debug banner
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => OrderScreen(),
      },
    );
  }
}
