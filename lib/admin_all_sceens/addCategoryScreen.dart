import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomLoader {
  static Future<void> showLoaderForTask({
    required BuildContext context,
    required Future<void> Function() task,
  }) async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Execute the task
    try {
      await task();
    } finally {
      // Remove the loading overlay
      Navigator.of(context).pop();
    }
  }
}

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  File? _image;

  // Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('categories/$fileName');
      await ref.putFile(_image!);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  // Function to add category to Firestore with loader and toast
  Future<void> _addCategory() async {
    if (_categoryNameController.text.isEmpty || _image == null) {
      Fluttertoast.showToast(msg: "Please fill in all fields");
      return;
    }

    await CustomLoader.showLoaderForTask(
      context: context,
      task: () async {
        try {
          String? imageUrl = await _uploadImage();
          if (imageUrl != null) {
            DocumentReference categoryRef = FirebaseFirestore.instance.collection('categories').doc();
            await categoryRef.set({
              'categoryId': categoryRef.id, // Set the generated document ID as categoryId
              'categoryName': _categoryNameController.text,
              'imageUrl': imageUrl,
              'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            });

            Fluttertoast.showToast(msg: "Category added successfully");

            // Clear the fields after submission
            _categoryNameController.clear();
            setState(() {
              _image = null;
            });
          } else {
            Fluttertoast.showToast(msg: "Failed to upload image");
          }
        } catch (e) {
          print("Error adding category: $e");
          Fluttertoast.showToast(msg: "Failed to add category");
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
            'ADD CATEGORY',
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
              GestureDetector(
                onTap: _pickImage, // Trigger image picker
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey[700]),
                      SizedBox(height: 5),
                      Text(
                        'Category',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(
                  hintText: 'Category Name',
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
                    onPressed: _addCategory, // Submit action with loader
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
