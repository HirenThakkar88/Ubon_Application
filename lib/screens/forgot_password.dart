import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import SystemChrome

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isEmailValid = true;
  bool _isEmailEmpty = false;
  bool _isTyping = false;

  // Email validation function
  bool _validateEmail(String email) {
    if (email.isEmpty) {
      setState(() {
        _isEmailEmpty = true;
      });
      return false;
    }

    // Simple email validation and checks if email ends with @gmail.com
    bool isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email) && email.endsWith('@gmail.com');
    setState(() {
      _isEmailValid = isValid;
      _isEmailEmpty = false;
    });
    return isValid;
  }

  void _clearEmail() {
    _emailController.clear(); // Clear the email input
    setState(() {
      _isEmailValid = true; // Reset email validation to valid (black border)
      _isEmailEmpty = false;
      _isTyping = false; // Reset typing status when cleared
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // Adjust for padding from top
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Forgot password',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please, enter your email address. You will receive a link to create a new password via email.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontFamily: 'Lora',
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: _isTyping ? FontWeight.bold : FontWeight.normal, // Input text becomes bold when typing
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: _isEmailValid && !_isEmailEmpty
                        ? Colors.black // Black if valid or no input yet
                        : Colors.redAccent, // Red if invalid
                    fontFamily: 'Lora',
                  ),
                  hintText: 'your@email.com',
                  hintStyle: const TextStyle(
                    color: Colors.black45,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.normal, // Ensure hint text remains normal
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isEmailValid && !_isEmailEmpty
                          ? Colors.grey // Black if valid
                          : Colors.redAccent, // Red if invalid
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isEmailValid && !_isEmailEmpty
                          ? Colors.grey // Black if valid
                          : Colors.redAccent, // Red if invalid
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: _emailController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: _clearEmail, // Clear email when close icon is tapped
                  )
                      : null,
                ),
                onChanged: (text) {
                  setState(() {
                    _isTyping = text.isNotEmpty; // Set to true when input is not empty
                    if (text.isEmpty) _isEmailValid = true;
                  });
                },
              ),
              const SizedBox(height: 10),
              if (!_isEmailValid && !_isEmailEmpty) // Show error only when email is invalid
                const Text(
                  'Email must end with @gmail.com',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontFamily: 'Lora',
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Check if email is valid when SEND button is pressed
                    if (_validateEmail(_emailController.text)) {
                      print('Email is valid, proceed to send reset link');
                      // Implement your sending logic here
                    } else {
                      print('Invalid email entered');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFFCC00), // Using your preferred button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'SEND',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
