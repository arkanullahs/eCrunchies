import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Added Items'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;


          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Dismissible(
                    key: Key(items[index].id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      // Delete item from database
                      FirebaseFirestore.instance
                          .collection('items')
                          .doc(items[index].id)
                          .delete();

                      // Remove item from list
                      items.removeAt(index);

                      // Update the UI
                      setState(() {});
                    },
                    background: Container(
                      color: Colors.red,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 40),
                    ),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(5),
                        leading: Image.network(
                          items[index]['imageUrl'],
                          height: 70,
                          width: 70,
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center
                        ),
                        title: Text(
                          items[index]['name'],
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height:3),
                            Text(
                              items[index]['description'],
                              style: TextStyle(fontSize: 14,fontStyle:FontStyle.italic),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            TextButton(
                              onPressed: () {
                                // Show full description in a dialog
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Description'),
                                      content: Text(items[index]['description']),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero, // Set this
                                padding: EdgeInsets.zero, // and this
                              ),
                              child: Text('Read more'),

                            ),
                            Text(
                              '\$${items[index]['price']}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                // Navigate to edit item page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditItemPage(
                                      item: items[index],
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 5,thickness: 0), // Divider between items
                ],
              );
            },
          );

        },
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  void setState(Null Function() param0) {}
}

class EditItemPage extends StatelessWidget {
  final DocumentSnapshot item;

  const EditItemPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: item['name']);
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController(text: item['imageUrl']);
    final descriptionController = TextEditingController(text: item['description']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: Form(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Price',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update item in Firestore
                FirebaseFirestore.instance
                    .collection('items')
                    .doc(item.id)
                    .update({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'imageUrl': imageUrlController.text,
                });

                // Navigate back to show items page
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}