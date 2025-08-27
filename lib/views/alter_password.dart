import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/services/recovery_service.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/services/validation_mixin.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appBar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_input.dart';

class AlterPassword extends StatefulWidget {
  const AlterPassword({super.key});

  @override
  State<AlterPassword> createState() => _AlterPasswordState();
}

class _AlterPasswordState extends State<AlterPassword> with ValidationsMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _actualPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmedPassword = TextEditingController();

  late final usersService = UsersService();
  Users? _currentUser;

  Future<void> _loadUser() async {
    final user = await usersService.getCurrentUser();
    if (mounted) {
      setState(() {
        if (user != null) {
          _currentUser = user;
        }
      });
    }
  }

  Future<httpPackage.Response> _submit() async {
    RecoveryService service = RecoveryService();
    final data = {
      'email': _currentUser!.email,
      'actualPassword': _actualPassword.text,
      'newPassword': _newPassword.text,
    };

    final response = await service.changePassword(data);

    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Senha Alterada',
              message: 'Senha alterada com sucesso!',
              type: AlertType.success,
                onOkPressed: () {
                  _actualPassword.clear();
                  _newPassword.clear();
                  _confirmedPassword.clear();
                  Navigator.pop(context);
                },
            );
          });
    } else if (response.statusCode == 422) {
      final errorMessage = jsonDecode(response.body)['details'] ?? 'Não foi possível alterar a senha.';
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Warning',
              message: errorMessage,
              type: AlertType.warning,
              onOkPressed: () => Navigator.pop(context),
            );
          });
    }

    return response;
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Alterar Senha',
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
      body: SizedBox(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomInput(
                  label: 'Senha Atual',
                  controller: _actualPassword,
                  fieldName: 'actualPassword',
                  obscureText: true,
                  colorLabel: MainColor.primaryColor,
                  colorBorder: MainColor.primaryColor,
                  colorText: MainColor.primaryColor,
                  colorIcon: MainColor.primaryColor,
                  colorError: MainColor.primaryColor,
                  validator: (val) => isNotEmpty(val, "A senha atual é obrigatória"),
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        _formKey.currentState?.fields['actualPassword']?.validate();
                      }
                    }
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomInput(
                  label: 'Nova Senha',
                  controller: _newPassword,
                  fieldName: 'newPassword',
                  obscureText: true,
                  colorLabel: MainColor.primaryColor,
                  colorBorder: MainColor.primaryColor,
                  colorText: MainColor.primaryColor,
                  colorIcon: MainColor.primaryColor,
                  colorError: MainColor.primaryColor,
                  validator: (val) => combine([
                    () => isNotEmpty(val, "A senha é obrigatória"),
                    () => validatePassword(val),
                  ]),
                  onChanged: (value) {
                    if (value != null && value.isNotEmpty) {
                      _formKey.currentState?.fields['newPassword']?.validate();
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomInput(
                  label: 'Confirmar Senha',
                  controller: _confirmedPassword,
                  fieldName: 'confirmedPassword',
                  obscureText: true,
                  colorLabel: MainColor.primaryColor,
                  colorBorder: MainColor.primaryColor,
                  colorText: MainColor.primaryColor,
                  colorIcon: MainColor.primaryColor,
                  colorError: MainColor.primaryColor,
                  validator: (val) => combine([
                    () => isNotEmpty(val, 'Você precisa confirmar a senha'),
                    () => validatePasswordMatch(_newPassword.text, val ?? ''),
                  ]),
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        _formKey.currentState?.fields['confirmedPassword']?.validate();
                      }
                    }
                ),
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: CustomButton(
                  text: 'Alterar',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _submit();
                    }
                  },
                  color: MainColor.primaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
