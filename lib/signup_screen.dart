import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Import the LoginScreen file
import 'user_type.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedUserType = UserType.user; // Default user type

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // If sign-up successful, navigate to the next screen based on the user type
      if (widget.userType == UserType.user) {
        Navigator.pushReplacementNamed(context, '/orderScreen'); // Navigate to the user screen
      } else if (widget.userType == UserType.restaurantOwner) {
        Navigator.pushReplacementNamed(context, '/restaurantDashboard'); // Navigate to the restaurant dashboard
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

  void _onUserTypeChanged(String? value) {
    setState(() {
      _selectedUserType = value ?? UserType.user;
    });
  }

  Widget _buildUserTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select User Type:'),
        Row(
          children: [
            Radio(
              value: UserType.user,
              groupValue: _selectedUserType,
              onChanged: _onUserTypeChanged,
            ),
            Text('User'),
            SizedBox(width: 20),
            Radio(
              value: UserType.restaurantOwner,
              groupValue: _selectedUserType,
              onChanged: _onUserTypeChanged,
            ),
            Text('Restaurant Owner'),
          ],
        ),
      ],
    );
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
                  height: 120,
                ),
                SizedBox(height: 32),
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
                _buildUserTypeSelection(),
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
                      MaterialPageRoute(builder: (context) => LoginScreen(userType: '',)),
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
