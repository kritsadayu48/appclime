import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myclimate/profile.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({Key? key}) : super(key: key);

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  String location = 'Enter a city';
  double? temperature;
  String weatherDescription = '';
  String weatherImage = '';

  Future<void> fetchWeather(String city) async {
    var apiKey = '6665af8f94a9cc511ae00bcaa0411d93';
    var url = Uri.parse(
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['weather'] != null && data['weather'].isNotEmpty) {
          var iconCode = data['weather'][0]['icon'];
          var iconUrl = 'http://openweathermap.org/img/wn/$iconCode@2x.png';
          setState(() {
            temperature = data['main']['temp'];
            weatherDescription = data['weather'][0]['description'];
            weatherImage = iconUrl;
          });
        } else {
          throw Exception("Invalid data structure");
        }
      } else {
        throw Exception("Failed to fetch weather data");
      }
    } catch (e) {
      print('Failed to load weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        centerTitle: true,
        // Add a leading widget to AppBar which is the menu button
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeUI()));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileUI()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search for a city',
                  hintText: 'Enter a city name',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      if (location.isNotEmpty && location != 'Enter a city') {
                        fetchWeather(location);
                      }
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    location = value;
                  });
                },
              ),
            ),
            if (weatherImage.isNotEmpty)
              Center(
                  child: Image.network(weatherImage, width: 100, height: 100)),
            if (temperature != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        location,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        '${temperature!.toStringAsFixed(1)}°C',
                        style: TextStyle(fontSize: 40),
                      ),
                      Text(
                        weatherDescription,
                        style: TextStyle(fontSize: 24, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
