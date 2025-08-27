import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? icon;
  final double? width;
  final String? errorText;
  final Function(String?)? onChanged;
  final String? fieldName;
  final String? Function(String?)? validator;
  final Color? colorLabel;
  final Color? colorBorder;
  final Color? colorText;
  final Color? colorError;
  final Color? colorIcon;
  final int? maxLength;

  const CustomInput({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.icon,
    this.width,
    this.errorText,
    this.onChanged,
    this.fieldName,
    this.validator,
    this.colorBorder,
    this.colorLabel,
    this.colorText,
    this.colorError,
    this.maxLength,
    this.colorIcon,
  }) : super(key: key);

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormBuilderTextField(
            name: widget.fieldName!.toLowerCase(),
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText && _obscureText,
            style: TextStyle(color: widget.colorText ?? Colors.white),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(color: widget.colorLabel ?? Colors.white),
              hintText: widget.hint,
              prefixIcon: widget.icon != null
                  ? Icon(widget.icon, color: Colors.white)
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        !_obscureText ? Icons.visibility : Icons.visibility_off,
                        color: widget.colorIcon ?? Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              counterStyle: TextStyle(color: MainColor.primaryColor),
              border: const UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.colorBorder ?? Colors.white, width: 1)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.colorBorder ?? Colors.white, width: 1)),
              errorText: widget.errorText,
              errorMaxLines: 2,
              errorStyle: TextStyle(
                color: widget.colorError ?? Colors.white,
                fontSize: 14,
                overflow: TextOverflow.visible,
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.red)
              ),
              focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.red)
              ),
            ),
            validator: widget.validator,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
