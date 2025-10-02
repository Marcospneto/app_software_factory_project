import 'package:flutter/material.dart';

class CustomButtonSquare extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double? fontSize;
  final VoidCallback onPressed;

  const CustomButtonSquare({
    super.key,
    required this.text,
    this.width = 80,
    this.height = 50,
    this.backgroundColor = const Color(0xFF9C27B0), // Roxo padrão
    this.textColor = Colors.white,
    this.borderRadius = 10,
    this.fontSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: fontSize ?? 16,
          ),
        ),
      ),
    );
  }
}