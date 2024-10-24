import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final TextStyle textStyle;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    required this.textStyle,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true; // Track if the password is hidden or shown

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPassword ? _obscureText : false,
      style: widget.textStyle.copyWith(fontWeight: FontWeight.bold), // Make input text bold
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        labelStyle: widget.textStyle, // Label text style
        hintStyle: widget.textStyle.copyWith(
          fontWeight: FontWeight.normal, // Ensure hint text is not bold
          color: Colors.grey,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText; // Toggle password visibility
            });
          },
        )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
