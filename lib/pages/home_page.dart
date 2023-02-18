import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_weather_cubit/constants/constants.dart';
import 'package:open_weather_cubit/cubits/weather/weather_cubit.dart';
import 'package:open_weather_cubit/pages/search_page.dart';
import 'package:open_weather_cubit/widgets/error_dialog.dart';
import 'package:recase/recase.dart';

// import 'package:http/http.dart' as http;
// import 'package:open_weather_cubit/repositories/weather_repository.dart';
// import 'package:open_weather_cubit/services/weather_api_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _city;

  ////create a call for testing
  // @override
  // void initState() {
  //   super.initState();
  //   _fetchWeather();
  // }

  // _fetchWeather() {
  //   //   WeatherRepository(
  //   //           weatherApiServices: WeatherApiServices(httpClient: http.Client()))
  //   //       .fetchWeather('london');

  //   ////context.read<WeatherCubit>().fetchWeather('london');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather'), actions: [
        IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              _city = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SearchPage();
                }),
              );
              print('city: $_city');
              if (_city != null) {
                context.read<WeatherCubit>().fetchWeather(_city!);
              }
            })
      ]),
      body: _showWeather(),
    );
  }

  String showTemperature(double temperature) {
    return temperature.toStringAsFixed(2) + '℃';
  }

  Widget showIcon(String icon) {
    return FadeInImage.assetNetwork(
      placeholder: 'assets/images/loading.gif',
      image: 'http://$kIconHost/img/wn/$icon@4x.png',
      width: 96,
      height: 96,
    );
  }

  Widget formatText(String description) {
    final formattedString = description.titleCase;
    return Text(
      formattedString,
      style: const TextStyle(fontSize: 24.0),
      textAlign: TextAlign.center,
    );
  }

//use BlocConsumer to integrate both Blocbuilder and BlocListener
  Widget _showWeather() {
    return BlocConsumer<WeatherCubit, WeatherState>(
      //builder for state
      builder: (context, state) {
        if (state.status == WeatherStatus.initial) {
          return const Center(
            child: Text(
              'Select a city',
              style: TextStyle(fontSize: 20.0),
            ),
          );
        }
        if (state.status == WeatherStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == WeatherStatus.error && state.weather.name == '') {
          return const Center(
            child: Text(
              'Select a city',
              style: TextStyle(fontSize: 20.0),
            ),
          );
        }

        // return Center(
        //   child: Text(
        //     state.weather.name,
        //     style: const TextStyle(fontSize: 18.0),
        //   ),
        // );

        // //delete the above center widgit and use the ListView widget
        return ListView(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 6,
          ),
          Text(
            state.weather.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                TimeOfDay.fromDateTime(state.weather.lastUpdated)
                    .format(context),
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(width: 10.0),
              Text(
                '(${state.weather.country})',
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          const SizedBox(
            height: 60.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                showTemperature(state.weather.temp),
                // '${state.weather.temp}',
                style: const TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 20.0),
              Column(
                children: [
                  Text(
                    showTemperature(state.weather.tempMax),
                    // '${state.weather.temp}',

                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    showTemperature(state.weather.tempMin),
                    // '${state.weather.temp}',

                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Spacer(),
              showIcon(state.weather.icon),
              Expanded(
                flex: 3,
                child: formatText(state.weather.description),
              ),
              Spacer(),
            ],
          ),
        ]);
      },
      // listener for error
      listener: (context, state) {
        if (state.status == WeatherStatus.error) {
          errorDialog(context, state.error.errMsg);

          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return AlertDialog(
          //       content: Text(state.error.errMsg),
          //     );
          //   },
          // );
        }
      },
    );
  }
}
