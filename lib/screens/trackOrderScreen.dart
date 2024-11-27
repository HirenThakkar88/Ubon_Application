import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  int _selectedTabIndex = 0; // For filtering tabs
  final List<String> _tabs = ["Delivered", "Processing", "Cancelled"];
  List<Map<String, dynamic>> _orders = []; // To hold orders fetched from Firestore
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
    _fetchOrders();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid'); // Get logged-in user ID

    if (authId != null) {
      // Fetch orders for the logged-in user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('auth_id', isEqualTo: authId)
          .get();

      setState(() {
        _orders = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "orderId": data['orderId'] ?? '',
            "tracking": data['trackingNumber'] ?? '',
            "quantity": (data['orderItems'] as List<dynamic>).length,
            "totalPrice": data['totalPrice'] ?? 0,
            "status": data['orderStatus'] ?? '',
            "createdAt": (data['createdAt'] as Timestamp).toDate().toString(),
          };
        }).toList();
      });
    }
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrdersList(String statusFilter) {
    final filteredOrders = _orders.where((order) {
      return order["status"] == statusFilter;
    }).toList();

    if (filteredOrders.isEmpty) {
      return Center(child: Text("No orders found"));
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Order ${order["orderId"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      order["createdAt"],
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "Tracking number: ${order["tracking"].isNotEmpty ? order["tracking"] : "Pending"}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Quantity: ${order["quantity"]}"),
                    Text(
                      "Total Amount: \₹${order["totalPrice"]}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    order["status"],
                    style: TextStyle(
                      color: order["status"] == "Delivered"
                          ? Colors.green
                          : order["status"] == "Processing"
                          ? Colors.orange
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                OutlinedButton(
                  onPressed: () {},
                  child: Text("Details"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              children: [
                _buildOrdersList("Delivered"),
                _buildOrdersList("Pending"),
                _buildOrdersList("Cancelled"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
