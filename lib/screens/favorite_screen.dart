import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/custom_bottom_nav_bar.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 3;
  List<Map<String, dynamic>> favorites = [];
  List<Map<String, dynamic>> filteredFavorites = [];
  TextEditingController searchController = TextEditingController();
  Set<String> categories = {};
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Load favorites from Firestore based on the user's authId
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');

    if (authId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('authentication')
          .where('auth_id', isEqualTo: authId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDocId = querySnapshot.docs.first.id;

        final cartRef = FirebaseFirestore.instance
            .collection('authentication')
            .doc(userDocId)
            .collection('cart');

        final snapshot = await cartRef.get();

        setState(() {
          favorites = snapshot.docs.map((doc) {
            final data = doc.data();
            categories.add(data['category']); // Add category dynamically
            return {
              'productName': data['productName'],
              'category': data['category'],
              'brand': data['brand'],
              'totalPrice': data['totalPrice'],
              'productImage': data['productImage'],
              'productId': data['productId'],
              'isFavorite': true,
            };
          }).toList();
          filteredFavorites = List.from(favorites); // Initially show all favorites
        });
      }
    }
  }


  void _searchFavorites(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFavorites = List.from(favorites);
      } else {
        filteredFavorites = favorites.where((item) {
          final productName = item['productName'].toLowerCase();
          return productName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _moveToOrders(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');

    if (authId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('authentication')
          .where('auth_id', isEqualTo: authId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDocId = querySnapshot.docs.first.id;

        final cartRef = FirebaseFirestore.instance
            .collection('authentication')
            .doc(userDocId)
            .collection('cart');

        final orderRef = FirebaseFirestore.instance
            .collection('authentication')
            .doc(userDocId)
            .collection('bag');

        // Fetch the selected product from cart
        final cartItemSnapshot = await cartRef
            .where('productId', isEqualTo: productId)
            .get();

        if (cartItemSnapshot.docs.isNotEmpty) {
          final cartItemData = cartItemSnapshot.docs.first.data();

          // Add the product to the orders collection
          await orderRef.add(cartItemData);

          // Optionally remove it from the cart (if needed)
          await cartItemSnapshot.docs.first.reference.delete();

          setState(() {
            favorites.removeWhere((item) => item['productId'] == productId);
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Product added to Bag!'),
          ));
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(fontSize: screenWidth * 0.06, fontFamily: 'Lora',fontWeight: FontWeight.bold),
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
              showSearch(
                context: context,
                delegate: _FavoritesSearchDelegate(favorites: favorites),
              );
            },
          ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: screenWidth * 0.1, color: Colors.black),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'No Favorites Yet',
              style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.02),
                    child: FilterChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (isSelected) {
                        setState(() {
                          selectedCategory = isSelected ? category : '';
                          filteredFavorites = isSelected
                              ? favorites.where((item) => item['category'] == category).toList()
                              : List.from(favorites);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Stack(
                  children: [
                    Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item['productImage'],
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
                                        Text(
                                          item['productName'],
                                          style: TextStyle(
                                            fontFamily: 'Lora',
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.048,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Brand: ${item['brand']}',
                                      style: TextStyle(
                                          fontFamily: 'Lora', fontSize: screenWidth * 0.045),
                                    ),
                                    Text(
                                      'Category: ${item['category']}',
                                      style: TextStyle(
                                          fontFamily: 'Lora', fontSize: screenWidth * 0.04),
                                    ),
                                    Text(
                                      'Amount: ₹${item['totalPrice']}',
                                      style: TextStyle(
                                        fontFamily: 'Lora',
                                        color: Colors.red,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.10, // Adjusted size
                                height: screenWidth * 0.10,
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
                                child: IconButton(
                                  icon: Icon(
                                    item['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                                    color: item['isFavorite'] ? Colors.red : Colors.grey,
                                    size: screenWidth * 0.05,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      item['isFavorite'] = !item['isFavorite'];
                                    });

                                    if (!item['isFavorite']) {
                                      // Remove the item from Firestore
                                      final prefs = await SharedPreferences.getInstance();
                                      final authId = prefs.getString('uid');
                                      final querySnapshot = await FirebaseFirestore.instance
                                          .collection('authentication')
                                          .where('auth_id', isEqualTo: authId)
                                          .get();
                                      final userDocId = querySnapshot.docs.first.id;

                                      final cartRef = FirebaseFirestore.instance
                                          .collection('authentication')
                                          .doc(userDocId)
                                          .collection('cart');

                                      await cartRef
                                          .where('productId', isEqualTo: item['productId'])
                                          .get()
                                          .then((snapshot) {
                                        for (var doc in snapshot.docs) {
                                          doc.reference.delete();
                                        }
                                      });

                                      // Remove the item from the local list
                                      setState(() {
                                        favorites.removeAt(index);
                                      });
                                    }
                                  },
                                ),
                              )

                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bag Icon Positioned at the Bottom Right
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the bag/cart screen
                          _moveToOrders(item['productId']);
                        },
                        child: Container(
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 3,
                              ),
                            ],

                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: Colors.black,
                            size: screenWidth * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
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
}

class _FavoritesSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> favorites;

  _FavoritesSearchDelegate({required this.favorites});

  @override
  String? get searchFieldLabel => 'Search favorites';

  @override
  Widget buildSuggestions(BuildContext context) {
    final queryResults = query.isEmpty
        ? favorites
        : favorites
        .where((item) => item['productName']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: queryResults.length,
      itemBuilder: (context, index) {
        final item = queryResults[index];
        return ListTile(
          title: Text(item['productName']),
          subtitle: Text('Brand: ${item['brand']}'),
          onTap: () {
            close(context, null); // Close search
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
}
