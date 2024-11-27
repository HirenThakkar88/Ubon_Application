import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/screens/shop_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'AddressSelectionScreen.dart';

class MyBagScreen extends StatefulWidget {
  @override
  _MyBagScreenState createState() => _MyBagScreenState();
}

class _MyBagScreenState extends State<MyBagScreen> {
  int _selectedIndex = 2; // Default selected index for bottom nav bar
  List<Map<String, dynamic>> bagItems = [];
  String? selectedCoupon;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchBagItems();
  }

  Future<void> fetchBagItems() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');
    if (authId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('authentication')
          .where('auth_id', isEqualTo: authId)
          .get();


      if (querySnapshot.docs.isNotEmpty) {
        final userDocId = querySnapshot.docs.first.id;
        final bagSnapshot = await FirebaseFirestore.instance
            .collection('authentication')
            .doc(userDocId)
            .collection('bag')
            .get();

        setState(() {
          bagItems = bagSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          _calculateTotalAmount();
        });
      }
    }
  }
  void _calculateTotalAmount() {
    double total = 0.0;
    for (var item in bagItems) {
      final double price = item['offerPrice'] ?? 0.0;
      final int quantity = item['quantity'] ?? 0;
      total += price * quantity;
    }
    setState(() {
      _totalAmount = total;
    });
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');
    if (authId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('authentication')
          .where('auth_id', isEqualTo: authId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDocId = querySnapshot.docs.first.id;

        // Fetch product price
        final productDoc = await FirebaseFirestore.instance
            .collection('authentication')
            .doc(userDocId)
            .collection('bag')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final productData = productDoc.data();
          final double price = productData?['offerPrice'] ?? 0.0;
          final int oldQuantity = productData?['quantity'] ?? 0;

          // Update the quantity in Firestore
          await FirebaseFirestore.instance
              .collection('authentication')
              .doc(userDocId)
              .collection('bag')
              .doc(productId)
              .update({'quantity': newQuantity});

          // Calculate total price change
          final double oldTotal = price * oldQuantity;
          final double newTotal = price * newQuantity;
          final double totalChange = newTotal - oldTotal;

          // Update total price in `totalPrice` collection
          final totalPriceDoc = await FirebaseFirestore.instance
              .collection('authentication')
              .doc(userDocId)
              .collection('bag')
              .doc(productId);


          if ((await totalPriceDoc.get()).exists) {
            await totalPriceDoc.update({
              'totalPrice': FieldValue.increment(totalChange),
            });
          } else {
            // If totalPrice document doesn't exist, create it
            await totalPriceDoc.set({'totalPrice': newTotal});
          }

          // Update local state after Firestore update
          setState(() {
            final itemIndex =
            bagItems.indexWhere((item) => item['id'] == productId);
            if (itemIndex != -1) {
              bagItems[itemIndex]['quantity'] = newQuantity;
            }
            _calculateTotalAmount();
          });
        }
      }
    }
  }

  Future<void> deleteItem(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');
    if (authId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('authentication')
          .where('auth_id', isEqualTo: authId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDocId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('authentication')
            .doc(userDocId)
            .collection('bag')
            .doc(productId)
            .delete();

        // Refresh the list
        fetchBagItems();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Bag",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: Colors.black,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: bagItems.isEmpty
                  ? Center(
                child: Text(
                  "Your bag is empty",
                  style: TextStyle(
                    fontFamily: 'Lora',

                    fontSize: screenWidth * 0.045,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: bagItems.length,
                itemBuilder: (context, index) {
                  final item = bagItems[index];
                  return Column(
                    children: [
                      _buildCartItem(
                        productId: item['id'],
                        imagePath: item['productImage'] ?? 'assets/images/default.jpeg',
                        title: item['productName'] ?? 'Unknown Item',
                        category: item['category'] ?? 'N/A',
                        brand: item['brand'],
                        price: item['offerPrice'] ?? 0.0,
                        quantity: item['quantity'] ?? 0,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  );
                },
              ),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select Coupon Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:  EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
              ),
              value: selectedCoupon,
              items: [
                DropdownMenuItem(
                  value: 'DISCOUNT10',
                  child: Text('DISCOUNT10 - 10% off'),
                ),
                DropdownMenuItem(
                  value: 'FREESHIP',
                  child: Text('FREESHIP - Free Shipping'),
                ),
                DropdownMenuItem(
                  value: 'SAVE20',
                  child: Text('SAVE20 - Save 20'),
                ),
                DropdownMenuItem(
                  value: 'BUY1GET1',
                  child: Text('BUY1GET1 - Buy 1 Get 1 Free'),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  selectedCoupon = value;
                });
              },
              icon: const Icon(Icons.arrow_drop_down),
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: screenWidth * 0.04,
                color: Colors.black,
              ),
              dropdownColor: Colors.white,
              alignment: Alignment.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Text(
                  'Total amount:',
                  style: TextStyle(fontSize: screenWidth * 0.045,fontFamily: 'Lora',fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${_totalAmount.toStringAsFixed(2)}', // Dynamically displaying total amount
                  style: TextStyle(fontSize:screenWidth * 0.045, fontWeight: FontWeight.bold),
                ),

              ],

            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Text(
                  'Coupen Discount: ',
                  style: TextStyle(fontSize: screenWidth * 0.045,fontFamily: 'Lora',fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹0', // Dynamically displaying total amount
                  style: TextStyle(fontSize:screenWidth * 0.045, fontWeight: FontWeight.bold),
                ),

              ],

            ),


            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressSelectionScreen()),
                );
                // Handle checkout logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                minimumSize: Size(double.infinity, screenHeight * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:  Text(
                'CHECK OUT',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Lora',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildCartItem({
    required String productId,
    required String imagePath,
    required String title,
    required String category,
    required String brand,
    required double price,
    required int quantity,
    required double screenWidth,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imagePath,
            width: screenWidth * 0.2,
            height: screenWidth * 0.2,
            fit: BoxFit.cover,
          ),
          SizedBox(width: screenWidth * 0.05),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  brand,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildCircularButton(Icons.remove, () {
                          if (quantity > 1) {
                            updateQuantity(productId, quantity - 1);
                          }
                        }),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        _buildCircularButton(Icons.add, () {
                          updateQuantity(productId, quantity + 1);
                        }),
                      ],
                    ),
                    Text(
                      '₹${(price * quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_item') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShopScreen()),
                );
              } else if (value == 'delete') {
                deleteItem(productId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_item',
                child: Text('Add Item'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete from the list'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 33,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 19,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
