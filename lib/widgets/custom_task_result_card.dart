import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/helpers/date_helper.dart';

class CustomTaskResultCard extends StatefulWidget {
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final Color? borderColor;
  final Color? cardColor;
  final Function(bool)? onSelectionChanged;
  final bool isSelected;

  const CustomTaskResultCard({
    super.key,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.borderColor,
    this.cardColor,
    this.onSelectionChanged,
    this.isSelected = false,
  });

  @override
  State<CustomTaskResultCard> createState() => _CustomTaskResultCardState();
}

class _CustomTaskResultCardState extends State<CustomTaskResultCard> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant CustomTaskResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      setState(() {
        _isChecked = widget.isSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateHelper.parseDateSaved(widget.date);
    final dateParsed = DateHelper.formatDate(date);
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: widget.cardColor ?? MainColor.colorCard,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 1.3,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 5.0,
                  ),
                  child: Checkbox(
                    value: _isChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isChecked = newValue ?? false;
                        if (widget.onSelectionChanged != null) {
                          widget.onSelectionChanged!(_isChecked);
                        }
                      });
                    },
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                      return Colors.white;
                    }),
                    checkColor: MainColor.primaryColor,
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        dateParsed,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        widget.startTime,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'às',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        widget.endTime,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 30.0,
            height: 90.0,
            decoration: BoxDecoration(
              color: widget.borderColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
