import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final Color? borderColor;
  final bool enabled;
  final IconData? icon;
  final FontWeight? fontWeight;
  final Color? iconColor;
  final double? fontSize;
  final double? iconSize;
  final Widget? iconPosition;
  final Alignment textAlignment;
  final EdgeInsets? textPadding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.borderColor,
    this.enabled = true,
    this.icon,
    this.fontWeight,
    this.iconColor,
    this.fontSize,
    this.iconSize,
    this.iconPosition, 
    this.textAlignment = Alignment.center,
    this.textPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? MainColor.secondaryColor,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: Stack(
          children: [
            Align(
              alignment: textAlignment,
              child: Padding(
                padding: textPadding ?? EdgeInsets.zero,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? 16,
                    fontWeight: fontWeight ?? FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (icon != null)
              iconPosition ??
              Positioned(
                right: 5,
                top: 11,
                child: Icon(
                  icon,
                  size: iconSize ?? 26,
                  color: iconColor ?? Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
