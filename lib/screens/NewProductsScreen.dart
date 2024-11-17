import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProductDetailScreen.dart';

class Newproductsscreen extends StatefulWidget {
  const Newproductsscreen({super.key});

  @override
  State<Newproductsscreen> createState() => _NewproductsscreenState();
}

class _NewproductsscreenState extends State<Newproductsscreen> {
  Stream<List<Map<String, dynamic>>> fetchNewProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .orderBy('createdAt', descending: true)
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

  //Fluttertoast.showToast(msg: "Invaliad User");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'New Launched',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchNewProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading products'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No new products available'));
                }

                final products = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 items per row
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
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

                      child:  _buildNewItemCard(
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

  Widget _buildNewItemCard(
      String imagePath, String label, double originalPrice, double discountedPrice, String categoryName, dynamic rating,String productId,String brand) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Image.network(
                    imagePath,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10, // Position the favorite icon on the top-right corner
                  child: GestureDetector(
                    onTap: () {
                      _addToCart(
                        productId: productId,
                        productName: label,
                        productImage: imagePath,
                        brand: brand,
                        price: originalPrice,
                        category: categoryName,
                        offerPrice: discountedPrice,
                      );
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
                        Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    '\₹${originalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\₹${discountedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
