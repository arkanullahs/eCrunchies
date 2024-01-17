import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'user_type.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserType {
  static const String user = 'User';
  static const String restaurantOwner = 'Restaurant Owner';
}



class SignupScreen extends StatefulWidget {
  final String userType;
  //SignupScreen({this.userType});
  SignupScreen({required this.userType});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _restaurantNameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedUserType = UserType.user;

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _storeUserData(
        userCredential.user?.uid,
        _selectedUserType,
        _fullNameController.text,
        _restaurantNameController.text,
      );

      if (_selectedUserType == UserType.user) {
        Navigator.pushReplacementNamed(context, '/orderScreen');
      } else if (_selectedUserType == UserType.restaurantOwner) {
        Navigator.pushReplacementNamed(context, '/restaurantDashboard');
      }
    } catch (e) {
      print('Sign up failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _storeUserData(String? userId, String userType, String fullName, [String? restaurantName]) async {
    try {
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(userId!);
      userRef.set({
        'userType': userType,
        'fullName': fullName,
        if (userType == UserType.restaurantOwner) 'restaurantName': restaurantName,
      });

      await FirebaseFirestore.instance.collection('restaurantOwner').doc(userId).set({
        'userType': userType,
        'fullName': fullName,
        if (userType == UserType.restaurantOwner) 'restaurantName': restaurantName,
      });

      if (userType == UserType.restaurantOwner) {
        await FirebaseFirestore.instance.collection('restaurant_owner').doc(userId).set({
          'userType': userType,
          'fullName': fullName,
          'restaurantName': restaurantName,
        });
      }

      print('User data stored successfully');
    } catch (e) {
      print('Error storing user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error storing user data. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _onUserTypeChanged(String? value) {
    setState(() {
      _selectedUserType = value ?? UserType.user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/login-icon/food_delivery_logo.png',
                  height: 150,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(height: 32),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),

                SizedBox(height: 16),
                if (_selectedUserType == UserType.restaurantOwner)
                  TextField(
                    controller: _restaurantNameController,
                    decoration: InputDecoration(
                      labelText: 'Restaurant Name',
                      prefixIcon: Icon(Icons.restaurant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('Sign Up'),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen(userType: '')),
                    );
                  },
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
