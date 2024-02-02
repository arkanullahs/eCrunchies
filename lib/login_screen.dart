import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_screen.dart' as signup;
import 'user_type.dart' as userType;

class LoginScreen extends StatefulWidget {
  final String userType;

  LoginScreen({required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedUserType = userType.UserType.user;

  bool _isPasswordInputting = false;
  bool _isPasswordIncorrect = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoginSuccessful = false;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 10.0, end: 50.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onUserTypeChanged(String? value) {
    setState(() {
      _selectedUserType = value ?? userType.UserType.user;
    });
  }

  void _updateButtonState() {
    setState(() {
      _isPasswordInputting = _passwordController.text.isNotEmpty;
      _isPasswordIncorrect = false;
    });
  }

  void _startLogin() {
    setState(() {
      _isLoggingIn = true;
    });
  }

  void _stopLogin() {
    setState(() {
      _isLoggingIn = false;
    });
  }

  void _login() async {
    try {
      _startLogin(); // Start loading indicator

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String detectedUserType = await _getUserType(userCredential.user?.uid);

      if (detectedUserType == userType.UserType.user) {
        Navigator.pushReplacementNamed(context, '/orderScreen');
      } else if (detectedUserType == userType.UserType.restaurantOwner) {
        Navigator.pushReplacementNamed(context, '/restaurantDashboard');
      } else {
        // Handle the case where the user type is neither 'user' nor 'restaurantOwner'
        print('Invalid user type: $detectedUserType');
      }
    } catch (e) {
      print('Login failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _isPasswordIncorrect = true;
      });
      _animationController.forward().then((value) {
        _animationController.reverse();
      });
    } finally {
      _stopLogin(); // Stop loading indicator regardless of success or failure
    }
  }

  Future<String> _getUserType(String? userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userTypesDoc =
      await FirebaseFirestore.instance.collection('userTypes').doc(userId).get();

      if (userTypesDoc.exists) {
        return userTypesDoc.get('userType');
      } else {
        print('User type not found in database');
        return ''; // Handle this case based on your requirements
      }
    } catch (e) {
      print('Error getting user type: $e');
      return ''; // Handle this case based on your requirements
    }
  }

  bool _isRestaurantOwner() {
    return _selectedUserType == userType.UserType.restaurantOwner;
  }

  Future<void> _showForgotPasswordDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Enter your email to receive a password reset link.'),
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _sendPasswordResetEmail();
                Navigator.of(context).pop();
              },
              child: Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  void _sendPasswordResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Reset Email Sent'),
            content: Text('Check your email for a password reset link.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      print('Password reset email sent successfully');
    } catch (e) {
      print('Error sending password reset email: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error sending password reset email. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFF9EBDC),
      appBar: AppBar(
        title: Text('Login'),
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
                  height: 170,
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
                  onChanged: (_) => _updateButtonState(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                GestureDetector(
                  onTap: _isPasswordIncorrect || _isLoggingIn ? null : _login,
                  child: Container(
                    width: 130,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_animation.value),
                      color: _isLoginSuccessful
                          ? Colors.green
                          : _isPasswordIncorrect
                          ? Colors.red
                          : (_isPasswordInputting ? Theme.of(context).primaryColor : Colors.grey[400]),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        children: [
                          if (!_isLoggingIn) // Only show arrow when not logging in
                            _isLoginSuccessful
                                ? Icon(Icons.check, color: Colors.white)
                                : _isPasswordIncorrect
                                ? Icon(Icons.close, color: Colors.white)
                                : Icon(Icons.arrow_forward, color: Colors.white),
                          if (_isLoggingIn)
                            CircularProgressIndicator(
                              strokeAlign: BorderSide.strokeAlignCenter,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),




                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    _showForgotPasswordDialog();
                  },
                  child: Text('Forgot Password?'),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToSignupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => signup.SignupScreen(userType: _selectedUserType)),
    );
  }
}
