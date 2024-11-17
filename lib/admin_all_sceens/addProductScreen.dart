import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? selectedCategory;
  String? selectedBrand;
  List<String> categories = [];
  List<String> brands = [];
  List<File> selectedImages = []; // Store selected images locally
  List<String> imageUrls = []; // Store uploaded image URLs

  // Product form data
  TextEditingController productNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController offerPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchBrands();
  }

  // Fetch categories from Firestore
  Future<void> fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
      List<String> fetchedCategories = snapshot.docs.map((doc) => doc['categoryName'] as String).toList();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  // Fetch brands from Firestore
  Future<void> fetchBrands() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('brands').get();
      List<String> fetchedBrands = snapshot.docs.map((doc) => doc['brandName'] as String).toList();
      setState(() {
        brands = fetchedBrands;
      });
    } catch (e) {
      print("Error fetching brands: $e");
    }
  }

  // Pick an image and display it on the screen
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path)); // Add selected image to the list
      });
    }
  }

  // Upload images to Firebase Storage and get download URLs
  Future<void> uploadImages() async {
    for (var imageFile in selectedImages) {
      try {
        String filePath = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(filePath);

        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();

        imageUrls.add(downloadUrl); // Store image URL
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  // Submit product details to Firestore
  Future<void> submitProduct() async {
    if (productNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        quantityController.text.isEmpty ||
        selectedImages.isEmpty ||
        selectedCategory == null ||
        selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields and upload at least one image")),
      );
      return;
    }

    try {
      // Upload images first
      await uploadImages();

      // Fetch the categoryId based on the selectedCategory name
      String categoryId = await getCategoryId(selectedCategory!);

      // Create a new document reference in Firestore
      DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc();

      // Prepare product data
      Map<String, dynamic> productData = {
        'productId': productRef.id, // Use the document ID as the productId
        'productName': productNameController.text,
        'description': descriptionController.text,
        'price': double.parse(priceController.text),
        'quantity': int.parse(quantityController.text),
        'offerPrice': offerPriceController.text.isNotEmpty ? double.parse(offerPriceController.text) : null,
        'categoryId': categoryId, // Add categoryId here
        'category': selectedCategory,
        'brand': selectedBrand,
        'imageUrls': imageUrls, // Use uploaded image URLs
        'createdAt': Timestamp.now(),
      };

      // Save product data to Firestore
      await productRef.set(productData);
      Fluttertoast.showToast(msg: "Product added successfully", toastLength: Toast.LENGTH_SHORT);

      // Clear fields after submitting
      productNameController.clear();
      descriptionController.clear();
      priceController.clear();
      quantityController.clear();
      offerPriceController.clear();
      setState(() {
        selectedCategory = null;
        selectedBrand = null;
        selectedImages.clear();
        imageUrls.clear();
      });
    } catch (e) {
      print("Error adding product: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding product")));
    }
  }

// Fetch categoryId based on selectedCategory name
  Future<String> getCategoryId(String categoryName) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('categoryName', isEqualTo: categoryName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id; // Return the categoryId
      } else {
        throw Exception('Category not found');
      }
    } catch (e) {
      print("Error fetching categoryId: $e");
      throw Exception('Error fetching categoryId');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ADD PRODUCT',
          style: TextStyle(
            fontFamily: 'Lora',
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                    (index) => Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                      onPressed: pickImage,
                    ),
                    Text('Image ${index + 1}', style: TextStyle(fontFamily: 'Lora', color: Colors.black)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: selectedImages.map((image) {
                return Image.file(
                  image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: TextStyle(fontFamily: 'Lora', color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Product Description',
                labelStyle: TextStyle(fontFamily: 'Lora', color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            categories.isNotEmpty
                ? DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Category',
                labelStyle: TextStyle(fontFamily: 'Lora', color: Colors.black),
              ),
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: TextStyle(fontFamily: 'Lora', color: Colors.black)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            )
                : Text('Loading categories...'),
            SizedBox(height: 16),
            brands.isNotEmpty
                ? DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Brand',
                labelStyle: TextStyle(fontFamily: 'Lora', color: Colors.black),
              ),
              value: selectedBrand,
              items: brands.map((brand) {
                return DropdownMenuItem<String>(
                  value: brand,
                  child: Text(brand, style: TextStyle(fontFamily: 'Lora', color: Colors.black)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBrand = value;
                });
              },
            )
                : Text('Loading brands...'),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(fontFamily: 'Lora', color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(fontFamily: 'Lora', color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: offerPriceController,
              decoration: InputDecoration(
                labelText: 'Offer Price',
                labelStyle: TextStyle(fontFamily: 'Lora', color: Colors.black),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: TextStyle(fontFamily: 'Lora', color: Colors.black,
                    fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCC00),
                    ),
                    onPressed: submitProduct,
                    child: Text('Submit', style: TextStyle(fontFamily: 'Lora', color: Colors.black,
                    fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
