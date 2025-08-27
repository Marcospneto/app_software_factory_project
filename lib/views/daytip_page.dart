import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/providers/tips_provider.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DaytipPage extends StatefulWidget {
  const DaytipPage({Key? key}) : super(key: key);

  @override
  _DaytipPageState createState() => _DaytipPageState();
}

class _DaytipPageState extends State<DaytipPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tipsProvider = Provider.of<TipsProvider>(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MainColor.primaryColor,
              MainColor.secondaryColor,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 220),
            const Text(
              'Dica do dia',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 160),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Consumer<TipsProvider>(
                  builder: (context, tipsProvider, child) {
                    if (tipsProvider.loading) {
                      return const CircularProgressIndicator(color: Colors.white);
                    } else if (tipsProvider.tip != null) {
                      return AutoSizeText(
                        tipsProvider.tip!.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ), 
                        minFontSize: 14,
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis, 
                      );
                    } else {
                      return const Text(
                        'Não foi possível carregar a dica do dia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 39),
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: Colors.purpleAccent.withAlpha(200),
                elevation: 0,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






































