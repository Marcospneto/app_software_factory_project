import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomDatePicker extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final Color? colorLabel;
  final Color? colorBorder;
  final Color? iconColor;
  final String? Function(String?)? validator;

  const CustomDatePicker({
    Key? key,
    required this.label,
    required this.controller,
    this.colorLabel,
    this.colorBorder,
    this.iconColor,
    this.hint,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          setState(() {
            widget.controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.controller,
          style: TextStyle(color: MainColor.primaryColor),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(color: widget.colorLabel ?? Colors.white),
            hintText: widget.hint,
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: widget.colorBorder ?? Colors.white, width: 1)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: widget.colorBorder ?? Colors.white, width: 1)),
            suffixIcon: Icon(
              Icons.calendar_month,
              color: widget.iconColor ?? Colors.white,
            ),
            errorStyle: TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}
