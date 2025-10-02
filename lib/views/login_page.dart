import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/config/application_constants.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/models/type_code.dart';
import 'package:meu_tempo/services/auth_service.dart';
import 'package:meu_tempo/services/secure_storage_service.dart';
import 'package:meu_tempo/services/validation_mixin.dart';
import 'package:meu_tempo/views/home_page.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_input.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:meu_tempo/widgets/custom_loading.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ValidationsMixin {
  final _formKey = GlobalKey<FormBuilderState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? emailError;
  String? passwordError;
  final storageService = SecureStorageService();

  @override
  void initState() {
    super.initState();
  }

  Future<httpPackage.Response> _submit() async {
    AuthService authService = AuthService();
    return await authService.authenticate(
        _emailController.text, _passwordController.text);
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState!.saveAndValidate())) {
      return; // Não faz login se o formulário for inválido
    }

    CustomLoading.show(context);

    try {
      var response = await _submit();
      if (response.statusCode == 200) {
        CustomLoading.close(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      } else if (response.statusCode == 422) {
        CustomLoading.close(context);
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = responseBody['details'] ?? 'Erro desconhecido';

        if (msg.contains(ApplicationConstants.userInactiveMessage)) {
          final data = {
            "email": _emailController.text,
            "typeCode": TypeCode.ACTIVATION.name,
            "password": _passwordController.text
          };

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.code,
            arguments: data,
          );
        }
      } else if (response.statusCode == 401) {
        CustomLoading.close(context);
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Alerta',
              message: responseBody['details'] ?? 'E-mail ou senha incorretos',
              type: AlertType.warning,
              onOkPressed: () {
                Navigator.pop(context);
              },
            );
          },
        );
      } else {
        CustomLoading.close(context);
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = response.statusCode == 403
            ? responseBody['details']
            : 'Ocorreu um erro inesperado. Tente novamente.';
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Erro',
              message: msg,
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

  @override
  Widget build(BuildContext context) {
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
            Navigator.of(context).pushNamed(AppRoutes.intro);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Entrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.bold,
                ),
              ),
              FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: CustomInput(
                        label: 'E-mail',
                        controller: _emailController,
                        fieldName: 'email',
                        validator: (val) => combine([
                          () => isNotEmpty(val, "E-mail é obrigatório"),
                          () => validEmail(
                              val, "Por favor, insira um email válido"),
                        ]),
                        onChanged: (value) {
                          if (value != null && value.isNotEmpty) {
                            _formKey.currentState?.fields['email']?.validate();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomInput(
                      label: 'Senha',
                      controller: _passwordController,
                      fieldName: 'password',
                      obscureText: true,
                      validator: (val) =>
                          isNotEmpty(val, "A senha é obrigatória"),
                      onChanged: (value) {
                        if (value != null && value.isNotEmpty) {
                          _formKey.currentState?.fields['password']?.validate();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.recoveryEmail);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text(
                    'ESQUECEU SUA SENHA?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: CustomButton(
                  text: 'ENTRAR',
                  onPressed: _handleLogin,
                  width: 200,
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.signin);
                  },
                  child: const Text(
                    'OU CADASTRE-SE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
