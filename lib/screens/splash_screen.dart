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
    Future.delayed(Duration(seconds: 7),
        _navigateBasedOnState
    ); // Adjust delay if needed
  }

  Future<void> _navigateBasedOnState() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it is the user's first time
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      // Set `isFirstTime` to false after the first launch
      await prefs.setBool('isFirstTime', false);

      // Navigate to LoginScreen if it’s the first time
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Check if the user is already logged in
      final email = prefs.getString('email');
      final uid = prefs.getString('uid');
      final admin = prefs.getString('admin');

      if (email != null && uid != null) {
        // User is logged in, navigate to HomeScreen or AdminDashboardScreen
        if(admin == "true") {
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
        // User is not logged in, navigate to LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            Lottie.asset(
              'assets/animations/splash.json',
              width: 230,
              height: 230,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text("Welcom to Shree Marketing...",style: TextStyle(color: Colors.black,fontFamily: "Lora",fontSize: 22),)
            // const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
