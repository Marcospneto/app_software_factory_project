import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/models/type_code.dart';
import 'package:meu_tempo/services/activation_code_service.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/services/auth_service.dart';
import 'package:meu_tempo/services/validation_mixin.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_code_input.dart';
import 'package:meu_tempo/widgets/custom_loading.dart';
import 'package:meu_tempo/widgets/custom_timer.dart';
import 'package:http/http.dart' as httpPackage;

class RecoveryCodePage extends StatefulWidget {
  RecoveryCodePage({super.key});

  @override
  State<RecoveryCodePage> createState() => _RecoveryCodePageState();
}

class _RecoveryCodePageState extends State<RecoveryCodePage>
    with ValidationsMixin {

  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  late Map<String, dynamic> data; 
  final authService = AuthService();

  Future<bool> _submit(String? email, String typeCode) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      ActivationCodeService service = ActivationCodeService();
      return await service.verifyCode(
          _codeController.text, typeCode, email!);
    }
    return false;
  }

   @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _alertSendEmail();
      _sendActiveCode();
    });
  }

  void _alertSendEmail(){
    showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Ative sua conta',
              message: 'Um codigo de ativação foi enviado para seu e-mail, por favor verificar',
              type: AlertType.warning,
              onOkPressed: () {
                Navigator.pop(context);
              },
            );
          },
        );
  }

  Future<void> _sendActiveCode() async {
    data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final email = data['email'];
    final typeCode = data['typeCode'];

    try {
      ActivationCodeService service = ActivationCodeService();
      await service.sendCode(email, typeCode);
    } catch (e) {
      debugPrint('Não foi possível carregar os dados: $e.');
    } 
  }

  Future<void> _handlerCodeRecovery(Map<String, dynamic> data) async {
    CustomLoading.show(context);
    try {
      final email = data['email'];
      final typeCode = data['typeCode'];
      final password = data['password'];
      bool isActivate = await _submit(email, typeCode);
      if (isActivate) {
        CustomLoading.close(context);
        if (typeCode == TypeCode.ACTIVATION.name) {
            await authService.authenticate(email, password);
            await Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          Navigator.pushNamed(context, AppRoutes.recoveryPassword,
              arguments: {'email': email, 'codeAccess': _codeController.text});
        }
      } else {
        CustomLoading.close(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Código inválido',
              message: 'Código inválido, tente novamente',
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
    data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        backgroundColor: MainColor.secondaryColor,
        leading: data['typeCode'] == TypeCode.RECOVERY.name
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [MainColor.primaryColor, MainColor.secondaryColor],
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
                  top: 50,
                  left: 16,
                ),
                child: Text(
                  data['typeCode'] == TypeCode.RECOVERY.name
                      ? 'Recuperar Senha'
                      : 'Ativar conta',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Comfortaa'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 20),
                child: Text(
                  'Digite o código',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
                child: FormBuilder(
                  key: _formKey,
                  child: CustomCodeInput(
                    controller: _codeController,
                    fieldName: 'code',
                    onChanged: (value) {
                      if (value != null || value!.isNotEmpty) {
                        _formKey.currentState?.fields['code']?.validate();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: CustomTimer(email: data['email'], typeCode: data['typeCode'],),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: CustomButton(
                    width: 200,
                    text: 'Enviar',
                    onPressed: () => _handlerCodeRecovery(data),
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
