import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class Weatherscreen extends StatefulWidget {
  static const String id = "Weatherscreen";
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<Weatherscreen> {
  Map<String, dynamic>? currentWeather;
  List<dynamic>? hourlyForecast;
  bool isLoading = true;
  String? error;
  String? currentCity;

  final String apiKey = '5836bad5c2b7aed7b621d9e94a550f87';

  @override
  void initState() {
    super.initState();
    getCurrentLocationWeather();
  }

  Future<void> getCurrentLocationWeather() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      if (apiKey.isEmpty || apiKey == 'YOUR_NEW_API_KEY_HERE') {
        setState(() {
          error =
              'API key not set. Please get a valid API key from OpenWeatherMap';
          isLoading = false;
        });
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          error =
              'Location services are disabled. Please enable location services.';
          isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            error = 'Location permission denied. Please allow location access.';
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          error =
              'Location permissions are permanently denied. Please enable in settings.';
          isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      print('Got location: ${position.latitude}, ${position.longitude}');
      await fetchWeatherDataByCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        error = 'Failed to get location: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> fetchWeatherDataByCoordinates(double lat, double lon) async {
    try {
      print('Fetching weather for: $lat, $lon');

      final currentResponse = await http
          .get(
            Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
            ),
          )
          .timeout(Duration(seconds: 10));

      print('Current weather response: ${currentResponse.statusCode}');
      print('Response body: ${currentResponse.body}');

      if (currentResponse.statusCode == 200) {
        currentWeather = json.decode(currentResponse.body);
        currentCity = currentWeather?['name'];
        print('Successfully got current weather for: $currentCity');

        final forecastResponse = await http
            .get(
              Uri.parse(
                'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
              ),
            )
            .timeout(Duration(seconds: 10));

        print('Forecast response: ${forecastResponse.statusCode}');

        if (forecastResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          hourlyForecast = forecastData['list'].take(4).toList();
          print('Successfully got forecast data');
        } else {
          print('Forecast request failed: ${forecastResponse.body}');
        }

        setState(() {
          isLoading = false;
          error = null;
        });
      } else if (currentResponse.statusCode == 401) {
        throw Exception(
          'Invalid API key. Please get a new API key from OpenWeatherMap.',
        );
      } else {
        throw Exception(
          'Failed to load weather data. Status: ${currentResponse.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String formatTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
    );
    final int hour = dateTime.hour;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour $period';
  }

  Widget buildMainWeatherIcon(String condition) {
    String imagePath = getWeatherImagePath(condition);
    return Container(
      width: 120,
      height: 100,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.cloud, size: 80, color: Colors.white70);
        },
      ),
    );
  }

  String getWeatherImagePath(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'images/sunny.png';
      case 'clouds':
        return 'images/Cloudy.png';
      case 'rain':
        return 'images/rainy.png';
      case 'thunderstorm':
        return 'images/thunderstorm.png';
      default:
        return 'images/Cloudy.png';
    }
  }

  Widget buildHourlyForecastItem(dynamic forecast) {
    final temp = forecast['main']['temp'].round();
    final condition = forecast['weather'][0]['main'];
    final time = formatTime(forecast['dt']);
    String imagePath = getWeatherImagePath(condition);

    return Container(
      width: 70,
      child: Column(
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 35,
            height: 35,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.cloud, size: 24, color: Colors.white);
              },
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${temp}°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFF4682B4)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Getting your location...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          error!,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: getCurrentLocationWeather,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF4682B4),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Try Again',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Need help?\n1. Get API key from openweathermap.org\n2. Allow location permission\n3. Enable location services',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildMainWeatherIcon(
                                  currentWeather?['weather'][0]['main'] ??
                                      'Clouds',
                                ),
                                SizedBox(width: 20),
                                Text(
                                  '${currentWeather?['main']['temp']?.round() ?? 25}°',
                                  style: TextStyle(
                                    fontSize: 120,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black87,
                                    height: 0.9,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _formatWeatherDescription(
                                currentWeather?['weather'][0]['description'] ??
                                    'partly cloudy',
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 40),
                            Text(
                              currentCity ?? 'Your Location',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${currentWeather?['main']['temp_max']?.round() ?? 30}° / ${currentWeather?['main']['temp_min']?.round() ?? 24}° Feels like ${currentWeather?['main']['feels_like']?.round() ?? 25}°',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hourlyForecast != null && hourlyForecast!.isNotEmpty)
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 40),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: hourlyForecast!.map((forecast) {
                            return buildHourlyForecastItem(forecast);
                          }).toList(),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  String _formatWeatherDescription(String description) {
    return description
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
