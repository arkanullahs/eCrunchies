import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordInputting = false;
  bool _isPasswordIncorrect = false;

  void _updateButtonState() {
    setState(() {
      _isPasswordInputting = _passwordController.text.isNotEmpty;
      _isPasswordIncorrect = false;
    });
  }

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    setState(() {
      _isPasswordIncorrect = false; // Reset the incorrect password status
    });

    // Simulate login success/failure
    if (username == 'saad' && password == '123') {
      // Replace this logic with actual authentication
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _isPasswordIncorrect = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              onChanged: (_) => _updateButtonState(),
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              onChanged: (_) => _updateButtonState(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isPasswordIncorrect ? null : _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
