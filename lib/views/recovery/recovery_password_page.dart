import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/services/recovery_service.dart';
import 'package:meu_tempo/services/validation_mixin.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appBar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_input.dart';
import 'package:meu_tempo/widgets/custom_loading.dart';

class RecoveryPasswordPage extends StatefulWidget {
  RecoveryPasswordPage({super.key});

  @override
  State<RecoveryPasswordPage> createState() => _RecoveryPasswordPageState();
}

class _RecoveryPasswordPageState extends State<RecoveryPasswordPage>
    with ValidationsMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();

  Future<httpPackage.Response> _submit(Map<String, dynamic> data) async {
      RecoveryService service = RecoveryService();
      data['password'] = _passwordController.text;
      return await service.alterPassword(data);
  }

  Future<void> _handleRecoveryPassword(Map<String, dynamic> data) async {

    if (_formKey.currentState?.saveAndValidate() ?? false) {
       CustomLoading.show(context);

    try {
      var response = await _submit(data);

      if (response.statusCode == 204) {
        CustomLoading.close(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Senha alterada',
              message: 'Senha alterada com sucesso',
              type: AlertType.success,
              onOkPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.login);
              },
            );
          },
        );
      } else if (response.statusCode == 422) {
        CustomLoading.close(context);
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Alerta de validação',
              message: responseBody['details'] ?? 'Erro desconhecido',
              type: AlertType.warning,
              onOkPressed: () {
                Navigator.pop(context);
              },
            );
          },
        );
      } else {
        CustomLoading.close(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Erro',
              message: 'Ocorreu um erro inesperado. Tente novamente.',
              type: AlertType.error,
              onOkPressed: () {
                Navigator.pop(context);
              },
            );
          },
        );
      }
    } on httpPackage.ClientException catch (e) {
      CustomLoading.close(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Erro de Conexão',
            message:
                'Não foi possível conectar ao servidor. Verifique sua conexão com a internet e tente novamente.',
            type: AlertType.error,
            onOkPressed: () {
              Navigator.pop(context);
            },
          );
        },
      );
    } catch (e) {
      CustomLoading.close(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Erro',
            message: 'Ocorreu um erro inesperado. Tente novamente.',
            type: AlertType.error,
            onOkPressed: () {
              Navigator.pop(context);
            },
          );
        },
      );
    } finally {
      CustomLoading.close(context);
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        backgroundColor: MainColor.secondaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
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
        child: SizedBox.expand(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 50,
                  ),
                  child: Text(
                    'Recuperar Senha',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Comfortaa',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
                  child: CustomInput(
                    label: 'Senha',
                    controller: _passwordController,
                    fieldName: 'password',
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    validator: (val) => combine([
                      () => isNotEmpty(val, 'A senha é obrigatória'),
                      () => validatePassword(val),
                    ]),
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        _formKey.currentState?.fields['password']?.validate();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
                  child: CustomInput(
                    label: 'Confirmar Senha',
                    controller: _confirmPasswordController,
                    fieldName: 'confirm_password',
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    validator: (val) => combine([
                      () => isNotEmpty(val, 'Você precisa confirmar a senha'),
                      () => validatePasswordMatch(
                          _passwordController.text, val ?? ''),
                    ]),
                    onChanged: (value) {
                      if (value != null || value!.isNotEmpty) {
                        _formKey.currentState?.fields['confirm_password']
                            ?.validate();
                      }
                    },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: CustomButton(
                      width: 200,
                      text: 'Alterar',
                      onPressed: () => _handleRecoveryPassword(data),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
