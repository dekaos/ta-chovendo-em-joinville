import 'package:angular/angular.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_spinner/material_spinner.dart';
import 'package:ta_chovendo_em_joinville/src/utils/handle_exception.dart';
import 'home_service.dart';
import 'dart:html';
import 'package:chartjs/chartjs.dart';
import '../utils/handle_exception.dart';
import '../utils/weather_description.dart';

@Component(
  selector: 'home',
  styleUrls: ['home_component.scss.css'],
  templateUrl: 'home_component.html',
  directives: [
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialInputComponent,
    materialInputDirectives,
    MaterialSpinnerComponent,
    NgIf,
  ],
  encapsulation: ViewEncapsulation.None,
  providers: [ClassProvider(HomeService)]
)

class HomeComponent implements OnInit {
  final HomeService weather;
  HomeComponent(this.weather);

  String currentCity = 'Joinville';
  bool loading;
  String inputSearch = '';
  String errorMessage = '';
  Map cityData = Map();

  void ngOnInit() {
    getWeather(currentCity);
  }

  void searchCity() {
    if (inputSearch.isNotEmpty) {
      currentCity = inputSearch;
      getWeather(currentCity);
      inputSearch = '';
    }
  }

  Future<dynamic> getWeather(String city) async {
    loading = true;
    errorMessage = '';

    try {
      cityData = await weather.getWeather(city);
      List<String> forecastLabels = List();
      List<double> forecastDataTemp = List();
      List<double> forecastDataWind = List();
      List<double> forecastDataHumidity = List();
      List<double> forecastDataPressure = List();

      cityData['forecast_data'].forEach((data) {
        DateTime dateLabel = DateTime.tryParse(data['dt_txt']);
        String hour = dateLabel.hour.toString().padLeft(2, '0');
        String minute = dateLabel.minute.toString().padLeft(2, '0');
        forecastLabels.add('$hour:$minute ${weatherDescription(data['weather'][0]['id'])}');
        forecastDataTemp.add(data['main']['temp']);
        forecastDataHumidity.add(data['main']['humidity']);
        forecastDataWind.add(data['wind']['speed']);
        forecastDataPressure.add(data['main']['pressure']);
      });

      ChartDataSets ChartDataSetsOne = ChartDataSets(
        label: 'Temperatura ˚C',
        borderColor: 'mediumvioletred',
        backgroundColor: 'transparent',
        data: forecastDataTemp,
        fill: false,
        yAxisID: 'y-one'
      );

      ChartDataSets ChartDataSetsTwo = ChartDataSets(
        label: 'Vento km/h',
        borderColor: 'forestgreen',
        backgroundColor: 'transparent',
        data: forecastDataWind,
        fill: false,
        yAxisID: 'y-two'
      );

      ChartDataSets ChartDataSetsTree = ChartDataSets(
        label: 'Pressão hdpa',
        borderColor: 'dodgerblue',
        backgroundColor: 'transparent',
        data: forecastDataPressure,
        fill: false,
        yAxisID: 'y-tree'
      );

      ChartYAxe ChartScaleYOne = ChartYAxe(
        type: 'linear',
        id: 'y-one',
        position: 'left'
      );

      ChartYAxe ChartScaleYTwo = ChartYAxe(
        type: 'linear',
        id: 'y-two',
        position: 'right'
      );

      ChartYAxe ChartScaleYTree = ChartYAxe(
        type: 'linear',
        id: 'y-tree',
        position: 'right'
      );

      LinearChartData data = LinearChartData(labels: forecastLabels, datasets: <ChartDataSets>[
        ChartDataSetsOne,
        ChartDataSetsTwo,
        ChartDataSetsTree
      ]);

      ChartConfiguration config = ChartConfiguration(
        type: 'line', data: data, options: ChartOptions(
        responsive: true,
        scales: ChartScales(yAxes: <ChartYAxe>[
          ChartScaleYOne,
          ChartScaleYTwo,
          ChartScaleYTree
        ])
      ));
      loading = false;
      Chart(querySelector('#chart') as CanvasElement, config);

    } on HandleException catch(error) {
      errorMessage = error.exception;
      print(errorMessage);
      loading = false;
    } catch (error, s) {
      print(s);
      loading = false;
      errorMessage = error;
    }
  }
}