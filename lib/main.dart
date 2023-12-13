import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import your LoginScreen file here

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Set LoginScreen as the home
    );
  }
}
