import 'package:flutter/material.dart';
import 'widgets.dart';

class WeatherScreen extends StatelessWidget {
  final double temperature;
  final double humid;

  const WeatherScreen(
      {Key? key, required this.temperature, required this.humid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Temperature:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                  text: CharacteristicTile.parseTemperature(
                      [temperature.toInt()])),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Humidity:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                  text: CharacteristicTile.parseHumidity([humid.toInt()])),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

