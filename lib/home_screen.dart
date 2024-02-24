import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/addtional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/secrets.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

extension CapFirstLetter on String {
  String capFirstLetter() {
    return this[0].toUpperCase() + substring(1);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
  );
  final getCityName = TextEditingController();
  String cityName = 'Rajshahi';

  // calling the openweathermap api...
  late Future<Map<String, dynamic>> weather = getCurrentWeather();
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String currentAPITempUnit = 'metric';
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&units=$currentAPITempUnit&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['cod'] != '200') {
        throw 'Some error might have occurred!!';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    // implement initState;
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Sky Sensor',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: IconButton(
              onPressed: () {
                setState(
                  () {
                    weather = getCurrentWeather();
                  },
                );
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentPressure = currentWeatherData['main']['pressure'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // search bar
                  Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: TextField(
                          controller: getCityName,
                          decoration: InputDecoration(
                            filled: true,
                            enabledBorder: border,
                            focusedBorder: border,
                            fillColor: Colors.white60,
                            prefixIcon: const Icon(Icons.location_on),
                            hintText: 'Enter a City...',
                            hintStyle: const TextStyle(
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            if (getCityName.text.isNotEmpty) {
                              setState(() {
                                cityName = getCityName.text;
                                weather = getCurrentWeather();
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                              fixedSize: const Size(80, 60),
                              backgroundColor: Colors.black,
                              iconColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                              side: const BorderSide(
                                style: BorderStyle.solid,
                              )),
                          icon: const Icon(Icons.search, size: 35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    cityName.capFirstLetter(),
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$currentTemp °C',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35,
                                  ),
                                ),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  currentSky,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // weather forecast card
                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                        itemCount: 10,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final hourlyForcast = data['list'][index + 1];
                          final hourlySky =
                              data['list'][index + 1]['weather'][0]['main'];
                          data['list'][index + 1]['weather'][0]['main'];
                          final hourlyTemp =
                              hourlyForcast['main']['temp'].toString();
                          final time = DateTime.parse(hourlyForcast['dt_txt']);
                          return HourlyForcastItem(
                              icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              time: DateFormat.jz().format(time),
                              temperature: hourlyTemp);
                        }),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // additional information
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AddtionalInfoItem(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString(),
                      ),
                      AddtionalInfoItem(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWindSpeed.toString(),
                      ),
                      AddtionalInfoItem(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: currentPressure.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
