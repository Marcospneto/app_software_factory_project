import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/helpers/date_helper.dart';
import 'custom_button.dart';
import 'custom_date_picker.dart';

class CustomDateRangeBottomSheet extends StatefulWidget {
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final Function(DateTime start, DateTime end) onConfirm;

  const CustomDateRangeBottomSheet({
    Key? key,
    required this.startDateController,
    required this.endDateController,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<CustomDateRangeBottomSheet> createState() => _CustomDateRangeBottomSheetState();
}

class _CustomDateRangeBottomSheetState extends State<CustomDateRangeBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'Selecione o período',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomDatePicker(
              label: 'Data inicial',
              controller: widget.startDateController,
              colorLabel: Colors.black,
              colorBorder: Colors.grey,
              iconColor: MainColor.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomDatePicker(
              label: 'Data final',
              controller: widget.endDateController,
              colorLabel: Colors.black,
              colorBorder: Colors.grey,
              iconColor: MainColor.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                  child: CustomButton(
                    onPressed: () {
                      if (widget.startDateController.text.isNotEmpty &&
                          widget.endDateController.text.isNotEmpty) {
                        final start = DateHelper.parseDate(widget.startDateController.text);
                        final end = DateHelper.parseDate(widget.endDateController.text);
                        widget.onConfirm(start, end);
                        Navigator.pop(context);
                      }
                    },
                    height: 40,
                    color: MainColor.primaryColor,
                    text: 'Confirmar',
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
