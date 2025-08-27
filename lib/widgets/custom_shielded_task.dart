import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomShieldedTask extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onToggle;

  const CustomShieldedTask({
    super.key,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Text(
            'Tarefa Blindada',
            style: TextStyle(
              color: MainColor.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isSelected ? Icons.toggle_on : Icons.toggle_off_outlined,
                  size: 40,
                  color: MainColor.primaryColor,
                ),
              ),
              Icon(
                isSelected ? Icons.lock_outline : Icons.lock_open_outlined,
                size: 30,
                color: MainColor.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}