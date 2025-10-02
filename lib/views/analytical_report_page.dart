import 'package:flutter/material.dart';
import 'package:meu_tempo/models/bar_chart_data.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/services/report_service.dart';
import 'package:meu_tempo/models/pie_chart_data.dart';
import 'package:meu_tempo/enums/period_type.dart';
import 'package:meu_tempo/widgets/period_filter_select_row.dart';
import 'package:meu_tempo/widgets/bar_chart_section.dart';
import 'package:meu_tempo/widgets/pie_chart_section.dart';
import 'package:meu_tempo/enums/period_type_extension.dart';

class AnalyticalReportPage extends StatefulWidget {
  const AnalyticalReportPage({super.key});

  @override
  State<AnalyticalReportPage> createState() => _AnalyticalReportPageState();
}

class _AnalyticalReportPageState extends State<AnalyticalReportPage> {
  int touchedIndex = -1;
  
  List<CustomBarChartData> barChartData = [];
  List<CustomPieChartData> pieChartData = [];

  PeriodType selectedPeriod = PeriodType.dia;
  bool isLoading= false;

  Future<void> _loadPieChartData(PeriodType periodType, {DateTime? start, DateTime? end}) async {
    final data = await ReportService().fetchTasksPieChart(
      periodType: periodType,
      start: start,
      end: end,
    );
    
    setState(() {
      pieChartData = data;
    });
  }

   Future<void> _loadBarChartData(PeriodType periodType, {DateTime? start, DateTime? end}) async {
    final data = await ReportService().fetchTasksBarChart(
      periodType: periodType,
      start: start,
      end: end,
    );

    setState(() {
      barChartData = data;
    });
  }

  bool taskRealizadaBarChart(List<CustomBarChartData> data) {
    return data.any((item) => item.realizadoPercentual > 0);
  }

  bool taskRealizadaPieChart(List<CustomPieChartData> data) {
    return data.any((item) => item.value > 0);
  }

  @override
  void initState() {
    super.initState();
    _loadPieChartData(PeriodType.dia);
    _loadBarChartData(PeriodType.dia);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PeriodFilterSelectRow(
              selectedPeriod: selectedPeriod,
              onPeriodChanged: (type, {start, end}) async {
                setState(() {
                  selectedPeriod = type;
                  isLoading = true;
                });
                
                await Future.wait([
                  _loadPieChartData(type, start: start, end: end),
                  _loadBarChartData(type, start: start, end: end),
                ]);
                
                setState(() {
                  isLoading = false;
                });
              } 
            ),

            SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Centro de Tempo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: MainColor.primaryColor,
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: MainColor.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'REALIZADO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: MainColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(width: 16),

                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'META',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 30),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                selectedPeriod.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: MainColor.primaryColor,
                ),
              ),
            ),

            isLoading  
              ? SizedBox(height: 223, child: Center(child: CircularProgressIndicator()))
              : taskRealizadaBarChart(barChartData)
                  ? BarChartSection(data: barChartData)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Nenhuma tarefa concluída ${selectedPeriod.label} para exibição do gráfico de barras.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            
            isLoading
              ? SizedBox(
                  height: 223,
                  child: Center(child: CircularProgressIndicator()),
                )
              : taskRealizadaPieChart(pieChartData)
                ? SizedBox(
                    height: 350,
                    child: PieChartSection(
                      data: pieChartData,
                      touchedIndex: touchedIndex,
                      onTouch: (index) {
                        setState(() => touchedIndex = index);
                      },
                    ),
                  )    
                : SizedBox(
                    height: 366,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Nenhuma tarefa concluída ${selectedPeriod.label} para exibição do gráfico de pizza.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomButton(
                width: 200,
                iconSize: 20,
                icon: Icons.show_chart,
                text: 'Visão Geral',
                textPadding: EdgeInsets.only(left: 25),
                textColor: Colors.white,
                color: MainColor.primaryColor,
                fontWeight: FontWeight.w900,
                iconPosition: Positioned(
                  top: 11,
                  left: 0,
                  right: 95,
                  child: Icon(
                    Icons.show_chart,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
