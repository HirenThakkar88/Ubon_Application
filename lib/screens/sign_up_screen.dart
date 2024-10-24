import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import SystemChrome
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SystemChrome configurations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 255, 255, 255), // Semi-transparent white
      statusBarIconBrightness: Brightness.dark, // Icon color to dark
      statusBarBrightness: Brightness.dark, // Status bar text color to dark
      systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
      systemNavigationBarIconBrightness: Brightness.light, // Navigation icons light
    ));

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                label: 'Full Name',
                hintText: 'XYZ',
                textStyle: const TextStyle(fontFamily: 'Lora'),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email',
                hintText: 'abcd@gmail.com',
                textStyle: const TextStyle(fontFamily: 'Lora'),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password',
                hintText: 'Password',
                isPassword: true,
                textStyle: const TextStyle(fontFamily: 'Lora'),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Confirm Password',
                hintText: 'Confirm Password',
                isPassword: true,
                textStyle: const TextStyle(fontFamily: 'Lora'),
              ),
              const SizedBox(height: 10),
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
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.red,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Action when the sign-up button is pressed
                    print('Sign Up button pressed!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Or login with social account',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SocialButton(imagePath: 'assets/images/google_icon.png'),
                  SizedBox(width: 30),
                  SocialButton(imagePath: 'assets/images/facebook_icon.png'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
