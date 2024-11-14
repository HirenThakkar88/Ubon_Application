import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ubon_application/screens/ResetPasswordPage.dart';
import 'dart:async';

import 'package:ubon_application/widgets/custom_loader.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  VerificationPage({required this.email});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String otpMap = '';
  final int _pinLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  int _remainingTime = 119;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_pinLength, (_) => TextEditingController());
    _focusNodes = List.generate(_pinLength, (_) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _remainingTime = 0;
        });
        _timer.cancel();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _remainingTime = 119;
    });
    _timer.cancel();
    _startTimer();
  }

  String get _formattedTime {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _onKeyPressed(String value) {
    if (value == 'backspace') {
      if (_currentIndex > 0) {
        setState(() {
          _controllers[_currentIndex].clear();
          _currentIndex--;
          FocusScope.of(context).requestFocus(_focusNodes[_currentIndex]);
          _controllers[_currentIndex].clear();
        });
      } else if (_currentIndex == 0) {
        setState(() {
          _controllers[_currentIndex].clear();
        });
      }
    } else if (_currentIndex < _pinLength) {
      setState(() {
        _controllers[_currentIndex].text = value;
        if (_currentIndex < _pinLength - 1) {
          _currentIndex++;
        }
        FocusScope.of(context).requestFocus(_focusNodes[_currentIndex]);
      });
    }

    otpMap = _controllers.map((controller) => controller.text).join();
    print("OTP: $otpMap");
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    _timer.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    await CustomLoader.showLoaderForTask(
        context: context,
        task: () async {
          String otp = otpMap;

          QuerySnapshot snapshot = await _firestore
              .collection('recovery')
              .where('email', isEqualTo: widget.email)
              .where('otp', isEqualTo: otp)
              .get();

          if (snapshot.docs.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(email: widget.email),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid OTP',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Verification",
          style: TextStyle(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            fontSize: screenHeight * 0.025,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_rounded,
            size: screenHeight * 0.03,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.03),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter your Verification Code",
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.025,
                        color: Color.fromRGBO(0, 0, 0, 80),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _pinLength,
                      (index) => _buildPinBox(index, screenHeight, screenWidth),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  if (_remainingTime > 0)
                    Text(
                      _formattedTime,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.025,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    )
                  else
                    TextButton(
                      onPressed: () {
                        _resetTimer();
                      },
                      child: Text(
                        "Send code again",
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.02,
                          color: const Color(0xFFFFCC00),
                        ),
                      ),
                    ),
                  SizedBox(height: screenHeight * 0.01),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "We sent a verification code to your email",
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.02,
                        color: Colors.black54,
                      ),
                      children: const <TextSpan>[
                        TextSpan(
                          text: '\nhpopa*****@gmail.com',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontWeight: FontWeight.bold,
                            color:  Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        TextSpan(
                          text: '. You can check your inbox.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  ElevatedButton(
                    onPressed: _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      padding:
                          EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Verify",
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.025,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            _buildCustomKeyboard(screenHeight, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildPinBox(int index, double screenHeight, double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.12,
      height: screenHeight * 0.06,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        readOnly: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.bold,
          fontSize: screenHeight * 0.03,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              width: 2.0,
              color: Color.fromRGBO(255, 249, 61, 1),
            ),
          ),
          filled: true,
          fillColor: Color.fromARGB(255, 245, 244, 244),
          contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        ),
      ),
    );
  }

  Widget _buildCustomKeyboard(double screenHeight, double screenWidth) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return _buildKeyboardButton(
                label: '${index + 1}', screenHeight: screenHeight);
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return _buildKeyboardButton(
                label: '${index + 4}', screenHeight: screenHeight);
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return _buildKeyboardButton(
                label: '${index + 7}', screenHeight: screenHeight);
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeyboardButton(label: 'backspace', screenHeight: screenHeight),
            _buildKeyboardButton(label: '0', screenHeight: screenHeight),
            _buildKeyboardButton(label: '', screenHeight: screenHeight),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboardButton(
      {required String label, required double screenHeight}) {
    return InkWell(
      onTap: label.isNotEmpty ? () => _onKeyPressed(label) : null,
      child: Container(
        width: screenHeight * 0.1,
        height: screenHeight * 0.1,
        alignment: Alignment.center,
        child: label == 'backspace'
            ? Icon(Icons.backspace_outlined)
            : Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.03,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}
