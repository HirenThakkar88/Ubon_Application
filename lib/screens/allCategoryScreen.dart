import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'CategoryProductsScreen.dart';
// Import the screen where you want to show products

class AllCategoriesScreen extends StatelessWidget {
  // Stream to fetch categories from Firestore
  Stream<List<Map<String, dynamic>>> fetchCategories() {
    return FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Categories',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Pop the current screen and go back to the previous one
          },
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading categories'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          final categories = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  category['categoryName'] ?? 'No Name',
                  category['imageUrl'] ?? 'assets/images/placeholder.jpg',
                  category['categoryName'], // Pass category name
                  context,
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Build the category card that will be displayed in the grid
  Widget _buildCategoryCard(String categoryName, String categoryImage, String categoryNameForNav, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // When a category is clicked, navigate to CategoryProductsScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(categoryName: categoryNameForNav), // Pass the category name to the product screen
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 5,
        child: Column(
          children: [
            Expanded(
              child: Center( // Center the image
                child: Image.network(
                  categoryImage,
                  width: 130, // Adjust width as needed
                  height: 130, // Adjust height as needed
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
