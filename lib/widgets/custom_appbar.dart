import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? titleColor;
  final FontWeight? fontWeight;
  final Widget? customDateWidget;
  final double? height;

  const CustomAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.titleColor,
    this.fontWeight,
    this.customDateWidget,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor != null
            ? null
            : LinearGradient(
                colors: [MainColor.primaryColor, MainColor.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child:
          customDateWidget != null ? _buildStackLayout() : _buildSimpleLayout(),
    );
  }

  Widget _buildSimpleLayout() {
    return AppBar(
      title: Text(
        title ?? '',
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontWeight: fontWeight ?? FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }

  Widget _buildStackLayout() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: actions,
          leading: leading,
          automaticallyImplyLeading: false,
        ),
        Positioned(
          top: 1, // Ajuste este valor para o posicionamento vertical
          child: customDateWidget!,
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    final double defaultHeight = customDateWidget != null ? 110.0 : 56.0;
    return Size.fromHeight(height ?? defaultHeight);
  }
}
