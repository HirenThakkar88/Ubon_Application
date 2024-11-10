import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/screens/firebase_Auth.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import 'forgot_password.dart'; // Import the forgot password screen
import 'home_screen.dart';
import 'sign_up_screen.dart'; // Import the sign-up screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Authservice _auth = Authservice();
  bool isLoading = false;
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome configurations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 255, 255, 255),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 85)),
              const SizedBox(height: 20),
              const Text('Login',
                  style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              CustomTextField(
                  label: 'Email',
                  hintText: 'abcd@gmail.com',
                  textStyle: const TextStyle(fontFamily: 'Lora'),
                  controller: _email),
              const SizedBox(height: 20),
              CustomTextField(
                  label: 'Password',
                  hintText: 'Password',
                  isPassword: true,
                  textStyle: const TextStyle(fontFamily: 'Lora'),
                  controller: _password),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen()));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Forgot your password?',
                          style: TextStyle(
                              fontFamily: 'Lora',
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      const Icon(Icons.arrow_forward,
                          color: Colors.red, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('LOGIN',
                        style: TextStyle(
                            fontFamily: 'Lora',
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignUpScreen()));
                  },
                  child: const Text("Don't have an account? Sign up here",
                      style: TextStyle(
                          fontFamily: 'Lora',
                          color: Colors.blue,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 120),
              const Center(
                  child: Text('Or login with social account',
                      style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 16,
                          fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () async {
                        await _auth.signInWithGoogle();
                      },
                      child: const SocialButton(
                          imagePath: 'assets/images/google_icon.png')),
                  const SizedBox(width: 30),
                  const SocialButton(
                      imagePath: 'assets/images/facebook_icon.png'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      // Show a SnackBar for empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Prevent further action if fields are empty
    }

    // Simple email validation regex
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(_email.text)) {
      // Show SnackBar for invalid email format
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user =
        await _auth.LoginUserWithEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      log("Login Successful");

      // Save login state to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Navigate to home screen
      goToHome(context);
    } else {
      log("Login failed");
      // Show 'Not Registered' message in SnackBar for 2 seconds
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Not Registered',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 2), // Show for 2 seconds
        ),
      );
    }
  }

  void goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }
}
