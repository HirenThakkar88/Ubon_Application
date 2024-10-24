import 'package:flutter/material.dart';
import 'package:ubon_application/screens/payment_method_screen.dart';
import 'package:ubon_application/widgets/custom_bottom_nav_bar.dart';

import 'ShippingAddressScreen.dart';

class ProfileScreen extends StatelessWidget {
  int _selectedIndex = 4;
  // const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'My profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Add search functionality here
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                      'assets/images/profile_pic.png'), // Replace with your image
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hiren Thakkar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'hpopat503@rku.ac.in',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                _buildProfileOption(
                  context: context,
                  title: 'My orders',
                  subtitle: 'Already have 12 orders',
                  icon: Icons.list_alt,
                  onTap: () {
                    // Navigate to My Orders page
                  },
                ),
                _buildProfileOption(
                  context: context,
                  title: 'Shipping addresses',
                  subtitle: '3 addresses',
                  icon: Icons.location_on_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShippingAddressScreen()),
                    ); // Navigate to Shipping Addresses page
                  },
                ),
                _buildProfileOption(
                  context: context,
                  title: 'Payment methods',
                  subtitle: 'Visa **34',
                  icon: Icons.credit_card_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentMethodsScreen()),
                    ); //
                    // Navigate to Payment Methods page
                  },
                ),
                _buildProfileOption(
                  context: context,
                  title: 'Promocodes',
                  subtitle: 'You have special promocodes',
                  icon: Icons.local_offer_outlined,
                  onTap: () {
                    // Navigate to Promocodes page
                  },
                ),
                _buildProfileOption(
                  context: context,
                  title: 'My reviews',
                  subtitle: 'Reviews for 4 items',
                  icon: Icons.star_outline,
                  onTap: () {
                    // Navigate to My Reviews page
                  },
                ),
                _buildProfileOption(
                  context: context,
                  title: 'Settings',
                  subtitle: 'Notifications, password',
                  icon: Icons.settings_outlined,
                  onTap: () {
                    // Navigate to Settings page
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      onTap: onTap,
    );
  }
}
