import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';

class TimePicker extends StatefulWidget {
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;

  const TimePicker({
    super.key,
    required this.startTimeController,
    required this.endTimeController,
  });

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horário',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MainColor.primaryColor,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeField(context, widget.startTimeController),
            SizedBox(width: 10),
            Text('-', style: TextStyle(fontSize: 18, color: MainColor.primaryColor)),
            SizedBox(width: 10),
            _buildTimeField(context, widget.endTimeController),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField(
      BuildContext context, TextEditingController controller) {
    return Container(
      width: 120,
      child: TextField(
        controller: controller,
        style: TextStyle(color: MainColor.primaryColor),
        readOnly: true,
        onTap: () => _selectTime(context, controller),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.access_time, color: MainColor.primaryColor),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: MainColor.primaryColor)
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: MainColor.primaryColor),
          ),
        ),
      ),
    );
  }
}
