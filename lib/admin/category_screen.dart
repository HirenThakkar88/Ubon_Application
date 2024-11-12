import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../admin_all_sceens/addCategoryScreen.dart';

class CategoryScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to format Firestore Timestamp
  String formatDate(dynamic date) {
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return DateFormat.yMMMd().format(dateTime);
    } else if (date is String) {
      return date; // If it's already a string, return it directly
    } else {
      return ''; // Return an empty string if the date is in an unexpected format
    }
  }

  // Method to delete category
  Future<void> _deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      print("Category deleted successfully");
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.black, fontFamily: 'Lora'),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white70,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey),
            onPressed: () {
              // Refresh action
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Categories',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var categories = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Category Name',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lora',
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Added Date',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lora',
                              ),
                            ),
                          ),
                          DataColumn(label: SizedBox.shrink()), // Delete column
                        ],
                        rows: categories.map((category) {
                          String name = category['categoryName'];
                          var addedDate = category['createdAt'];
                          String formattedDate = formatDate(addedDate);
                          String categoryId = category.id; // Fetch the document ID

                          return DataRow(cells: [
                            DataCell(Row(
                              children: [
                                Icon(Icons.category, color: Colors.black),
                                SizedBox(width: 8),
                                Text(name, style: TextStyle(color: Colors.black, fontFamily: 'Lora')),
                              ],
                            )),
                            DataCell(Text(formattedDate, style: TextStyle(color: Colors.black, fontFamily: 'Lora'))),
                            DataCell(Icon(Icons.delete, color: Colors.red), onTap: () async {
                              // Show confirmation dialog before deleting
                              bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text('Are you sure you want to delete this category?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false); // Cancel
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true); // Confirm
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDelete == true) {
                                await _deleteCategory(categoryId); // Delete category
                              }
                            }),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFFFFCC00),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCategoryScreen()),
          );
          // Add new category action
        },
        icon: Icon(Icons.add),
        label: Text(
          'Add New',
          style: TextStyle(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
