import 'dart:convert';
import 'package:meu_tempo/config/http_common.dart';
import 'package:http/http.dart' as httpPackage;

class ActivationCodeService {
  var http = HttpCommon();

  Future<httpPackage.Response> sendCode(String email, String typeCode) async {
    var data = {
      "typeCode": typeCode,
    };

    return await http.post('/activation-code/$email', queryParams: data);
  }

  Future<bool> verifyCode(
      String codeAccess, String typeCode, String email) async {
    var data = {"typeCode": typeCode, "email": email};
    final response = await http.get('/activation-code/$codeAccess', queryParams: data);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return false;
  }
}
