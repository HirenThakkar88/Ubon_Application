import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProductDetailScreen.dart';


class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  Stream<List<Map<String, dynamic>>> fetchProductsByCategory(String categoryName) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: categoryName) // Filter by category
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
  Future<void> _addToCart({
    required String productId,
    required String productName,
    required String productImage,
    required String brand,
    required double price,
    required String category,
    required double offerPrice,
  }) async {
    try {
      // Retrieve the user's authId from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final authId = prefs.getString('uid');
      if (authId == null) {
        throw Exception("User not authenticated.");
      }

      // Retrieve the user's document ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('authentication')
          .where('auth_id', isEqualTo: authId)
          .get();
      if (querySnapshot.docs.isEmpty) {
        throw Exception("User document not found.");
      }

      final userDocId = querySnapshot.docs.first.id;

      // Define the cart reference
      final cartRef = FirebaseFirestore.instance
          .collection('authentication')
          .doc(userDocId)
          .collection('cart');

      // Calculate total price
      int quantity = 1; // Default quantity
      double totalPrice = quantity * offerPrice;

      // Add product to the cart
      await cartRef.doc(productId).set({
        'authId': authId,
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'brand': brand,
        'price': price,
        'category': category,
        'offerPrice': offerPrice,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$productName has been added to your cart.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product to cart: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // SystemChrome configurations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 255, 255, 255),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: Column(
        children: [
          // Custom AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    widget.categoryName,
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // For symmetry with the back button
              ],
            ),
          ),
          // Body Content
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchProductsByCategory(widget.categoryName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading products'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available for this category'));
                }

                final products = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to product detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product),
                          ),
                        );
                      },

                    child:  _buildProductCard(
                      product['imageUrls'][0] ?? 'assets/images/placeholder.jpg',
                      product['productName'] ?? 'No Name',
                      product['price'] ?? 0.0,
                      product['offerPrice'] ?? 0.0,
                      product['category'] ?? 'No Category',
                      product['rating'] ?? 0.0,
                      product['productId']??'no',
                      product['brand']??'no',
                    ),// Pass the category name here
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String imagePath, String name, double price, double offerPrice, String categoryName, dynamic rating,String productId, String brand,) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a Stack to overlay the favorite icon on the image
          Stack(
            children: [
              // Responsive image size
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Get the screen size using MediaQuery
                    double screenWidth = MediaQuery.of(context).size.width;

                    // Calculate responsive height for the image (50% of screen width as an example)
                    double imageHeight = screenWidth * 0.45;

                    return Center(
                      child: Image.network(
                        imagePath,
                        height: imageHeight, // Set the height based on the screen width
                        width: double.infinity, // Ensure the width fills the container
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              // Favorite icon in the top-right corner
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    _addToCart(
                      productId: productId,
                      productName: name,
                      productImage: imagePath,
                      brand: brand,
                      price: offerPrice,
                      category: categoryName,
                      offerPrice: price,
                    );
                    // Add functionality to toggle favorite status
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_border, // Change to Icons.favorite for selected state
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: const TextStyle(
                  fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              categoryName, // Display the category name here
              style: const TextStyle(
                fontFamily: 'Lora',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '$rating', // Display the rating value
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  '\₹${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '\₹${offerPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
