import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createUser(String name, String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'currentOrder': {}, // Empty order initially
    });
  } catch (e) {
    print('Error creating user: $e');
    // Handle error appropriately
  }
}
