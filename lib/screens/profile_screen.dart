import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/screens/firebase_Auth.dart';
import 'package:ubon_application/screens/login_screen.dart';
import 'package:ubon_application/screens/payment_method_screen.dart';
import 'package:ubon_application/screens/setting_screen.dart';
import 'package:ubon_application/screens/trackOrderScreen.dart';
import 'package:ubon_application/widgets/custom_bottom_nav_bar.dart';
import 'ShippingAddressScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4;
  Authservice _auth = Authservice();
  String? userName;
  String? userEmail;
  String? profileImageUrl;
  int addressCount = 0;
  int orderCount = 0; //

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchAddressCount(); //
    fetchOrderCount();
    // fetchorderCount(); // Fetch the user's order count
  }
  void fetchAddressCount() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');

    if (authId != null) {
      try {
        // Fetch user document directly using the 'auth_id'
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('authentication')
            .doc(authId) // Directly access the document using the auth_id
            .get(); // Fetch the document

        // Debug: print the entire document data to check the structure
        print('User Document Data: ${userDoc.data()}');

        // Check if the 'addresses' field exists and is a list
        if (userDoc.exists && userDoc['addresses'] != null) {
          var addresses = userDoc['addresses'];
          if (addresses is List) {
            setState(() {
              addressCount = addresses.length; // Set address count from the list
            });
          } else {
            setState(() {
              addressCount = 0; // In case 'addresses' is not a list
            });
          }
        } else {
          setState(() {
            addressCount = 0; // No addresses available or field is missing
          });
        }
      } catch (e) {
        print('Error fetching address count: $e');
        setState(() {
          addressCount = 0; // Handle errors by setting address count to 0
        });
      }
    }
  }

  void fetchOrderCount() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid'); // Get the user's ID

    if (authId != null) {
      try {
        // Query the "orders" collection to count the user's orders
        QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('auth_id', isEqualTo: authId)
            .get();

        setState(() {
          orderCount = orderSnapshot.size; // Get the count of documents
        });
      } catch (e) {
        print('Error fetching order count: $e');
        setState(() {
          orderCount = 0; // Default to 0 in case of error
        });
      }
    }
  }


  void fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid'); // Assuming 'uid' is saved in prefs

    if (authId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('authentication')
            .where('auth_id', isEqualTo: authId)
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first);

        setState(() {
          userName = userDoc['name'];
          userEmail = userDoc['email'];
          profileImageUrl = userDoc['profileImageUrl'] ??
              'assets/images/avtar_default.png'; // Fallback to default image
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return; // User did not pick an image

    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');
    if (authId == null) return;

    try {
      final File imageFile = File(pickedFile.path);

      // Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$authId.jpg');
      await storageRef.putFile(imageFile);

      // Get the download URL of the uploaded image
      final String downloadUrl = await storageRef.getDownloadURL();

      // Update the Firestore document with the new image URL
      final userDoc = await FirebaseFirestore.instance
          .collection('authentication')
          .where('auth_id', isEqualTo: authId)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      await userDoc.reference.update({'profileImageUrl': downloadUrl});

      setState(() {
        profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      print('Error uploading profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture.')),
      );
    }
  }

  void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

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
                GestureDetector(
                  onTap: uploadProfileImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImageUrl != null &&
                        profileImageUrl!.startsWith('http')
                        ? NetworkImage(profileImageUrl!)
                        : AssetImage('assets/images/avtar_default.png')
                    as ImageProvider,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? 'Loading...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail ?? 'Loading...',
                      style: const TextStyle(
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
                  subtitle: 'Already have $orderCount  orders',
                  icon: Icons.list_alt,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  MyOrdersScreen ()),
                    );
                    // Navigate to My Orders page
                  },
                ),
                _buildProfileOption(
                  context: context,
                  title: 'Shipping addresses',
                  subtitle: '$addressCount addresses',
                  icon: Icons.location_on_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShippingAddressScreen()),
                    );
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
                    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  SettingsScreen()),
                    );
                    // Navigate to Settings page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Sign Out'),
                          content:
                          const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () async {
                                await _auth.signout();
                                final prefs =
                                await SharedPreferences.getInstance();
                                await prefs.remove('email');
                                await prefs.remove('uid');
                                goToLogin(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
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
