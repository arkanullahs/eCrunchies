import 'package:flutter/material.dart';
import 'signup_screen.dart' as signup;
import 'user_type.dart';
import 'login_screen.dart';

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
            Image.asset(
              'assets/login-icon/food_delivery_logo.png',
              height: 170,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => signup.SignupScreen(userType: '',)),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                textStyle: TextStyle(fontSize: 18),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: Text('Sign Up as User'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => signup.SignupScreen(userType: UserType.restaurantOwner)),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                textStyle: TextStyle(fontSize: 18),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: Text('Sign Up as Restaurant Owner'),
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
    );
  }
}
