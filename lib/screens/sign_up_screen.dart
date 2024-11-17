import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ubon_application/screens/firebase_Auth.dart';
import 'package:ubon_application/screens/home_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = Authservice();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 255, 255, 255),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // MediaQuery dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.08),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'XYZ',
                  textStyle: const TextStyle(fontFamily: 'Lora'),
                  controller: _fullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomTextField(
                  label: 'Email',
                  hintText: 'abcd@gmail.com',
                  textStyle: const TextStyle(fontFamily: 'Lora'),
                  controller: _emailController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@gmail.com')) {
                      return 'Your email must contain @gmail.com';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Password',
                  isPassword: true,
                  textStyle: const TextStyle(fontFamily: 'Lora'),
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 8 || value.length > 16) {
                      return 'Password must be 8-16 characters';
                    } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\W)')
                        .hasMatch(value)) {
                      return 'Password must contain at least one special character and one uppercase letter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Confirm Password',
                  isPassword: true,
                  textStyle: const TextStyle(fontFamily: 'Lora'),
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Confirm password does not match the password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: screenWidth * 0.04,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.red,
                          size: screenWidth * 0.045,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        color: Colors.black,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                Center(
                  child: Text(
                    'Or login with social account',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButton(imagePath: 'assets/images/google_icon.png'),
                    SizedBox(width: screenWidth * 0.08),
                    SocialButton(imagePath: 'assets/images/facebook_icon.png'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  goToHome(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => HomeScreen()));

  _signup() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final userType = 'regular';

    if (_formKey.currentState?.validate() ?? false) {
      final user = await _auth.createUserWithEmailAndPassword(
          email, password, fullName, userType);

      if (user != null) {
        log("User created and data saved in Firestore");
        goToHome(context);
      } else {
        log("Error creating user");
      }
    }
  }
}
