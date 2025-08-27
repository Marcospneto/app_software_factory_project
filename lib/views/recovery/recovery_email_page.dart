import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/models/type_code.dart';
import 'package:meu_tempo/services/activation_code_service.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/services/validation_mixin.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_input.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:meu_tempo/widgets/custom_loading.dart';

class RecoveryEmailPage extends StatefulWidget {
  RecoveryEmailPage({super.key});

  @override
  State<RecoveryEmailPage> createState() => _RecoveryEmailPageState();
}

class _RecoveryEmailPageState extends State<RecoveryEmailPage>
    with ValidationsMixin {
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormBuilderState>();
  final typeCode = TypeCode.RECOVERY.name;

  Future<httpPackage.Response> _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      ActivationCodeService service = ActivationCodeService();
      return await service.sendCode(
          _emailController.text, typeCode);
    }
    return Future.value(httpPackage.Response('', 400));
  }

  Future<void> _handlerEmailRecovery() async {
    CustomLoading.show(context);

    try {
      var response = await _submit();
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomLoading.close(context);
        var data = {
          "email": _emailController.text,
          "typeCode": typeCode
        };
        Navigator.pushNamed(
          context,
          AppRoutes.code,
          arguments: data,
        );
      } else if (response.statusCode == 404) {
        CustomLoading.close(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Alerta',
              message: 'Se o e-mail estiver registrado, você receberá um código para continuar com a recuperação',
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
                child: FormBuilder(
                  key: _formKey,
                  child: CustomInput(
                    label: 'Email',
                    controller: _emailController,
                    fieldName: 'email',
                    validator: (val) => combine([
                      () => isNotEmpty(val, 'O email é obrigatório'),
                      () => validEmail(val),
                    ]),
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        _formKey.currentState?.fields['email']?.validate();
                      }
                    },
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: CustomButton(
                    text: 'Enviar',
                    width: 200,
                    onPressed: _handlerEmailRecovery,
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
