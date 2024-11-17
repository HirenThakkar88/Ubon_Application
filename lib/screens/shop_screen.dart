import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'ProductDetailScreen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedIndex = 1;
  bool isGridView = true;
  String filterType = 'all'; // Added filterType state variable

  // Fetch products by category from Firestore with filter applied
  Stream<List<Map<String, dynamic>>> fetchProducts() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('products');

    // Apply filter based on selected filter type
    if (filterType == 'newest') {
      query = query.orderBy('createdAt', descending: true); // Order by timestamp for newest products
    } else if (filterType == 'highToLow') {
      query = query.orderBy('offerPrice', descending: true); // Order by price: High to Low
    } else if (filterType == 'lowToHigh') {
      query = query.orderBy('offerPrice', descending: false); // Order by price: Low to High
    }

    return query.snapshots().map((snapshot) =>
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products',
          style: TextStyle(
              color: Colors.black,
            fontSize: screenWidth > 600 ? 28 : 24, // Responsive font size

            fontWeight: FontWeight.bold,

          ),
        ),
        centerTitle: true,
        actions: [
          if (screenWidth > 600) // Show the search icon on larger screens
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                // Handle search button pressed
              },
            ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      filterType == 'newest'
                          ? 'Newest'
                          : filterType == 'highToLow'
                          ? 'Price: High to Low'
                          : filterType == 'lowToHigh'
                          ? 'Price: Low to High'
                          : 'Show all', // Default to 'Popular' when no filter is selected
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                      ),
                    ),
                  ],
                ),


                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.swap_vert, color: Colors.black),
                          onPressed: () async {
                            // Open filter dialog
                            String? selectedFilter = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Choose Filter'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: const Text('Newest'),
                                        onTap: () => Navigator.pop(context, 'newest'),
                                      ),
                                      ListTile(
                                        title: const Text('Price: High to Low'),
                                        onTap: () => Navigator.pop(context, 'highToLow'),
                                      ),
                                      ListTile(
                                        title: const Text('Price: Low to High'),
                                        onTap: () => Navigator.pop(context, 'lowToHigh'),
                                      ),
                                      ListTile(
                                        title: const Text('Show All'),
                                        onTap: () => Navigator.pop(context, 'all'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (selectedFilter != null) {
                              setState(() {
                                filterType = selectedFilter; // Update filter type
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 30),
                        IconButton(
                          icon: isGridView
                              ? const Icon(Icons.view_list, color: Colors.black)
                              : const Icon(Icons.grid_view, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              isGridView = !isGridView;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),

              ],

            ),
          ),

          const Divider(
            color: Colors.grey, // Line color
            thickness: 0.5,        // Line thickness
            height: 10,

            // Space around the line
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading products'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available'));
                }

                final products = snapshot.data!;
                return isGridView
                    ? buildGridView(products)
                    : buildListView(products);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
      ),
    );
  }

// GridView and ListView methods remain unchanged.



  // Build responsive GridView
  Widget buildGridView(List<Map<String, dynamic>> products) {
    int crossAxisCount = (MediaQuery.of(context).size.width > 600) ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.61,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            // Navigate to ProductDetailScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: _buildProductCard(
            product['imageUrls'][0] ?? 'assets/images/placeholder.jpg',
            product['productName'] ?? 'No Name',
            product['rating'] ?? 0.0,
            product['category'] ?? 'No Category',
            product['offerPrice'] ?? 0.0,
            product['price'] ?? 0.0,
            product['productId']??'no',
            product['brand']??'no',
          ),
        );
      },
    );
  }

  // Build ListView
  Widget buildListView(List<Map<String, dynamic>> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            // Navigate to ProductDetailScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: _buildListItem(
            product['imageUrls'][0] ?? 'assets/images/placeholder.jpg',
            product['productName'] ?? 'No Name',
            product['rating'] ?? 0.0,
            product['category'] ?? 'No Category',
            product['offerPrice'] ?? 0.0,
            product['price'] ?? 0.0,
              product['productId']??'no',
              product['brand']??'no',

          ),
        );
      },
    );
  }

  // Product card for GridView
  Widget _buildProductCard(
      String imageUrl,
      String name,
      dynamic rating,
      String category,
      double offerPrice,
      double price,

      String productId,
      String brand) {
    double ratingValue =
    (rating is double) ? rating : (rating is num) ? rating.toDouble() : 0.0;

    return Stack(
      children: [
        Container(
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(category,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          ratingValue.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (offerPrice > 0)
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
                          '\₹${offerPrice > 0 ? offerPrice.toStringAsFixed(2) : price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Positioned Favorite Icon
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              _addToCart(
                productId: productId,
                productName: name,
                productImage: imageUrl,
                brand: brand,
                price: price,
                category: category,
                offerPrice: offerPrice,
              );
              // Add logic to handle adding to favorites
              //print('Favorite icon clicked for $name');
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
    );
  }


  // ListItem for ListView
  Widget _buildListItem(String imageUrl, String name, dynamic rating,
      String category, double offerPrice, double price,String productId, String brand) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (offerPrice > 0)
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
                      '\₹${offerPrice > 0 ? offerPrice.toStringAsFixed(2) : price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Favorite Icon
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                _addToCart(
                  productId: productId,
                  productName: name,
                  productImage: imageUrl,
                  brand: brand,
                  price: price,
                  category: category,
                  offerPrice: offerPrice,
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
    );
  }

}
