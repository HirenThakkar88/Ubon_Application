import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/screens/home_screen.dart';
import 'package:ubon_application/screens/login_screen.dart';
import 'package:ubon_application/screens/firebase_Auth.dart';

import '../widgets/custom_loader.dart';

class SetPassword extends StatefulWidget {
  final String uid;

  SetPassword({required this.uid});

  @override
  _SetPasswordState createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _setPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    await CustomLoader.showLoaderForTask(
        context: context,
        task: () async {
          if (password.isNotEmpty &&
              confirmPassword.isNotEmpty &&
              password == confirmPassword) {
            try {
              // Update the password in Firestore
              await FirebaseFirestore.instance
                  .collection('authentication')
                  .doc(widget.uid)
                  .update({'password': password});

              // Fetch user details from Firestore
              final userDoc = await FirebaseFirestore.instance
                  .collection('authentication')
                  .doc(widget.uid)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data();
                if (userData != null) {
                  // Save user data to Shared Preferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('email', userData['email'] ?? '');
                  await prefs.setString('uid', userData['auth_id'] ?? '');

                  // Navigate to HomeScreen
                  goToHome(context);
                }
              }
            } catch (e) {
              print('Error while setting password: $e');
              // Show error message if there's an issue with password setting
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Error while setting password. Please try again!',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                        ),
                    )),
              );
            }
          } else {
            // Show error message if passwords do not match
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Passwords do not match or fields are empty!',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                      ),
                  )),
            );
          }
        });
  }

  // Function to navigate to HomeScreen
  void goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen height and width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Set Password",
          style: TextStyle(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          child: Icon(Icons.arrow_back_ios_rounded),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          top: screenHeight * 0.05,
          bottom: padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Set your Password.",
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              "Enter a strong password to secure your account.",
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: screenHeight * 0.02,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Set Password",
                labelStyle: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: "Retype password",
                labelStyle: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            ElevatedButton(
              onPressed: _setPassword, // Call the function to set the password
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: screenHeight * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
