import 'package:flutter/material.dart';
import 'widgets.dart';

class WeatherScreen extends StatelessWidget {
  final double temperature;
  final double humidity;

  const WeatherScreen(
      {Key? key, required this.temperature, required this.humidity})
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
            _buildInfoBox(
              title: 'Temperature:',
              value: '$temperature °C',
              color: Colors.blue, // Color theme for temperature
            ),
            SizedBox(height: 20),
            _buildInfoBox(
              title: 'Humidity:',
              value: '$humidity %',
              color: Colors.orange, // Color theme for humidity
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(
      {required String title, required String value, required Color color}) {
    return Container(
      width: 250,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color, // Apply color theme
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
