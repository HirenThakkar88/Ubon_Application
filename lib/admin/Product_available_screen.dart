import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllProductsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch products from Firestore
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include the document ID for deletion
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // Method to delete a product from Firestore
  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      print('Product deleted: $productId');
    } catch (e) {
      print("Error deleting product: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        backgroundColor: Colors.white,
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
              String productId = product['id']; // Get the document ID for deletion

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
                      Text('Price: \₹$price'),
                      offerPrice < price
                          ? Text('Offer Price: \₹$offerPrice', style: TextStyle(color: Colors.red))
                          : SizedBox(),
                      Text('Available Quantity: $quantity'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool confirm = await _showDeleteConfirmation(context, name);
                      if (confirm) {
                        await _deleteProduct(productId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$name deleted')),
                        );
                        // Trigger a rebuild by using a StatefulWidget or refreshing the FutureBuilder
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Show confirmation dialog before deleting
  Future<bool> _showDeleteConfirmation(BuildContext context, String productName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
        false;
  }
}
