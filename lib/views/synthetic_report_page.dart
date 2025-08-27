import 'package:flutter/material.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/widgets/custom_menu.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/services/report_service.dart';
import 'package:meu_tempo/models/pie_chart_data.dart';

class SyntheticReportPage extends StatefulWidget {
  const SyntheticReportPage({super.key});

  @override
  State<SyntheticReportPage> createState() => _SyntheticPageState();
}

class _SyntheticPageState extends State<SyntheticReportPage> {
  int touchedIndex = -1;
  final ReportService reportService = ReportService();
  List<CustomPieChartData> pieSections = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      isLoading = true;
    });

  try {
    final result = await reportService.fetchTasksPieChart();
    setState(() {
      pieSections = result;
    });
  } catch (e) {
    print('Erro ao carregar dados: $e');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Estatísticas',
         leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Visão Geral',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: MainColor.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 20),
            
            SizedBox(
                height: 420,
                child: Center(
                  child: isLoading
                    ? CircularProgressIndicator()
                    : pieSections.isEmpty
                      ? Text('Nenhum dado disponível')
                      : PieChart(
                        PieChartData(
                          sections: piechartSection(),
                          sectionsSpace: 0,
                          centerSpaceRadius: 0,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = response.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                        ),
                      ),
                ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: CustomButton(
                width: 200,
                icon: Icons.add,
                text: 'Detalhes',
                textPadding: EdgeInsets.only(left: 25),
                textColor: Colors.white,
                color: MainColor.primaryColor,
                fontWeight: FontWeight.w900,
                iconPosition: Positioned(
                  top: 11,
                  left: 0,
                  right: 75,
                  child: Icon(
                    Icons.add,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                   Navigator.pushNamed(context, AppRoutes.analyticalReport);
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: CustomMenu(),
    );
  }
  List<PieChartSectionData> piechartSection() {
    return List.generate(pieSections.length, (index) {
      final data = pieSections[index];
      final isTouched = index == touchedIndex;
      final double radius = isTouched ? 140 : 130;

      return PieChartSectionData(
        color: data.color,
        value: data.value,
        radius: radius,
        title: '${data.title}\n${data.value.toInt()}%',
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: data.color,
        ),
        titlePositionPercentageOffset: 1.3,
      );
    });
  }
}