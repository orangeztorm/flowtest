import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/forecast.dart';

part 'forecast_model.freezed.dart';
part 'forecast_model.g.dart';

/// Forecast model for API response data
/// Converts JSON forecast data to domain entity
@freezed
class ForecastModel with _$ForecastModel {
  const factory ForecastModel({
    required CityModel city,
    @JsonKey(name: 'list') required List<ForecastItemModel> items,
  }) = _ForecastModel;

  factory ForecastModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastModelFromJson(json);

  const ForecastModel._();

  /// Convert to domain entity
  Forecast toEntity() {
    return Forecast(
      cityName: city.name,
      country: city.country,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }
}

/// City model for forecast response
@freezed
class CityModel with _$CityModel {
  const factory CityModel({required String name, required String country}) =
      _CityModel;

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);
}

/// Individual forecast item model
@freezed
class ForecastItemModel with _$ForecastItemModel {
  const factory ForecastItemModel({
    @JsonKey(name: 'dt') required int dt,
    required ForecastMainModel main,
    required List<ForecastWeatherModel> weather,
    required ForecastWindModel wind,
    required ForecastCloudsModel clouds,
    @JsonKey(name: 'pop') required double pop,
  }) = _ForecastItemModel;

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastItemModelFromJson(json);

  const ForecastItemModel._();

  /// Convert to domain entity
  ForecastItem toEntity() {
    final weatherData = weather.first;
    return ForecastItem(
      dt: dt,
      main: weatherData.main,
      description: weatherData.description,
      iconCode: weatherData.icon,
      temperature: main.temp,
      feelsLike: main.feelsLike,
      tempMin: main.tempMin,
      tempMax: main.tempMax,
      pressure: main.pressure,
      humidity: main.humidity,
      windSpeed: wind.speed,
      windDegree: wind.deg,
      cloudiness: clouds.all,
      pop: pop,
    );
  }
}

/// Main model for forecast item
@freezed
class ForecastMainModel with _$ForecastMainModel {
  const factory ForecastMainModel({
    required double temp,
    @JsonKey(name: 'feels_like') required double feelsLike,
    @JsonKey(name: 'temp_min') required double tempMin,
    @JsonKey(name: 'temp_max') required double tempMax,
    required int pressure,
    required int humidity,
  }) = _ForecastMainModel;

  factory ForecastMainModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastMainModelFromJson(json);
}

/// Weather model for forecast item
@freezed
class ForecastWeatherModel with _$ForecastWeatherModel {
  const factory ForecastWeatherModel({
    required String main,
    required String description,
    required String icon,
  }) = _ForecastWeatherModel;

  factory ForecastWeatherModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastWeatherModelFromJson(json);
}

/// Wind model for forecast item
@freezed
class ForecastWindModel with _$ForecastWindModel {
  const factory ForecastWindModel({required double speed, required int deg}) =
      _ForecastWindModel;

  factory ForecastWindModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastWindModelFromJson(json);
}

/// Clouds model for forecast item
@freezed
class ForecastCloudsModel with _$ForecastCloudsModel {
  const factory ForecastCloudsModel({required int all}) = _ForecastCloudsModel;

  factory ForecastCloudsModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastCloudsModelFromJson(json);
}
