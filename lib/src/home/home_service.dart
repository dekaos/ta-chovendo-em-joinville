import 'package:angular/core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import '../utils/handle_exception.dart';

@Injectable()
class HomeService {

  String _throwException(error) {
    throw HandleException(error);
  }

  String _errorMessageByStatusCode (int code) {
    Map status = Map();
    status[400] = 'Erro ao processar requisição.';
    status[401] = 'Usuário não autorizado.';
    status[404] = 'Cidade não encontrada, você pode tentar uma nova busca.';
    status[500] = 'Erro interno do servidor.';
    status[503] = 'Serviço indisponível.';

    return status[code];
  }

  Future<dynamic> getWeather([String city]) async {
    String url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&type=like&units=metric&lang=pt&APPID=50cee3eb274c3567972054e2c538a34b';

    final response = await http.get(url);
    final weather = json.decode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 400) {
      int code = weather.containsKey('cod') && weather['cod'] is String ? int.tryParse(weather['cod']) : 400;
      _throwException(_errorMessageByStatusCode(code));
    }

    if (weather['weather']?.isEmpty ?? true) {
      _throwException('Dados da cidade não encontrados.');
    }

    return weather;
  }
}
