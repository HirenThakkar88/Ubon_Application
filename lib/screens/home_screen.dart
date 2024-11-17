import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import SystemChrome
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/screens/shop_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'CategoryProductsScreen.dart';
import 'NewProductsScreen.dart';
import 'ProductDetailScreen.dart';
import 'allCategoryScreen.dart'; // Import the custom bottom nav bar

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Fetch products by category
  Stream<List<Map<String, dynamic>>> fetchProductsByCategory(String categoryName) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: categoryName) // Filter by category
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
  // Save product to user's cart in Firestore
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



  // Fetch products by category
  Stream<List<Map<String, dynamic>>> fetchNewProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .orderBy('createdAt', descending: true) // Order by newest first
        .limit(10) // Limit to the latest 10 products, adjust as needed
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  // Fetch categories from Firestore
  Stream<List<Map<String, dynamic>>> fetchCategories() {
    return FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  // Fetch background image URL from Firestore
  Future<String?> fetchBackgroundImageUrl() async {
    try {
      // Get the document from 'backgroundphoto' collection
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('backgroundphoto')
          .doc('SI7jPaMoRObhD7uYOBjl')  // Use the correct document ID or query
          .get();

      // Check if the document exists and contains the 'imageUrls' field
      if (snapshot.exists && snapshot.data() != null) {
        String imageUrl = snapshot.get('imageUrls');
        return imageUrl; // Return the string URL directly
      }
    } catch (e) {
      print('Error fetching background image URL: $e');
    }
    return null;
  }

  Future<void> _refreshPage() async {
    // Add any specific actions to refresh data, like re-fetching data from Firestore.
    await Future.delayed(Duration(seconds: 2)); // Simulate a delay for loading
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome configurations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 255, 255, 255), // Semi-transparent white
      statusBarIconBrightness: Brightness.dark, // Icon color to light
      statusBarBrightness: Brightness.light, // Status bar text color to light
      systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
      systemNavigationBarIconBrightness: Brightness.dark, // Navigation icons light
    ));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh:  () async {
          // Print a message to the console
          print("Page is being refreshed...");

          // Call the function to fetch data
          await _refreshPage();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Image Section for "Item Sale"
              FutureBuilder<String?>(
                future: fetchBackgroundImageUrl(), // Fetch the background image URL
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading image'));
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    // Use the image URL from Firebase Storage
                    return Stack(
                      children: [
                        Container(
                          height: 500,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(snapshot.data!), // Use the dynamic URL here
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 50,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'All Products',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  goToProduct(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFCC00),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Check',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(child: Text('No image found'));
                },
              ),            // Other widgets go here (e.g., Product Grid/List View)


          // New Items Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the NewProductsScreen to view all products
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Newproductsscreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // New Items Horizontal List from Firestore
              SizedBox(
                height: 300,

                child:
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fetchNewProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading products'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No new products available'));
                    }

                    final products = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
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
                          // Pass the category name here
                        ),
                        );
                      },
                    );
                  },
                ),

              ),

              // Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => AllCategoriesScreen(), // Your new screen
                        ),
                        );
                        //print('View all pressed!');
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories List from Firestore
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading categories'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No categories available'));
                  }

                  final categories = snapshot.data!.take(4).toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),

                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  // Widget to build individual new item cards
  Widget _buildNewItemCard(
      String imagePath, String label, double originalPrice, double discountedPrice, String categoryName, dynamic rating, String productId,String brand) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 160,
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
                      topLeft: Radius.circular(15), topRight: Radius.circular(15)),
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
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                // "New" label on top of the image
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
                        fontFamily: 'Lora',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Favorite icon in the top-right corner
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      // Add logic to handle adding to favorites
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
                maxLines: 1, // Limit to 1 line
                overflow: TextOverflow.ellipsis,
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



  // Widget to build individual category cards
  Widget _buildCategoryCard(String categoryName, String categoryImage) {
    return GestureDetector(
      onTap: () {
        // Navigate to the category-specific product screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(categoryName: categoryName),
          ),
        );
      },
      child: Card(
        color: Colors.white,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    categoryImage,
                    width: 130,
                    height: 130,
                    //width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoryName,
                style: const TextStyle(fontFamily: 'Lora', fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to navigate to product details screen
  void goToProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopScreen()), // Adjust this route
    );
  }
}