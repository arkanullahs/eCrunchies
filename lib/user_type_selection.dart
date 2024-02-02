import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eCrunchies/notification_controller.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart' as signup;
import 'user_type.dart';
import 'login_screen.dart';

class UserTypeSelection extends StatefulWidget {
  @override
  _UserTypeSelectionState createState() => _UserTypeSelectionState();
}

class _UserTypeSelectionState extends State<UserTypeSelection> {
  int _currentIndex = 0;


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFF9EBDC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 200),
            Image.asset(
              'assets/login-icon/food_delivery_logo.png',
              height: 200,
              fit: BoxFit.fitHeight,
              alignment: Alignment.bottomCenter,
            ),
            SizedBox(height: 100),
            _currentIndex == 0
                ? Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => signup.SignupScreen(userType: UserType.user)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    //primary: Color(0xfff47a10), // Reddish color
                    textStyle: TextStyle(fontSize: 18, /*color: Colors.white*/),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: Icon(Icons.person, size: 24),
                  label: Text('Sign Up as User'),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => signup.SignupScreen(userType: UserType.restaurantOwner)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    //primary: Color(0xfff47a10), // Reddish color
                    textStyle: TextStyle(fontSize: 18, color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: Icon(Icons.restaurant, size: 24),
                  label: Text('Sign Up as Restaurant'),
                ),
              ],
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepOrange,
        selectedIconTheme: IconThemeData(
          color: Colors.deepOrange,
          size: 30.0, // Adjust the size according to your preference
        ),
        selectedLabelStyle: TextStyle(
          color: Colors.deepOrange,
        ),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 1) {
              selectedItemColor: Colors.deepOrange;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen(userType: '')),
              );
            }
          });
        },
        //backgroundColor: Color(0xFFF9EBDC),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_outlined),
            label: 'Sign Up',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login_outlined),
            label: 'Log In',
          ),
        ],
      ),
    );
  }
}
