# Weather App

A beautiful Flutter weather app built with clean architecture and Riverpod state management.

## Features

- **Current Weather**: Get real-time weather data for any city
- **5-Day Forecast**: View detailed weather forecasts
- **Location-based Weather**: Automatically get weather for your current location
- **Search History**: Quick access to previously searched cities
- **Beautiful UI**: Dynamic backgrounds based on weather conditions
- **Error Handling**: Comprehensive error handling and user feedback

## Architecture

This app follows **Clean Architecture** principles:

### Core Layer

- **Constants**: API endpoints and app constants
- **Error Handling**: Custom exceptions and failures
- **Network**: HTTP client configuration
- **Utils**: Location utilities and helpers
- **Dependency Injection**: GetIt service locator

### Feature Layer (Weather)

- **Domain Layer**: Entities, repositories (interfaces), and use cases
- **Data Layer**: Models, data sources, and repository implementations
- **Presentation Layer**: Pages, widgets, and Riverpod providers

## Setup Instructions

### 1. Get OpenWeatherMap API Key

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Get your API key from the dashboard

### 2. Configure API Key

1. Open `lib/core/constants/api_constants.dart`
2. Replace `YOUR_API_KEY_HERE` with your actual API key:
   ```dart
   static const String apiKey = 'your_actual_api_key_here';
   ```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Code

```bash
dart run build_runner build
```

### 5. Run the App

```bash
flutter run
```

## Dependencies

- **flutter_riverpod**: State management
- **dio**: HTTP client
- **freezed**: Immutable data classes
- **json_annotation**: JSON serialization
- **get_it**: Dependency injection
- **geolocator**: Location services
- **geocoding**: Address geocoding
- **permission_handler**: Runtime permissions
- **cached_network_image**: Image caching
- **flutter_spinkit**: Loading indicators
- **dartz**: Functional programming (Either type)

## State Management

The app uses **Riverpod** for state management with the following providers:

- `weatherProvider`: Main weather state notifier
- `currentWeatherProvider`: Current weather data
- `forecastProvider`: Forecast data
- `weatherLoadingProvider`: Loading states
- `weatherErrorProvider`: Error states
- `locationLoadingProvider`: Location loading state
- `searchHistoryProvider`: Search history

## API Integration

The app integrates with the OpenWeatherMap API:

- **Current Weather**: `/weather` endpoint
- **5-Day Forecast**: `/forecast` endpoint
- **Coordinates**: Supports both city names and GPS coordinates
- **Units**: Uses metric units (Celsius, m/s)

## Error Handling

Comprehensive error handling for:

- Network connectivity issues
- API errors (invalid key, city not found)
- Location permission errors
- Location service disabled
- Data parsing errors

## Location Services

The app supports:

- Automatic location detection
- GPS coordinates to city name conversion
- Location permission handling
- Fallback to default city (London)

## UI Features

- **Dynamic Backgrounds**: Colors change based on weather conditions
- **Weather Icons**: Official OpenWeatherMap icons
- **Responsive Design**: Works on different screen sizes
- **Pull to Refresh**: Refresh weather data
- **Search Suggestions**: Search history with quick access
- **Error States**: User-friendly error messages with retry options

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── utils/
│   └── dependency_injection/
├── features/
│   └── weather/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── pages/
│           ├── providers/
│           └── widgets/
└── main.dart
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Credits

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- Built with [Flutter](https://flutter.dev/)
- State management with [Riverpod](https://riverpod.dev/)
