import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? userName;
  String? userEmail;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool isEditingName = false;

  // Notification Switch States
  bool sales = true;
  bool newArrivals = false;
  bool deliveryStatusChanges = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid'); // Assuming 'uid' is saved in prefs

    if (authId != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('authentication')
            .where('auth_id', isEqualTo: authId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          setState(() {
            userName = userDoc['name'];
            userEmail = userDoc['email'];
            _nameController.text = userName ?? '';
            _emailController.text = userEmail ?? '';
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('uid');

    if (authId != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('authentication')
            .where('auth_id', isEqualTo: authId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.update({'name': newName});
          setState(() {
            userName = newName;
            isEditingName = false;
          });
        }
      } catch (e) {
        print('Error updating user name: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Personal Information Section
            Text(
              'Personal Information',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Editable Name Field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    enabled: isEditingName,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(isEditingName ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (isEditingName) {
                      if (_nameController.text.trim().isNotEmpty) {
                        updateUserName(_nameController.text.trim());
                      }
                    } else {
                      setState(() {
                        isEditingName = true;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            // Dynamic Email Field (Read-only)
            TextFormField(
              controller: _emailController,
              enabled: false, // Email field is read-only
              decoration: InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Password Section
            Text(
              'Password',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              obscureText: true,
              initialValue: '*******',
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  ForgotPasswordPage()),
                  );
                  // Navigate to Change Password Screen
                },
                child: Text('Change', style: TextStyle(color: Colors.grey)),
              ),
            ),
            SizedBox(height: 20),

            // Notifications Section
            Text(
              'Notifications',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text('Sales'),
              value: sales,
              onChanged: (bool value) {
                setState(() {
                  sales = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('New arrivals'),
              value: newArrivals,
              onChanged: (bool value) {
                setState(() {
                  newArrivals = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Delivery status changes'),
              value: deliveryStatusChanges,
              onChanged: (bool value) {
                setState(() {
                  deliveryStatusChanges = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
