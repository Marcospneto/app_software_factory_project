import 'dart:convert';
import 'package:meu_tempo/config/http_common.dart';
import 'package:meu_tempo/models/tips.dart';

class TipsService {
  var http = HttpCommon();

  Future<TipResponse> getTip() async {
    try {
      final response = await http.get('/tips');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return TipResponse.fromJson(data);
      } else {
        throw Exception('Falha ao carregar dica do dia.');
      }
    } catch (e) {
      throw Exception('Falha na requisição: $e');
    }
  }
}