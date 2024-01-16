/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'food_items_screen.dart'; // Import your screens
import 'firebase_options.dart';
import 'login_screen.dart';
import 'order_screen.dart';
import 'restaurant_dash.dart';
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
      /*
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => UserTypeSelection(),
        '/home': (context) => OrderScreen(restaurantOwnerId: '',), // No need to pass restaurantOwnerId here
        '/restaurantDashboard': (context) => RestaurantDashboard(),
        '/orderScreen': (context) => OrderScreen(restaurantOwnerId: '',), // No need to pass restaurantOwnerId here
        '/login': (context) => LoginScreen(userType: ''),
        '/signup': (context) => SignupScreen(userType: ''),
      },
    );
  }
}

*/
      home: UserTypeSelection(),
    );
  }
}

class UserTypeSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User Type'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodItemsScreen()),
                );
              },
              child: Text('Browse Restaurants'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'login_screen.dart';
import 'order_screen.dart';
import 'restaurant_dash.dart';
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
        '/home': (context) => OrderScreen(restaurantOwnerId: '',), // No need to pass restaurantOwnerId here
        '/restaurantDashboard': (context) => RestaurantDashboard(),
        '/orderScreen': (context) => OrderScreen(restaurantOwnerId: '',), // No need to pass restaurantOwnerId here
        '/login': (context) => LoginScreen(userType: ''),
        '/signup': (context) => SignupScreen(userType: ''),
      },
    );
  }
}
