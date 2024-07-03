import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final String apiKey = 'c19abce7d87d10d3c0c1560c3f82103d';
  final String city = 'Depok';

  WeatherCubit() : super(WeatherInitial());

  Future<void> getWeather() async {
    final weatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    try {
      // Fetch current weather
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);

        // Fetch today's forecast (example: next 8 hours)
        final forecastResponse = await http.get(Uri.parse(forecastUrl));
        if (forecastResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          // Assuming first 8 hours forecast as today's forecast
          final List<dynamic> forecasts = forecastData['list'].take(8).toList();

          emit(WeatherLoaded(
            temperature: weatherData['main']['temp'].toInt(),
            windSpeed: weatherData['wind']['speed'].toInt(),
            humidity: weatherData['main']['humidity'].toInt(),
            visibility: (weatherData['visibility'] / 1000).toInt(), // Convert to km
            todayForecast: forecasts.map((forecast) => WeatherForecast(
              time: '${DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000).hour.toString().padLeft(2, '0')}:00',
              temperature: forecast['main']['temp'].toInt(),
              weatherIcon: forecast['weather'][0]['icon'],
            )).toList(),
          ));
        } else {
          emit(WeatherError('Failed to fetch weather forecast'));
        }
      } else {
        emit(WeatherError('Failed to fetch current weather data'));
      }
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}

abstract class WeatherState {}


class WeatherInitial extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final int temperature;
  final int windSpeed;
  final int humidity;
  final int visibility;
  final List<WeatherForecast> todayForecast;

  WeatherLoaded({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.visibility,
    required this.todayForecast,
  });
  
  get message => null;
}

class WeatherForecast {
  final String time;
  final int temperature;
  final String weatherIcon;

  WeatherForecast({
    required this.time,
    required this.temperature,
    required this.weatherIcon,
  });
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);
}

class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: BlocProvider(
        create: (context) => WeatherCubit()..getWeather(),
        child: WeatherBody(),
      ),
    );
  }
}

class WeatherBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherInitial) {
          return Center(child: CircularProgressIndicator());
        } else if (state is WeatherLoaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WeatherInfoBox(
                  icon: Icons.thermostat_outlined,
                  value: '${state.temperature}°C',
                  label: 'Temperature',
                ),
                WeatherInfoBox(
                  icon: Icons.air,
                  value: '${state.windSpeed} m/s',
                  label: 'Wind Speed',
                ),
                WeatherInfoBox(
                  icon: Icons.opacity,
                  value: '${state.humidity}%',
                  label: 'Humidity',
                ),
                WeatherInfoBox(
                  icon: Icons.visibility,
                  value: '${state.visibility} km',
                  label: 'Visibility',
                ),
                SizedBox(height: 20),
                Text(
                  'Today\'s Forecast',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (state.todayForecast.isNotEmpty)
                  Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.todayForecast.length,
                      itemBuilder: (context, index) {
                        var forecast = state.todayForecast[index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(forecast.time),
                              Icon(
                                getIconData(forecast.weatherIcon), // Use icon code to get IconData
                                size: 30,
                                color: Colors.blue,
                              ),
                              Text('${forecast.temperature}°C'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (state is WeatherError)
                  Text('Failed to fetch weather data: ${state.message}'),
              ],
            ),
          );
        } else if (state is WeatherError) {
          return Center(
            child: Text('Failed to fetch weather data: ${state.message}'),
          );
        } else {
          return Center(child: Text('Unknown state'));
        }
      },
    );
  }

  IconData getIconData(String weatherIcon) {
    switch (weatherIcon) {
      case '01d':
        return WeatherIcons.day_sunny;
      case '01n':
        return WeatherIcons.night_clear;
      case '02d':
      case '02n':
        return WeatherIcons.cloudy;
      case '03d':
      case '03n':
        return WeatherIcons.cloud;
      case '04d':
      case '04n':
        return WeatherIcons.cloudy_gusts;
      case '09d':
      case '09n':
        return WeatherIcons.showers;
      case '10d':
      case '10n':
        return WeatherIcons.rain;
      case '11d':
      case '11n':
        return WeatherIcons.thunderstorm;
      case '13d':
      case '13n':
        return WeatherIcons.snow;
      case '50d':
      case '50n':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.na; // Default icon if not recognized
    }
  }
}

class WeatherInfoBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  WeatherInfoBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blueAccent),
        Text(value, style: TextStyle(color: Colors.black)),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
