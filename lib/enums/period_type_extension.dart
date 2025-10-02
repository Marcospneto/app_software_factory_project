import 'period_type.dart';

extension PeriodTypeExtension on PeriodType {
  String get title {
    switch (this) {
      case PeriodType.dia:
        return 'Tempo diário';
      case PeriodType.semana:
        return 'Tempo semanal';
      case PeriodType.mes:
        return 'Tempo mensal';
      case PeriodType.periodo:
        return 'Tempo por período';
    }
  }

  String get label {
    switch (this) {
      case PeriodType.dia:
        return 'neste dia';
      case PeriodType.semana:
        return 'nesta semana';
      case PeriodType.mes:
        return 'neste mês';
      case PeriodType.periodo:
        return 'no período selecionado';
    }
  }
}