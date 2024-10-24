import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String imagePath;

  const SocialButton({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          imagePath,
          height: 40,
          width: 40,
        ),
      ),
    );
  }
}
