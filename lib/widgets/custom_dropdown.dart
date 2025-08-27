import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final List<T>? option;
  final T? selectedValue;
  final Function(T?)? onChanged;
  final Color? colorLabel;
  final Color? colorBorder;
  final Color? colorText;
  final String? errorText;
  final String? Function(T?)? validator;
  final double? width;
  final String? fieldName;
  final String Function(T)? itemAsString;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.option,
    required this.controller,
    this.selectedValue,
    this.onChanged,
    this.colorLabel,
    this.colorBorder,
    this.colorText,
    this.hint,
    this.validator,
    this.errorText,
    this.width,
    this.fieldName,
    this.itemAsString,
  }) : super(key: key);

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<T>(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            value: widget.selectedValue,
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(color: widget.colorLabel ?? Colors.white),
              hintText: widget.hint,
              hintStyle: TextStyle(color: widget.colorText ?? Colors.white),
              border: const UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: widget.colorBorder ?? Colors.white, width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: widget.colorBorder ?? Colors.white, width: 1),
              ),
              errorText: widget.errorText,
              errorMaxLines: 2,
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                overflow: TextOverflow.visible,
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
            ),
            items: widget.option?.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  widget.itemAsString != null
                      ? widget.itemAsString!(item)
                      : item.toString(),
                  style: TextStyle(
                      color: widget.colorText ?? MainColor.primaryColor,
                      fontWeight: FontWeight.normal),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  widget.controller.text = widget.itemAsString != null
                      ? widget.itemAsString!(value)
                      : value.toString();
                } else {
                  widget.controller.text = '';
                }

                widget.onChanged?.call(value);
              });
            },
            validator: widget.validator,
            iconEnabledColor: MainColor.primaryColor,
            style: TextStyle(color: widget.colorText ?? Colors.white),
          ),
        ],
      ),
    );
  }
}
