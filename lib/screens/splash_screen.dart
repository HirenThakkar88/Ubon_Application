import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/admin/admin_dashboard_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 7), _navigateBasedOnState);
  }

  Future<void> _navigateBasedOnState() async {
    final prefs = await SharedPreferences.getInstance();

    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      final email = prefs.getString('email');
      final uid = prefs.getString('uid');
      final admin = prefs.getString('admin');

      if (email != null && uid != null) {
        if (admin == "true") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve screen dimensions
    final size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation with responsive dimensions
            Lottie.asset(
              'assets/animations/splash.json',
              width: width * 0.6, // 60% of the screen width
              height: height * 0.3, // 30% of the screen height
              fit: BoxFit.contain,
            ),
            SizedBox(height: height * 0.02), // Spacing based on screen height
            Text(
              "Welcome to Shree Marketing...",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Lora",
                fontWeight: FontWeight.bold,
                fontSize: width * 0.055, // Font size based on screen width
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
