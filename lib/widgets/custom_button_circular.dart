import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomButtonCircular extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? iconColor;
  final double? width;
  final double? height;
  final VoidCallback onPressed;

  const CustomButtonCircular({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.iconColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width ?? 40,
        height: height ?? 40,
        decoration: BoxDecoration(
          color: color ?? MainColor.secondaryColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: onPressed,
          color: color ?? MainColor.secondaryColor,
          icon: Icon(
            icon,
            color: iconColor ?? Colors.white,
          ),
        ));
  }
}
