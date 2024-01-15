import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Widget _buildUserTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select User Type:'),
        Row(
          children: [
            Radio(
              value: userType.UserType.user,
              groupValue: _selectedUserType,
              onChanged: _onUserTypeChanged,
            ),
            Text('User'),
            SizedBox(width: 20),
            Radio(
              value: userType.UserType.restaurantOwner,
              groupValue: _selectedUserType,
              onChanged: _onUserTypeChanged,
            ),
            Text('Restaurant Owner'),
          ],
        ),
      ],
    );
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
    }
  }

  bool _isRestaurantOwner() {
    return _selectedUserType == userType.UserType.restaurantOwner;
  }

  // Method -> Forgot Password
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

  // Method-> password reset email
  void _sendPasswordResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);

      // Display a message
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
                _buildUserTypeSelection(),
                SizedBox(height: 1),
               // ElevatedButton(
                 // onPressed: _login,
                 // child: Text('Login'),
               // ),
                SizedBox(height: 1),
                TextButton(
                  onPressed: () {
                    _showForgotPasswordDialog();
                  },
                  child: Text('Forgot Password?'),
                ),
                SizedBox(height: 1),
                TextButton(
                  onPressed: () {
                    _goToSignupScreen();
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
  void _goToSignupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => signup.SignupScreen(userType: _selectedUserType)),
    );
  }
}
