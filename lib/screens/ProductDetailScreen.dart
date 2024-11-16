import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductDetailScreen extends StatefulWidget
{

  final Map<String, dynamic> product;

  const ProductDetailScreen({required this.product});


  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();

}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final authid = FirebaseAuth.instance.currentUser?.uid ?? '';


    // Set up system UI overlay configurations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 255, 255, 255), // Semi-transparent white
      statusBarIconBrightness: Brightness.dark, // Icon color to dark
      statusBarBrightness: Brightness.light, // Status bar text color to light
      systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
      systemNavigationBarIconBrightness: Brightness.dark, // Navigation icons dark
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrls = product['imageUrls'] as List<dynamic>? ?? [];

    // Get screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 600; // Consider wide screens as those with width > 600

    // Dynamic font sizes based on screen width
    final titleFontSize = screenWidth < 350 ? 20.0 : 24.0;
    final priceFontSize = screenWidth < 350 ? 20.0 : 24.0;
    final descriptionFontSize = screenWidth < 350 ? 14.0 : 16.0;
    final quantityFontSize = screenWidth < 350 ? 14.0 : 16.0;

    return Scaffold(
      body: SingleChildScrollView(  // Wrap the entire body in a scroll view
        child: Padding(
          padding: EdgeInsets.only(top: 30, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Back Button, Share Button, and Favorite Button at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.black),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.black),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Main Product Image
              Center(
                child: Image.network(
                  imageUrls.isNotEmpty ? imageUrls[0] : 'assets/images/placeholder.jpg',
                  height: 300,
                  width: screenWidth * 0.8,  // Use percentage of screen width for responsiveness
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // GridView of Product Images
              if (imageUrls.length > 1)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWideScreen ? 4 : 3, // Adjust grid count based on screen width
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              const SizedBox(height: 16),

              // Product Title, Price, and Seller
              Text(
                product['productName'] ?? 'No Name',
                style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, fontFamily: 'lora'),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\₹${product['offerPrice'].toStringAsFixed(2)}',
                    style: TextStyle(fontSize: priceFontSize, fontWeight: FontWeight.bold, color: Colors.red, fontFamily: 'lora'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\₹${product['price'].toStringAsFixed(2)}',
                    style: const TextStyle(fontFamily: 'lora', fontSize: 16, decoration: TextDecoration.lineThrough, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  Text(
                    '${product['rating'] ?? 0} ',
                    style: const TextStyle(fontSize: 16, fontFamily: 'lora', fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '(${product['totalRatings'] ?? 0} Reviews)',
                    style: const TextStyle(color: Colors.grey, fontFamily: 'lora'),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),

              // Color Options
              const Text(
                'Color',
                style: TextStyle(fontSize: 16, fontFamily: 'lora', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),

              // Tab Bar for Description, Specifications, Reviews
              TabBar(
                controller: _tabController,
                labelColor: Colors.red,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.orange,
                tabs: [
                  Tab(text: 'Description'),
                  Tab(text: 'Specifications'),
                  Tab(text: 'Reviews'),
                ],
              ),
              SizedBox(
                height: 150,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      child: Text(
                        product['description'] ?? 'No Description',
                        style: TextStyle(fontSize: descriptionFontSize),
                        softWrap: true,
                      ),
                    ),
                    const Text('Specifications will be shown here'),
                    const Text('Reviews will be shown here'),
                  ],
                ),
              ),

              // Quantity Selector and Add to Cart Button
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildQuantitySelector(quantityFontSize),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {

                      },
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),

                  ),
                ],
              ),
              const SizedBox(height: 30),  // Add space after the buttons
            ],
          ),
        ),
      ),
    );
  }

  // Quantity Selector Widget
  Widget _buildQuantitySelector(double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: () {
              setState(() {
                if (_quantity > 1) _quantity--;
              });
            },
          ),
          Text(
            '$_quantity',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              setState(() {
                _quantity++;
              });
            },
          ),
        ],
      ),
    );
  }


}
