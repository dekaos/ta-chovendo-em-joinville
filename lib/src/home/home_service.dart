import 'package:angular/core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import '../utils/handle_exception.dart';
import '../utils/weather_description.dart';

@Injectable()
class HomeService {

  String _throwException(error) {
    throw HandleException(error);
  }

  String _errorMessageByStatusCode (int code) {
    Map status = Map();
    status[400] = 'Erro ao processar requisição.';
    status[401] = 'Usuário não autorizado.';
    status[404] = 'Cidade não encontrada, tente uma nova busca.';
    status[500] = 'Erro interno do servidor.';
    status[503] = 'Serviço indisponível.';

    return status[code];
  }

  void _checkStatusCode (int statusCode, dynamic data) {
    if (statusCode < 200 || statusCode >= 400) {
      int code;

      if (data.containsKey('cod')) {
        String responseAPICode = data['cod'].toString();
        code = int.tryParse(responseAPICode) ?? 400;
      }

      _throwException(_errorMessageByStatusCode(code));
    }
  }

  Future<dynamic> _getForecast (int cityId) async {
    String urlForecast = 'http://api.openweathermap.org/data/2.5/forecast?id=$cityId&units=metric&type=accurate&lang=pt&APPID=50cee3eb274c3567972054e2c538a34b';

    final response = await http.get(urlForecast);
    final foreCast = json.decode(response.body);

    _checkStatusCode(response.statusCode, foreCast);

    return foreCast;
  }

  Future<dynamic> getWeather([String city]) async {
    String url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&type=like&units=metric&lang=pt&APPID=50cee3eb274c3567972054e2c538a34b';
    List foreCastData = List();
    final response = await http.get(url);
    final weather = json.decode(response.body);

    _checkStatusCode(response.statusCode, weather);

    if (weather['weather']?.isEmpty ?? true) {
      _throwException('Dados da cidade não encontrados.');
    }

    int cityId = int.tryParse(weather['id'].toString());

    final foreCast = await _getForecast(cityId);

    if (foreCast.containsKey('list')) {
      foreCastData = foreCast['list'];

      if (foreCastData.isNotEmpty) {
        weather['forecast_data'] = foreCastData;
      }
    }

    DateTime sunrise = DateTime.fromMillisecondsSinceEpoch(weather['sys']['sunrise'] * 1000);
    DateTime sunset = DateTime.fromMillisecondsSinceEpoch(weather['sys']['sunset'] * 1000);

    weather['temp'] = weather['main']['temp'];
    weather['max'] = weather['main']['temp_max'];
    weather['min'] = weather['main']['temp_min'];
    weather['pressure'] = weather['main']['pressure'];
    weather['wind_speed'] = weather['wind']['speed'];
    weather['humidity'] = weather['main']['humidity'];
    weather['sunrise'] = '${sunrise.hour.toString().padLeft(2, '0')}:${sunrise.minute.toString().padLeft(2, '0')}';
    weather['sunset'] = '${sunset.hour.toString().padLeft(2, '0')}:${sunset.minute.toString().padLeft(2, '0')}';
    weather['description'] = weatherDescription(weather['weather'][0]['id']);

    return weather;
  }
}
