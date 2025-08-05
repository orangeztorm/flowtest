import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/weather.dart';

part 'weather_model.freezed.dart';
part 'weather_model.g.dart';

/// Weather model for API response data
/// Converts JSON data to domain entity
@freezed
class WeatherModel with _$WeatherModel {
  const factory WeatherModel({
    @JsonKey(name: 'name') required String cityName,
    required SysModel sys,
    required List<WeatherDataModel> weather,
    required MainModel main,
    required WindModel wind,
    required CloudsModel clouds,
    required int visibility,
    @JsonKey(name: 'dt') required int dt,
  }) = _WeatherModel;

  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);

  const WeatherModel._();

  /// Convert to domain entity
  Weather toEntity() {
    final weatherData = weather.first;
    return Weather(
      cityName: cityName,
      country: sys.country,
      main: weatherData.main,
      description: weatherData.description,
      iconCode: weatherData.icon,
      temperature: main.temp,
      feelsLike: main.feelsLike,
      tempMin: main.tempMin,
      tempMax: main.tempMax,
      pressure: main.pressure,
      humidity: main.humidity,
      visibility: visibility,
      windSpeed: wind.speed,
      windDegree: wind.deg,
      cloudiness: clouds.all,
      sunrise: sys.sunrise,
      sunset: sys.sunset,
      dt: dt,
    );
  }
}

/// System information model
@freezed
class SysModel with _$SysModel {
  const factory SysModel({
    required String country,
    required int sunrise,
    required int sunset,
  }) = _SysModel;

  factory SysModel.fromJson(Map<String, dynamic> json) =>
      _$SysModelFromJson(json);
}

/// Weather data model
@freezed
class WeatherDataModel with _$WeatherDataModel {
  const factory WeatherDataModel({
    required String main,
    required String description,
    required String icon,
  }) = _WeatherDataModel;

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataModelFromJson(json);
}

/// Main weather parameters model
@freezed
class MainModel with _$MainModel {
  const factory MainModel({
    required double temp,
    @JsonKey(name: 'feels_like') required double feelsLike,
    @JsonKey(name: 'temp_min') required double tempMin,
    @JsonKey(name: 'temp_max') required double tempMax,
    required int pressure,
    required int humidity,
  }) = _MainModel;

  factory MainModel.fromJson(Map<String, dynamic> json) =>
      _$MainModelFromJson(json);
}

/// Wind model
@freezed
class WindModel with _$WindModel {
  const factory WindModel({required double speed, required int deg}) =
      _WindModel;

  factory WindModel.fromJson(Map<String, dynamic> json) =>
      _$WindModelFromJson(json);
}

/// Clouds model
@freezed
class CloudsModel with _$CloudsModel {
  const factory CloudsModel({required int all}) = _CloudsModel;

  factory CloudsModel.fromJson(Map<String, dynamic> json) =>
      _$CloudsModelFromJson(json);
}
