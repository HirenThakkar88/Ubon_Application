import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllProductsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch products from Firestore
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available.'));
          }

          var products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              String name = product['productName'] ?? 'Unknown Product';
              String imageUrl = product['imageUrls'] != null && product['imageUrls'].isNotEmpty
                  ? product['imageUrls'][0] // Assuming it's an array and picking the first image
                  : '';
              String brand = product['brand'] ?? 'Unknown Brand';
              String category = product['category'] ?? 'Unknown Category';
              String description = product['description'] ?? 'No description available';
              double price = product['price'] ?? 0.0;
              double offerPrice = product['offerPrice'] ?? price; // Use offer price if available, otherwise the original price
              int quantity = product['quantity'] ?? 0;

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Brand: $brand'),
                      Text('Category: $category'),
                      Text('Description: $description', maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text('Price: \$$price'),
                      offerPrice < price
                          ? Text('Offer Price: \$$offerPrice', style: TextStyle(color: Colors.red))
                          : SizedBox(),
                      Text('Available Quantity: $quantity'),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // You can navigate to a detailed product screen if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

