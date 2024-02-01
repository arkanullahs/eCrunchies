import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'user_type.dart' as userType;
import 'package:cloud_firestore/cloud_firestore.dart';

class UserType {
  static const String user = 'User';
  static const String restaurantOwner = 'Restaurant Owner';
}

class SignupScreen extends StatefulWidget {
  final String userType;

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
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _storeUserData(
        userCredential.user?.uid,
        widget.userType,
        _fullNameController.text,
        _emailController.text,
        _restaurantNameController.text,
      );

      if (widget.userType == UserType.user) {
        Navigator.pushReplacementNamed(context, '/orderScreen');
      } else if (widget.userType == UserType.restaurantOwner) {
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _storeUserData(String? userId, String userType, String fullName, String email,
      [String? restaurantName]) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userType': userType,
        'fullName': fullName,
        'email': email,
        if (userType == UserType.restaurantOwner) 'restaurantName': restaurantName,
      });

      await FirebaseFirestore.instance.collection('userTypes').doc(userId).set({
        'userType': userType,
      });

      print('User data stored successfully : $userType, Name: $fullName, email: $email, restaurantName: $restaurantName');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9EBDC),
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
                if (widget.userType == UserType.restaurantOwner)
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
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward_ios_outlined),
                      SizedBox(width: 0),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen(userType: '')),
                    );
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    textStyle: TextStyle(fontSize: 16),
                  ),
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
