import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ubon_application/admin_all_sceens/adminCustomLoader.dart';



class AddBrandScreen extends StatefulWidget {
  @override
  _AddBrandScreenState createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  // Function to add brand to Firestore with loading overlay
  Future<void> _addBrand() async {
    String brandName = _brandNameController.text.trim();
    String statusText = _statusController.text.trim().toLowerCase();

    if (brandName.isEmpty || statusText.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill in all fields");
      return;
    }

    // Determine status based on user input
    bool? status;
    if (statusText == 'active') {
      status = true;
    } else if (statusText == 'inactive') {
      status = false;
    } else {
      Fluttertoast.showToast(msg: "Invalid status. Use 'Active' or 'Inactive'.");
      return;
    }

    await CustomLoader.showLoaderForTask(
      context: context,
      task: () async {
        try {
          DocumentReference brandRef = FirebaseFirestore.instance.collection('brands').doc();
          await brandRef.set({
            'brandId': brandRef.id, // Set the generated document ID as brandId
            'brandName': brandName,
            'status': status,
            'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          });
          Fluttertoast.showToast(msg: "Brand added successfully");

          // Clear the fields after submission
          _brandNameController.clear();
          _statusController.clear();
        } catch (e) {
          print("Error adding brand: $e");
          Fluttertoast.showToast(msg: "Failed to add brand");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: Text(
            'ADD BRAND',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Lora',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _brandNameController,
                decoration: InputDecoration(
                  hintText: 'Brand Name',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: false,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _statusController,
                decoration: InputDecoration(
                  hintText: 'Status (Active/Inactive)',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: false,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Cancel action
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC00),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _addBrand, // Submit action with loader
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
