import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'login_screen.dart';
import 'order_screen.dart';
//import 'restaurant_dashboard.dart';
import 'user_type_selection.dart';
import 'signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCrunchies',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => UserTypeSelection(),
        '/home': (context) => OrderScreen(),
        // '/restaurantDashboard': (context) => RestaurantDashboard(),
        '/orderScreen': (context) => OrderScreen(),
        '/login': (context) => LoginScreen(userType: ''),
        '/signup': (context) => SignupScreen(userType: ''),
      },
    );
  }
}
