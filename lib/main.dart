import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_ap/cubits/weather_cubit.dart';
import 'package:weather_icons/weather_icons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: BlocProvider(
        create: (context) => WeatherCubit()..getWeather(),
        child: WeatherPage(),
      ),
    );
  }
}

class WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[300],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '12, March 2024',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Jakarta, Indonesia',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Switch(
            value: false, // Replace with your dark mode state management
            onChanged: (value) {
              // Implement your dark mode toggle logic
            },
          ),
        ],
      ),
      backgroundColor: Colors.indigo[300],
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoaded) {
            return WeatherLoadedView(state: state);
          } else if (state is WeatherError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class WeatherLoadedView extends StatelessWidget {
  final WeatherLoaded state;

  const WeatherLoadedView({Key? key, required this.state}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.indigo[300],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.indigo[300],
            child: Column(
              children: [
                SizedBox(width: 200),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 110,
                      child: Icon(
                        getIconData(state.todayForecast[0].weatherIcon),
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${state.temperature}°',
                      style: TextStyle(
                        fontSize: 150,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      WeatherInfoBox(
                        icon: Icons.air,
                        value: '${state.windSpeed} km/h',
                        label: 'Wind',
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
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Forecast',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: state.todayForecast
                              .map((forecast) => DailyForecastWidget(
                                    forecast: forecast,
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData getIconDatas(String weatherIcon) {
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

class DailyForecastWidget extends StatelessWidget {
  final WeatherForecast forecast;

  const DailyForecastWidget({Key? key, required this.forecast})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          Text(
            '${forecast.time}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            getIconDatas(forecast.weatherIcon),
            size: 30,
            color: Colors.blue,
          ),
          Text(
            '${forecast.temperature}°C',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
