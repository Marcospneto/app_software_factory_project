import 'package:flutter/material.dart';
import 'package:meu_tempo/enums/period_type.dart';
import 'package:meu_tempo/widgets/period_filter_button.dart';

class PeriodFilterSelectRow extends StatelessWidget{
  final PeriodType selectedPeriod;
  final Function(PeriodType, {DateTime? start, DateTime? end}) onPeriodChanged;

  const PeriodFilterSelectRow({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PeriodFilterButton(
          label: 'DIA', 
          type: PeriodType.dia, 
          selectedPeriod: selectedPeriod, 
          onPeriodChanged: onPeriodChanged
        ),
        PeriodFilterButton(
          label: 'SEMANA', 
          type: PeriodType.semana, 
          selectedPeriod: selectedPeriod, 
          onPeriodChanged: onPeriodChanged
        ),
        PeriodFilterButton(
          label: 'MÊS', 
          type: PeriodType.mes, 
          selectedPeriod: selectedPeriod, 
          onPeriodChanged: onPeriodChanged
        ),
        PeriodFilterButton(
          label: 'PERÍODO', 
          type: PeriodType.periodo, 
          selectedPeriod: selectedPeriod, 
          onPeriodChanged: onPeriodChanged
        ),   
      ],
    );
  }
}