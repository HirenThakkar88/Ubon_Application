import 'package:flutter/material.dart';

import '../widgets/custom_bottom_nav_bar.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 3;

  final List<Map<String, dynamic>> favorites = [
    {
      'title': 'Headphone',
      'brand': 'LIME',
      'color': 'Blue',
      'price': 32,
      'rating': 5,
      'reviews': 10,
      'image': 'assets/images/item_first.jpg', // Replace with your image paths
      'isSoldOut': false,
      'isNew': false,
    },
    {
      'title': 'Headphones',
      'brand': 'Mango',
      'color': 'Orange',
      'price': 46,
      'rating': 0,
      'reviews': 0,
      'image': 'assets/images/item_first.jpg',
      'isSoldOut': false,
      'isNew': true,
    },
    {
      'title': 'Buds',
      'brand': 'Olivier',
      'color': 'Gray',
      'price': 52,
      'rating': 3,
      'reviews': 3,
      'image': 'assets/images/item_first.jpg',
      'isSoldOut': true,
      'isNew': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(fontSize: screenWidth * 0.06, fontFamily: 'Lora'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_bag), // Add bag icon here
            onPressed: () {
              // Navigate to the bag/cart screen
              Navigator.pushNamed(context, '/bagScreen');
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(label: Text('Electric'), onSelected: (val) {}),
                  SizedBox(width: screenWidth * 0.02),
                  FilterChip(label: Text('Gadget'), onSelected: (val) {}),
                  SizedBox(width: screenWidth * 0.02),
                  FilterChip(label: Text('Powerbank'), onSelected: (val) {}),
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              item['image'],
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (item['isNew'])
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02,
                                            vertical: screenHeight * 0.005,
                                          ),
                                          color: Colors.orange,
                                          child: Text(
                                            'NEW',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.03,
                                            ),
                                          ),
                                        ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        item['brand'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.045,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item['title'],
                                    style: TextStyle(fontSize: screenWidth * 0.045),
                                  ),
                                  Text(
                                    'Color: ${item['color']}',
                                    style: TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                  Text(
                                    '\$${item['price']}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: screenWidth * 0.04,
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        '${item['rating']} (${item['reviews']})',
                                        style: TextStyle(fontSize: screenWidth * 0.035),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.01,
                        right: screenWidth * 0.02,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red, size: screenWidth * 0.05),
                          onPressed: () {
                            setState(() {
                              favorites.removeAt(index);
                            });
                          },
                        ),
                      ),
                      if (item['isSoldOut'])
                        Positioned.fill(
                          child: Container(
                            color: Colors.grey.withOpacity(0.7),
                            alignment: Alignment.center,
                            child: Text(
                              'Sorry, this item is currently sold out',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        // onItemTapped: (index) {
        //   setState(() {
        //     _selectedIndex = index;
        //   });
        //   if (index == 2) {
        //     Navigator.pushNamed(context, '/bagScreen'); // Navigate to the bag screen
        //   }
        // },
      ),
    );
  }
}
