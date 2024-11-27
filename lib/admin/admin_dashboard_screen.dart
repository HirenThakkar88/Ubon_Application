import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore package
import 'package:ubon_application/admin/category_screen.dart';
import 'package:ubon_application/admin_all_sceens/addProductScreen.dart';
import 'package:ubon_application/screens/firebase_Auth.dart';
import 'package:ubon_application/screens/login_screen.dart';
import 'AllOrderScreen.dart';
import 'Product_available_screen.dart';
import 'brand_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Authservice _auth = Authservice();
  int productCount = 0;  // Variable to store product count

  @override
  void initState() {
    super.initState();
    _fetchProductCount();  // Fetch product count when screen loads
  }

  // Fetch product count from Firestore
  Future<void> _fetchProductCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
      setState(() {
        productCount = snapshot.docs.length;  // Set the product count
      });
    } catch (e) {
      print("Error fetching product count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
          ),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(height: 30),
            buildDrawerItem(Icons.category, 'Dashboard', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
              );
            }),
            buildDrawerItem(Icons.category, 'Category', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryScreen()),
              );
            }),
            //buildDrawerItem(Icons.subtitles, 'Sub Category'),
            buildDrawerItem(Icons.category, 'Brands', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BrandScreen()),
              );
            }),
            buildDrawerItem(Icons.assignment, 'Orders'),
            buildDrawerItem(Icons.card_giftcard, 'Coupons'),
            buildDrawerItem(Icons.notifications, 'Notifications'),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await _auth.signout();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('email');
                await prefs.remove('uid');
                await prefs.setString('admin', "false");
                goToLogin(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Products',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddProductScreen()),
                    );
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('Add New', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildStatusCard('All Product', '$productCount Product', Colors.blue, context),  // Display dynamic count
                  buildStatusCard('Out of Stock', '0 Product', Colors.red, context),
                  buildStatusCard('Limited Stock', '0 Product', Colors.orange, context),
                  buildStatusCard('Other Stock', '1 Product', Colors.green, context),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  buildOrderTile('All Orders', 0,AllOrdersScreen()),
                  buildOrderTile('Pending Orders', 0,null),
                  buildOrderTile('Processed Orders', 0,null),
                  buildOrderTile('Cancelled Orders', 0,null),
                  buildOrderTile('Shipped Orders', 0,null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title, [Function()? onTap]) {
    return ListTile(
      leading: Icon(icon, color: Colors.pinkAccent),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget buildStatusCard(String title, String subtitle, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'All Product') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AllProductsScreen()),
          );
        }
      },
      child: Card(
        color: Color.fromARGB(255, 226, 228, 238),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.inventory, color: color, size: 40),
              Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderTile(String title, int count,Widget? screen) {
    return ListTile(
      leading: Icon(Icons.receipt_long, color: Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      trailing: Text(
        '$count Files',
        style: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }

      },
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
