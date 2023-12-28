import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart'; // Import the SignupScreen file
import 'order_screen.dart'; // Import the OrderScreen file
import 'restaurant_dash.dart'; // Import the RestaurantDashboard file

class UserType {
  static const String user = 'User';
  static const String restaurantOwner = 'Restaurant Owner';
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoginSuccessful = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isPasswordInputting = false;
  bool _isPasswordIncorrect = false;

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

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _isLoginSuccessful = true;
      });
      _animationController.forward().then((value) {
        if (_isRestaurantOwner()) {
          Navigator.pushReplacementNamed(context, '/restaurantDashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/orderScreen');
        }
      });
    } catch (e) {
      setState(() {
        _isPasswordIncorrect = true;
      });
      _animationController.forward().then((value) {
        _animationController.reverse();
      });
    }
  }

  bool _isRestaurantOwner() {
    // Add your logic to determine if the logged-in user is a restaurant owner
    // For example, you can check the user's type in Firebase
    return false; // Replace with your logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onTap: _isPasswordIncorrect ? null : _login,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_animation.value),
                          color: _isLoginSuccessful
                              ? Colors.green
                              : _isPasswordIncorrect
                              ? Colors.red
                              : (_isPasswordInputting ? Theme.of(context).primaryColor : Colors.grey),
                        ),
                        child: Center(
                          child: _isLoginSuccessful
                              ? Icon(Icons.check, color: Colors.white)
                              : _isPasswordIncorrect
                              ? Icon(Icons.close, color: Colors.white)
                              : (_isPasswordInputting
                              ? Icon(Icons.arrow_forward, color: Colors.white)
                              : Icon(Icons.arrow_forward, color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateButtonState() {
    setState(() {
      _isPasswordInputting = _passwordController.text.isNotEmpty;
      _isPasswordIncorrect = false;
    });
  }
}
