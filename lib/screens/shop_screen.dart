import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart'; // Import the custom bottom nav bar

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedIndex = 1;
  bool isGridView = true; // Toggle between Grid and List view

  // Sample list of products (you can replace it with your own data)
  final List<Map<String, dynamic>> _products = [
    {
      'image': 'assets/images/item_first.jpg',
      'title': 'Headphone - Ubon',
      'rating': 4.5,
      'reviews': 120,
      'category': 'Electric',
      'price': 12.99
    },
    {
      'image': 'assets/images/item_second.jpeg',
      'title': 'NeckBand - ubon',
      'rating': 4.2,
      'reviews': 259,
      'category': 'Electric',
      'price': 19.99
    },
    {
      'image': 'assets/images/item_third.png',
      'title': 'Powerbank + charger',
      'rating': 4.8,
      'reviews': 500,
      'category': 'Electric',
      'price': 21.99
    },
    {
      'image': 'assets/images/item_fourth.png',
      'title': 'NeckBand - ubon',
      'rating': 3.5,
      'reviews': 430,
      'category': 'Electric',
      'price': 15.99
    },
    {
      'image': 'assets/images/image_fifth.png',
      'title': 'Earpods - Ubon',
      'rating': 4.7,
      'reviews': 400,
      'category': 'Electric',
      'price': 14.99
    },
    {
      'image': 'assets/images/item_seven.jpeg',
      'title': 'Data Cable - Ubon',
      'rating': 4.3,
      'reviews': 70,
      'category': 'Electric',
      'price': 11.99
    },
    {
      'image': 'assets/images/item_eight.jpeg',
      'title': 'Car Charger - ubon',
      'rating': 4.3,
      'reviews': 70,
      'category': 'Electric',
      'price': 5.99
    },
    {
      'image': 'assets/images/item_third.png',
      'title': 'Powerbank + charger',
      'rating': 4.8,
      'reviews': 500,
      'category': 'Electric',
      'price': 21.99
    },
    {
      'image': 'assets/images/item_seven.jpeg',
      'title': 'Data Cable - Ubon',
      'rating': 4.3,
      'reviews': 70,
      'category': 'Electric',
      'price': 11.99
    },
  ];

  // Function to open the sort options modal bottom sheet
  void _openSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Popular'),
              onTap: () {
                // Handle sorting logic here
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Newest'),
              onTap: () {
                // Handle sorting logic here
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Reviews'),
              onTap: () {
                // Handle sorting logic here
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Price: High to Low'),
              onTap: () {
                // Handle sorting logic here
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Price: Low to High'),
              onTap: () {
                // Handle sorting logic here
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
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
          // Filter and Sorting Row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.filter_list, color: Colors.black),
                    SizedBox(width: 4),
                    Text('Popular', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.swap_vert, color: Colors.black),
                      onPressed:
                          _openSortOptions, // Open sort modal when pressed
                    ),
                    const SizedBox(width: 90),
                    IconButton(
                      icon: isGridView
                          ? const Icon(Icons.view_list,
                              color: Colors.black) // List view icon
                          : const Icon(Icons.grid_view,
                              color: Colors.black), // Grid view icon
                      onPressed: () {
                        setState(() {
                          isGridView =
                              !isGridView; // Toggle between Grid and List view
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Use Expanded to prevent overflow
          Expanded(
            child: isGridView ? buildGridView() : buildListView(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.61,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        double price =
            product['price'] != null ? product['price'] as double : 0.0;
        return _buildProductCard(
          product['image'],
          product['title'],
          product['rating'],
          product['reviews'],
          product['category'],
          price,
        );
      },
    );
  }

  Widget buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        double price =
            product['price'] != null ? product['price'] as double : 0.0;
        return _buildListItem(
          product['image'],
          product['title'],
          product['rating'],
          product['reviews'],
          product['category'],
          price,
        );
      },
    );
  }

  // Function to build individual product cards with price tag for GridView
  Widget _buildProductCard(String imagePath, String title, double rating,
      int reviews, String category, double price) {
    return Container(
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
                  topRight: Radius.circular(15),
                ),
                child: Image.asset(
                  imagePath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 110,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border,
                        size: 19, color: Colors.red),
                    onPressed: () {
                      // Handle favorite button pressed
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Wrap(
                      spacing: 4.0,
                      children: List.generate(5, (index) {
                        if (index < rating.floor()) {
                          return const Icon(Icons.star,
                              color: Colors.orange, size: 16);
                        } else if (index == rating.floor() &&
                            rating - rating.floor() >= 0.5) {
                          return const Icon(Icons.star_half,
                              color: Colors.orange, size: 16);
                        } else {
                          return const Icon(Icons.star_border,
                              color: Colors.orange, size: 16);
                        }
                      }),
                    ),
                    Text(' ($reviews)',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                // Display the price tag
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build individual product list items for ListView
  Widget _buildListItem(String imagePath, String title, double rating,
      int reviews, String category, double price) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Wrap(
                      spacing: 4.0,
                      children: List.generate(5, (index) {
                        if (index < rating.floor()) {
                          return const Icon(Icons.star,
                              color: Colors.orange, size: 16);
                        } else if (index == rating.floor() &&
                            rating - rating.floor() >= 0.5) {
                          return const Icon(Icons.star_half,
                              color: Colors.orange, size: 16);
                        } else {
                          return const Icon(Icons.star_border,
                              color: Colors.orange, size: 16);
                        }
                      }),
                    ),
                    Text(' ($reviews)',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () {
              // Handle favorite button pressed
            },
          ),
        ],
      ),
    );
  }
}
