import 'package:flutter/material.dart';
import 'package:meu_tempo/enums/period_type.dart';
import 'package:meu_tempo/widgets/custom_button_square.dart';
import 'package:meu_tempo/config/main_color.dart';

class PeriodFilterButton extends StatelessWidget {
  final String label;
  final PeriodType type;
  final PeriodType selectedPeriod;
  final Function(PeriodType, {DateTime? start, DateTime? end}) onPeriodChanged;

  const PeriodFilterButton({
    super.key,
    required this.label,
    required this.type,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPeriod == type;
      return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomButtonSquare(
          text: label,
          height: 50,
          backgroundColor: isSelected ? MainColor.primaryColor : Colors.grey[300]!,
          textColor: isSelected ? Colors.white : Colors.black,
          fontSize: 14,
          onPressed: () async {
            if (type == PeriodType.periodo) {
              DateTime? startDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(), 
                firstDate: DateTime(2020), 
                lastDate: DateTime.now(),
                helpText: 'Selecione a data de inicio',
                cancelText: 'Cancelar',
                confirmText: 'Proximo',
                locale: const Locale("pt", "BR"),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: MainColor.primaryColor,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: MainColor.primaryColor,
                        ),
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                }
              );
              if (startDate != null) {
                DateTime? endDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(), 
                  firstDate: startDate, 
                  lastDate: DateTime.now(),
                  helpText: 'Selecione a data final',
                  cancelText: 'Cancelar',
                  confirmText: 'Confirmar',
                  locale: const Locale("pt", "BR"),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: MainColor.primaryColor,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: MainColor.primaryColor,
                          ),
                        ),
                        dialogBackgroundColor: Colors.white,
                      ),
                      child: child!,
                    );
                  }
                );
                if (endDate != null) {
                  onPeriodChanged(type, start: startDate, end: endDate);
                }
              }
            } else  {
              onPeriodChanged(type);
            }
          },
        ),
      ),
    );
  }
}