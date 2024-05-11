import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class FanControlScreen extends StatefulWidget {
  final BluetoothDevice device;

  FanControlScreen({required this.device});

  @override
  _FanControlScreenState createState() => _FanControlScreenState();
}

class AnimatedFanIcon extends StatelessWidget {
  final double intensity;

  const AnimatedFanIcon({Key? key, required this.intensity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Ensures that the icon is centered in its container
      child: AnimatedRotation(
        turns: intensity, // Use intensity to control the speed of the rotation
        duration: const Duration(
            milliseconds: 300), // Adjust duration to smooth out the animation
        child: Icon(
          Icons
              .ac_unit, // Placeholder for a fan icon, replace with a suitable fan icon if available
          size: 100, // Increased size for better visibility
        ),
      ),
    );
  }
}

class _FanControlScreenState extends State<FanControlScreen> {
  BluetoothCharacteristic? intensityCharacteristic;
  double currentIntensity = 0;

  @override
  void initState() {
    super.initState();
    discoverServices();
  }

  void discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString().toUpperCase().substring(4, 8) == "0001") {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toUpperCase() ==
              "10000001-0000-0000-FDFD-FDFDFDFDFDFD") {
            intensityCharacteristic = characteristic;
          }
        }
      }
    }
    if (intensityCharacteristic == null) {
      print("Intensity characteristic not found.");
    } else {
      print("Intensity characteristic found.");
    }
  }

  void setIntensity(double value) {
    if (intensityCharacteristic == null) {
      print("No intensity characteristic found");
      return;
    }

    int intValue = (value * 65535).toInt(); // Scale slider value to uint16
    List<int> bytes = [intValue & 0xFF, (intValue >> 8) & 0xFF];

    intensityCharacteristic!.write(bytes).then((_) {
      print("Intensity set to $intValue");
    }).catchError((error) {
      print("Failed to write intensity: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Menu - LED/FAN'),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData:
                BluetoothDeviceState.connecting, // Adjust this as needed
            builder: (context, snapshot) {
              IconData icon;
              VoidCallback? onPressed;
              String tooltip;

              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  icon = Icons.bluetooth_connected;
                  tooltip = 'Disconnect';
                  onPressed = () {
                    widget.device.disconnect();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Disconnected from device')));
                  };
                  break;
                case BluetoothDeviceState.disconnected:
                  icon = Icons.bluetooth_disabled;
                  tooltip = 'Connect';
                  onPressed = () {
                    widget.device.connect();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Connecting to device')));
                  };
                  break;
                default:
                  icon = Icons.bluetooth_searching;
                  tooltip = 'Connection status unknown';
                  onPressed = null; // Optionally disable the button
                  break;
              }

              return IconButton(
                icon: Icon(icon),
                onPressed: onPressed,
                tooltip: tooltip,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Ensures vertical centering
          crossAxisAlignment:
              CrossAxisAlignment.center, // Ensures horizontal centering
          children: <Widget>[
            Text('Adjust Fan Intensity',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 20), // Add some spacing
            AnimatedFanIcon(intensity: currentIntensity), // The fan icon
            Slider(
              value: currentIntensity,
              min: 0,
              max: 1,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  currentIntensity = value;
                });
              },
              onChangeEnd: (value) {
                setIntensity(value);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                  'Current Intensity: ${(currentIntensity * 100).toStringAsFixed(2)}%',
                  style: Theme.of(context).textTheme.subtitle1),
            ),
          ],
        ),
      ),
    );
  }
}
