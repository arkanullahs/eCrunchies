import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'food_details_screen.dart';
import 'food_items_screen.dart';
import 'discover_screen.dart';
import 'foods_screen.dart';
import 'restaurant_menu_screen.dart';
import 'order_chat_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String searchQuery = '';
  //String? userName = '';
  String? userEmail = '';
  String? profilePictureUrl;

  @override
  void initState() {
    super.initState();
    //fetchUserName();
    fetchUserEmail();
  }


  void fetchUserEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? email = user.email;
        setState(() {
          userEmail = email;
        });
      }
    } catch (error) {
      print('Error fetching user email: $error');
    }
  }

/////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Restaurants'),
        actions: [
          GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: RestaurantSearchDelegate(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.search,
                size: 32,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.logout,
                size: 32,
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: Container(
          color: Colors.blueGrey[500],
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'User Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: profilePictureUrl != null // Use profilePictureUrl here
                          ? Image.network(
                        profilePictureUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : SizedBox(
                        width: 50,
                        height: 50,
                        child: Placeholder(),
                      ),

                      title: Text(
                        userEmail ?? 'Email Address',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  'View Profile',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                onTap: () async {
                  // Navigate to the profile view screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileViewScreen()),
                  );
                },
              ),

              ListTile(
                title: Text(
                  'Upload Profile Picture',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                onTap: () async {
                  await _uploadProfilePicture();
                },
              ),
              ListTile(
                title: Text(
                  'About Us',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        //],
      ),
   // ),
    //),

    body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            FoodsScreen(),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            FoodItemsScreen(),
            DiscoverScreen(),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMessages(context);
        },
        tooltip: 'Show Messages',
        child: Icon(Icons.message),
      ),
    );
  }
  Future<void> _uploadProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Upload image to Firebase Storage
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;

        // Get the download URL of the uploaded image
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Save the download URL in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'profile_picture': downloadUrl});

        // Update the UI to display the profile picture
        setState(() {
          // Update the profile picture URL with the newly uploaded picture's download URL
          profilePictureUrl = downloadUrl;
          // This will trigger the UI to update
          // and show the newly uploaded picture
          // You can also navigate to a new page where the user can see their updated profile
          // For simplicity, I'm not implementing navigation here
          // You can add it as per your application flow
        });
      }
    } catch (error) {
      print('Error uploading profile picture: $error');
    }
  }
}

//void _showMessages() async {
void _showMessages(BuildContext context) async {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    CollectionReference orderChatsCollection =
    FirebaseFirestore.instance.collection('order_chats');

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await orderChatsCollection
          .where('sender', isEqualTo: currentUserEmail)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      List<String> orderIds = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
      in querySnapshot.docs) {
        String orderId = document['orderId'];
        orderIds.add(orderId);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select an Order'),
            content: Container(
              width: double.maxFinite,
              //height: MediaQuery.of(context).size.height * 0.5,

              child: ListView.builder(
                itemCount: orderIds.length,
          //itemBuilder: (BuildContext context, int index) {
          itemBuilder: (context, index) {
                  String orderId = orderIds[index];

                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Order ID: $orderId',
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderChatScreen(
                                restaurantId: '', //  the restaurant ID here
                                orderId: orderId,
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error fetching order chats: $error');
    }
  }
class ProfileViewScreen extends StatefulWidget {
  @override
  _ProfileViewScreenState createState() => _ProfileViewScreenState();
}
class _ProfileViewScreenState extends State<ProfileViewScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController privacyController = TextEditingController();
  TextEditingController securityController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPrivate = false;
  bool twoFactorAuth = false;
 // String aboutUs = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('Change Email:'),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your new email',
              ),
            ),
            SizedBox(height: 20),
            Text('Change Password:'),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your new password',
              ),
            ),
            SizedBox(height: 20),
            Text('Privacy:'),
            Switch(
              value: isPrivate,
              onChanged: (value) {
                setState(() {
                  isPrivate = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Two-factor Authentication:'),
            Switch(
              value: twoFactorAuth,
              onChanged: (value) {
                setState(() {
                  twoFactorAuth = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await updateProfile();
              },
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    try {
      if (emailController.text.isNotEmpty) {
        await FirebaseAuth.instance.currentUser?.updateEmail(emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email updated successfully.'),
          ),
        );
      }

      if (passwordController.text.isNotEmpty) {
        await FirebaseAuth.instance.currentUser?.updatePassword(passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully.'),
          ),
        );
      }

      if (isPrivate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Privacy settings updated successfully.'),
          ),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
    }
  }
}
class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Team Members:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            ListTile(
              leading: Image.asset('assets/nadia_yeasmin.jpg'),
              title: Text('Nadia Yeasmin'),
              subtitle: Text('Developer'),
            ),
            ListTile(
              leading: Image.asset('assets/arkanullah_saad.jpg'),
              title: Text('Arkanullah Saad'),
              subtitle: Text('Developer'),
            ),
            ListTile(
              leading: Image.asset('assets/khadiza_khanom_liza.jpg'),
              title: Text('Khadiza khanom liza'),
              subtitle: Text('Developer'),
            ),
            Divider(),
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            // Display description using Text widget
            Text(
              'About our eCrunchies: The food delivery application aims to revolutionize the way users interact with restaurant services. It will provide a seamless platform where users can explore diverse culinary options, place orders effortlessly . Simultaneously, it offers restaurant owners a streamlined interface to manage incoming orders efficiently.',
              style: TextStyle(fontSize: 16),
            ),

            Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Email:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  // Display contact emails using Text widgets
                  Text(
                    'nadiasupti8@gmail.com',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'arkanullahs@gmail.com',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'IK221201@gmail.com',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}


class RestaurantSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResults(searchQuery: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SearchResults(searchQuery: query);
  }
}


class SearchResults extends StatelessWidget {
  final String searchQuery;

  SearchResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: searchQuery + 'z')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot document = documents[index];
            final String name = document['name'];
            final String imageUrl = document['imageUrl'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantMenuScreen(restaurantName: name),
                  ),
                );
              },
              child: RestaurantCard(
                imageUrl: imageUrl,
                name: name,
              ),
            );
          },
        );
      },
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  RestaurantCard({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

