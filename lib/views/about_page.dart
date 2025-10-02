import 'package:flutter/material.dart';
import 'package:meu_tempo/widgets/custom_appBar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sobre',
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 30),
            child: Text(
              'Proposta:',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 20, top: 20),
            child: Text(
              'A proposta do aplicativo é coordenar o seu tempo diário de forma divertida, simples e eficiente; em um app atrativo, rápido, leve e emocionante. Assim, ajudando você a executar sua agenda, otimizando o seu tempo.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 20),
            child: Text(
              'Nossas Redes:',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/meu-tempo.png',
                      width: 60,
                      height: 60,
                    ),
                    SizedBox(width: 16,),
                    InkWell(
                      onTap: () {
                        _launchURL('https://aldenirarrudapaes.com.br');
                      },
                      child: Text(
                        'www.arrudapaes.com.br',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
                child: Divider(thickness: 1,),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/facebook.png',
                      width: 60,
                      height: 60,
                    ),
                    SizedBox(width: 16,),
                    InkWell(
                      onTap: () {
                        _launchURL('https://www.facebook.com/aldenirarrudapaes');
                      },
                      child: Text(
                        '@aldenirarrudapaes',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
                child: Divider(thickness: 1,),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/instagram.png',
                      width: 60,
                      height: 60,
                    ),
                    SizedBox(width: 16,),
                    InkWell(
                      onTap: () {
                        _launchURL('https://www.instagram.com/aldenirarrudapaes');
                      },
                      child: Text(
                        '@aldenirarrudapaes',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
                child: Divider(thickness: 1,),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/youtube.png',
                      width: 60,
                      height: 60,
                    ),
                    SizedBox(width: 16,),
                    InkWell(
                      onTap: () {
                        _launchURL('https://www.youtube.com/@aldenirarrudapaes6923');
                      },
                      child: Text(
                        '@aldenirarrudapaes',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
                child: Divider(thickness: 1,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _launchURL(String link) async {
  final Uri url = Uri.parse(link);

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Não foi possível abrir o link $url';
  }
}
