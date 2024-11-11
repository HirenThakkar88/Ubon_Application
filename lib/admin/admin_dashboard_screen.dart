import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/screens/firebase_Auth.dart';
import 'package:ubon_application/screens/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Authservice _auth = Authservice();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontFamily: 'Lora', // Apply Lora font family
            fontWeight: FontWeight.bold, // Apply bold font weight
            color: Colors.black, // Set text color to black
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'), // Placeholder profile image
          ),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(height: 30),
            buildDrawerItem(Icons.dashboard, 'Dashboard'),
            buildDrawerItem(Icons.category, 'Category'),
            buildDrawerItem(Icons.subtitles, 'Sub Category'),
            buildDrawerItem(Icons.branding_watermark, 'Brands'),
            buildDrawerItem(Icons.assignment, 'Orders'),
            buildDrawerItem(Icons.card_giftcard, 'Coupons'),
            buildDrawerItem(Icons.notifications, 'Notifications'),
            const Divider(),
      ListTile(
        leading: Icon(Icons.logout, color: Colors.red),
        title: Text('Sign Out', style: TextStyle(color: Colors.red)),
        onTap:  ()async {
                                await _auth.signout();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('email');
                                await prefs.remove('uid');
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
            // "My Products" Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Products',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black, // Set text color to black
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add New',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Product Status Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildStatusCard('All Product', '1 Product', Colors.blue),
                  buildStatusCard('Out of Stock', '0 Product', Colors.red),
                  buildStatusCard('Limited Stock', '0 Product', Colors.orange),
                  buildStatusCard('Other Stock', '1 Product', Colors.green),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Orders Details Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black, // Set text color to black
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  buildOrderTile('All Orders', 0),
                  buildOrderTile('Pending Orders', 0),
                  buildOrderTile('Processed Orders', 0),
                  buildOrderTile('Cancelled Orders', 0),
                  buildOrderTile('Shipped Orders', 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.pinkAccent),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.bold,
          color: Colors.black, // Set text color to black
        ),
      ),
      onTap: () {},
    );
  }

  Widget buildStatusCard(String title, String subtitle, Color color) {
    return Card(
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
                color: Colors.black, // Set text color to black
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderTile(String title, int count) {
    return ListTile(
      leading: Icon(Icons.receipt_long, color: Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.bold,
          color: Colors.black, // Set text color to black
        ),
      ),
      trailing: Text(
        '$count Files',
        style: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.bold,
          color: Colors.black, // Set text color to black
        ),
      ),
      onTap: () {},
    );
  }
    void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
