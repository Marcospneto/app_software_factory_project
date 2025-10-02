import 'package:flutter/material.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/services/secure_storage_service.dart';
import 'package:meu_tempo/widgets/custom_button.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<StatefulWidget> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  var storageService = SecureStorageService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double pageWidth = MediaQuery
        .of(context)
        .size
        .width;
    double pageHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MainColor.primaryColor,
                  MainColor.secondaryColor,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              )),
          child: Center(
            child: Text(
              'Meu Tempo',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: pageWidth * 0.13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Comfortaa'
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: MainColor.primaryColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: CustomButton(
                        text: 'Entrar',
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.login);
                        },
                        color: Colors.white,
                        textColor: MainColor.primaryColor,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomButton(
                        text: 'Cadastre-se',
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.signin);
                        }),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Espaço entre os botões e o texto
              Text(
                'Direitos Autorais',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Centraliza o texto
              ),
              Text(
                'Grupo Arruda Paes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center, // Centraliza o texto
              ),
            ],
          ),
        ));
  }
}
