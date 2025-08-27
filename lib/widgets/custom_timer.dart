import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:meu_tempo/models/type_code.dart';
import 'package:meu_tempo/services/activation_code_service.dart';

class CustomTimer extends StatefulWidget {
  final String email;
  final String typeCode;

  const CustomTimer({
    super.key,
    required this.email,
    required this.typeCode,
  });

  @override
  State<CustomTimer> createState() => _CustomTimerState();
}

class _CustomTimerState extends State<CustomTimer> {
  int endTime =
      DateTime.now().millisecondsSinceEpoch + 10 * 60 * 1000; // 10 minutos
  bool isButtonEnabled = false;

  ActivationCodeService activationCodeService = ActivationCodeService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CountdownTimer(
          endTime: endTime,
          onEnd: () {
            setState(() {
              isButtonEnabled = true; // Habilita o botão quando o tempo acaba
            });
          },
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          widgetBuilder: (_, CurrentRemainingTime? time) {
            if (time == null || (time.min == 0 && time.sec == 0)) {
              return Text(
                '00:00',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }
            return Text(
              '${time.min ?? 0}:${time.sec?.toString().padLeft(2, '0') ?? '00'}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
        SizedBox(height: 20),
        if (!isButtonEnabled)
          Text(
            'Reenvio disponível em instantes.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (isButtonEnabled)
          TextButton(
            child: Text(
              'Reenviar Código',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              activationCodeService.sendCode(widget.email, widget.typeCode);
              setState(() {
                isButtonEnabled = false; // Desabilita o botão novamente
                endTime = DateTime.now().millisecondsSinceEpoch +
                    10 * 60 * 1000; // Reinicia o timer para 10 minutos
              });
            },
          ),
      ],
    );
  }
}
