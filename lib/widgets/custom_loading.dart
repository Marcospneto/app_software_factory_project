import 'package:flutter/material.dart';

class CustomLoading {
  static bool _isDialogOpen = false; // Para evitar múltiplas chamadas de showDialog

  static void show(BuildContext context, {String mensagem = "Carregando..."}) {
    if (_isDialogOpen) return; // Se já estiver aberto, não faz nada

    _isDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false, // Impede o fechamento ao clicar fora
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: CustomLoadingWidget(),
        );
      },
    );
  }

  static void close(BuildContext context) {
    if (_isDialogOpen && Navigator.of(context).canPop()) {
      _isDialogOpen = false;
      Navigator.of(context).pop();
    }
  }
}

class CustomLoadingWidget extends StatelessWidget {
  final String message;

  const CustomLoadingWidget({Key? key, this.message = "Carregando..."}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
