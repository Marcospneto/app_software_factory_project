import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meu_tempo/models/pie_chart_data.dart';

class PieChartSection extends StatelessWidget {
  final List<CustomPieChartData> data;
  final int touchedIndex;
  final Function(int index) onTouch;

  const PieChartSection({
    required this.data,
    required this.touchedIndex,
    required this.onTouch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: List.generate(data.length, (index) {
          final d = data[index];
          final isTouched = index == touchedIndex;
          return PieChartSectionData(
            color: d.color,
            value: d.value,
            radius: isTouched ? 120 : 110,
            title: '${d.title} ${d.value.toInt()}%',
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: d.color,
            ),
            titlePositionPercentageOffset: 1.4,
          );
        }),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.touchedSection == null) {
              onTouch(-1);
            } else {
              onTouch(response.touchedSection!.touchedSectionIndex);
            }
          },
        ),
      ),
    );
  }
}
