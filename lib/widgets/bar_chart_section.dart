import 'package:flutter/material.dart';
import 'package:meu_tempo/models/bar_chart_data.dart';
import 'package:meu_tempo/config/main_color.dart';

class BarChartSection extends StatelessWidget {
  final List<CustomBarChartData> data;

  const BarChartSection({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((item) {
        final taskCompleted = (item.realizadoPercentual * 100).round();
        final taskNotCompleted = (item.naoRealizadoPercentual * 100).round();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  item.categoria,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: MainColor.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: item.realizadoPercentual,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: MainColor.primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: taskCompleted > 0
                                ? Text(
                                    '$taskCompleted%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    if (taskNotCompleted > 0)
                      Positioned(
                        right: 10,
                        top: 2,
                        child: Text(
                          '$taskNotCompleted%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
