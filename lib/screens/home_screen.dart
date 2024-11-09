// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import SystemChrome
import '../widgets/custom_bottom_nav_bar.dart'; // Import the custom bottom nav bar
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  //const HomeScreen({Key? key}) : super(key: key);
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // SystemChrome configurations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
          Color.fromARGB(0, 255, 255, 255), // Semi-transparent white
      statusBarIconBrightness: Brightness.dark, // Icon color to light
      statusBarBrightness: Brightness.light, // Status bar text color to light
      systemNavigationBarColor:
          Colors.transparent, // Transparent navigation bar
      systemNavigationBarIconBrightness:
          Brightness.dark, // Navigation icons light
    ));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Section for "Item Sale"
            Stack(
              children: [
                Container(
                  height: 500,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/Main_page_image.jpg'), // Replace with your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // "Item sale" Text Positioned and Styled
                Positioned(
                  bottom: 50,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Item sale',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontStyle: FontStyle.italic, // Apply italic style
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          print('Check button pressed!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFFFFCC00), // Set the button color to your preferred yellow
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
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
            ),

            // New Items Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      print('View all pressed!');
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

            // New Items Horizontal List
            SizedBox(
              height:
                  280, // Adjusted height for taller card to accommodate stars and price
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildNewItemCard('assets/images/item_first.jpg',
                      'HeadPhones', 15, 12, 4.5),
                  _buildNewItemCard('assets/images/item_second.jpeg',
                      'Thunder Bass', 20, 18, 4.0),
                  _buildNewItemCard('assets/images/item_third.png',
                      'PowerBank + Charger', 25, 22, 5.0),
                  _buildNewItemCard('assets/images/item_fourth.png',
                      'Ear Sound', 18, 15, 3.5),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Headphones',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('View all pressed!');
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
            SizedBox(
              height:
                  280, // Adjusted height for taller card to accommodate stars and price
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildNewItemCard('assets/images/image_fifth.png',
                      'HeadPhones', 15, 12, 4.5),
                  _buildNewItemCard('assets/images/item_second.jpeg',
                      'Thunder Bass', 20, 18, 4.0),
                  _buildNewItemCard('assets/images/item_third.png',
                      'PowerBank + Charger', 25, 22, 5.0),
                  _buildNewItemCard('assets/images/item_fourth.png',
                      'Ear Sound', 18, 15, 3.5),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wired Earphones',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('View all pressed!');
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
            SizedBox(
              height:
                  280, // Adjusted height for taller card to accommodate stars and price
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildNewItemCard('assets/images/image_fifth.png',
                      'HeadPhones', 15, 12, 4.5),
                  _buildNewItemCard('assets/images/item_second.jpeg',
                      'Thunder Bass', 20, 18, 4.0),
                  _buildNewItemCard('assets/images/item_third.png',
                      'PowerBank + Charger', 25, 22, 5.0),
                  _buildNewItemCard('assets/images/item_fourth.png',
                      'Ear Sound', 18, 15, 3.5),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
      ), // Bottom Navigation Bar
    );
  }

  // Widget to build individual new item cards
  Widget _buildNewItemCard(String imagePath, String label, double originalPrice,
      double discountedPrice, double rating) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 160, // Adjusted width for a proportional look
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
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
                  child: Image.asset(
                    imagePath,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // "New" label on top of the image
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4.0, // Add spacing between icons and text
                    children: [
                      for (int i = 0; i < rating.floor(); i++)
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                      if (rating - rating.floor() >= 0.5)
                        const Icon(Icons.star_half,
                            color: Colors.orange, size: 16),
                      for (int i = rating.ceil(); i < 5; i++)
                        const Icon(Icons.star_border,
                            color: Colors.orange, size: 16),
                      Text(
                        '($rating)',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$$originalPrice',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '\$$discountedPrice',
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
    );
  }
}
