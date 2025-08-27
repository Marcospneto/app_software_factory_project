import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomInputPhone extends StatefulWidget {
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
  final Color? colorText;
  final Color? colorBorder;

  const CustomInputPhone({
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
    this.colorText
  }) : super(key: key);

  @override
  State<CustomInputPhone> createState() => _CustomPhoneState();
}

class _CustomPhoneState extends State<CustomInputPhone> {
  bool _obscureText = true;

  final phoneMask = MaskTextInputFormatter(
    mask: '(##)#####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

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
            keyboardType: TextInputType.phone,
            obscureText: widget.obscureText && _obscureText,
            style: TextStyle(color: widget.colorText ?? Colors.white),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(color: widget.colorLabel ?? Colors.white),
              hintText: widget.hint,
              prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.white) : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        !_obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              border: UnderlineInputBorder(borderSide: BorderSide(color: widget.colorBorder ?? Colors.white)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.colorBorder ?? Colors.white, width: 2)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.colorBorder ?? Colors.white, width: 1)),
              errorText: widget.errorText,
              errorStyle: const TextStyle(color: Colors.white),
            ),
            validator: widget.validator,
            onChanged: widget.onChanged,
            //inputFormatters: [phoneMask],
          ),
        ],
      ),
    );
  }
}
