import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ubon_application/admin_all_sceens/adminCustomLoader.dart';
// Import CustomLoader if it’s in a separate file

import '../admin_all_sceens/addBrandScreen.dart';

class BrandScreen extends StatelessWidget {
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

  // Method to delete brand with loader
  Future<void> _deleteBrand(BuildContext context, String brandId) async {
    await CustomLoader.showLoaderForTask(
      context: context,
      task: () async {
        try {
          await _firestore.collection('brands').doc(brandId).delete();
          Fluttertoast.showToast(msg: "Brand deleted successfully");
        } catch (e) {
          Fluttertoast.showToast(msg: "Error deleting brand: $e");
          //print();
        }
      },
    );
  }

  // Refresh brands list with loader
  Future<void> _refreshPage(BuildContext context) async {
    await CustomLoader.showLoaderForTask(
      context: context,
      task: () async {
        // Add delay or any additional operations to simulate a refresh
        await Future.delayed(Duration(seconds: 1));
        Fluttertoast.showToast(msg: "Page refreshed successfully");

        //print("");
      },
    );
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
            onPressed: () async {
              await _refreshPage(context); // Use refresh loader
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
              'My Brands',
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
                stream: _firestore.collection('brands').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var brands = snapshot.data!.docs;

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
                              'Brand Name',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lora',
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lora',
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Added Date', // New column for timestamp
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lora',
                              ),
                            ),
                          ),
                          DataColumn(label: SizedBox.shrink()), // Delete column
                        ],
                        rows: brands.map((brand) {
                          Map<String, dynamic>? brandData = brand.data() as Map<String, dynamic>?;
                          String name = brandData?['brandName'] ?? 'Unknown Brand';
                          bool status = brandData?['status'] ?? false;
                          String statusText = status ? "Active" : "Inactive";
                          String brandId = brand.id;
                          var createdAt = brandData?['createdAt']; // Fetch the createdAt timestamp
                          String formattedDate = formatDate(createdAt); // Format the date

                          return DataRow(cells: [
                            DataCell(Row(
                              children: [
                                Icon(Icons.branding_watermark, color: Colors.black),
                                SizedBox(width: 8),
                                Text(name, style: TextStyle(color: Colors.black, fontFamily: 'Lora')),
                              ],
                            )),
                            DataCell(Text(statusText, style: TextStyle(color: Colors.black, fontFamily: 'Lora'))),
                            DataCell(Text(formattedDate, style: TextStyle(color: Colors.black, fontFamily: 'Lora'))), // Display formatted date
                            DataCell(Icon(Icons.delete, color: Colors.red), onTap: () async {
                              // Show confirmation dialog before deleting
                              bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text('Are you sure you want to delete this brand?'),
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
                                await _deleteBrand(context, brandId); // Delete brand with loader
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
            MaterialPageRoute(builder: (context) => AddBrandScreen()),
          );
          // Add new brand action
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
