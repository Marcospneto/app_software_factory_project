import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/models/profile.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/services/validation_mixin.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_input.dart';
import 'package:meu_tempo/widgets/custom_loading.dart';
import 'package:meu_tempo/widgets/custom_input_phone.dart';
import 'package:http/http.dart' as httpPackage;

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> with ValidationsMixin {
  bool _isChecked = false;
  final _formKey = GlobalKey<FormBuilderState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? nameError;
  String? emailError;
  String? phoneError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
  }

  bool _validateTerms() {
    if (!_isChecked) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Termos não aceitos',
            message:
                'Você deve aceitar os Termos de Serviço e Política de Privacidade para continuar.',
            type: AlertType.warning,
            onOkPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
      return false;
    }
    return true;
  }

  void _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (_validateTerms()) {
        final user = Users(
          name: _nameController.text,
          email: _emailController.text,
          telephone: _phoneController.text,
          password: _passwordController.text,
          idProfile: Profile.ROLE_USER.value,
        );

        try {
          CustomLoading.show(context);
          final userService = UsersService();
          final response = await userService.createUser(user);
          CustomLoading.close(context);
          if (response.statusCode == 201) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return CustomAlert(
                  title: 'Sucesso!',
                  message: 'O usuário foi cadastrado com sucesso',
                  type: AlertType.success,
                  onOkPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.intro);
                  },
                );
              },
            );
          } else if (response.statusCode == 422 || response.statusCode == 409) {
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
                title: 'Erro!',
                message: 'Erro ao cadastrar o usuário',
                type: AlertType.error,
                onOkPressed: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );
        } finally {
          CustomLoading.close(context);
        }
      }
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
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 30,
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cadastro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontFamily: 'Comfortaa',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 36),
                            child: CustomInput(
                              label: 'Nome',
                              controller: _nameController,
                              keyboardType: TextInputType.text,
                              fieldName: 'name',
                              validator: (val) =>
                                  isNotEmpty(val, "Nome é obrigatório"),
                              onChanged: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _formKey.currentState?.fields['name']
                                      ?.validate();
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: CustomInput(
                              label: 'E-mail',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              fieldName: 'email',
                              validator: (val) => combine([
                                () => isNotEmpty(val, "Email é obrigatório"),
                                () => validEmail(val, "Digite um email válido"),
                              ]),
                              onChanged: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _formKey.currentState?.fields['email']
                                      ?.validate();
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: CustomInputPhone(
                              label: 'Telefone',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              fieldName: 'phone',
                              validator: (val) => combine([
                                () => isNotEmpty(val, "Telefone é obrigatório"),
                                () => validatePhoneNumber(val),
                              ]),
                              onChanged: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _formKey.currentState?.fields['phone']
                                      ?.validate();
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: CustomInput(
                              label: 'Senha',
                              controller: _passwordController,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              fieldName: 'password',
                              validator: (val) => combine([
                                () => isNotEmpty(val, "Senha é obrigatória"),
                                () => validatePassword(val),
                              ]),
                              onChanged: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _formKey.currentState?.fields['password']
                                      ?.validate();
                                }
                              },
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: CustomButton(
                                text: 'Cadastrar',
                                onPressed: _submit,
                                width: 200,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });
                          },
                          fillColor: WidgetStateColor.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.blue;
                            }
                            return Color.fromRGBO(217, 217, 217, 1.0);
                          }),
                          side: BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Termos e serviços de privacidade'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      height: 400,
                                      child: SingleChildScrollView(
                                        child: const Text("Conteudo"),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Fechar'),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 50,
                            child: Center(
                              child: const Text(
                                'Ao se cadastrar, você concorda com nossos Termos de Serviço e Política de Privacidade.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
