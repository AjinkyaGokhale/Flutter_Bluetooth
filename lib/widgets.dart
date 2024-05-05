// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'fan.dart'; 

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;


  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
    }
  

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }
 

  
  @override
 Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade100, // Background color
          textStyle: const TextStyle(color: Colors.white), // Text color
        ),
        onPressed: (result.advertisementData.connectable) ? onTap : null,
        child: Text('CONNECT'),
      ),
      children: <Widget>[
        _buildAdvRow(
            context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level',
            '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(context, 'Manufacturer Data',
            getNiceManufacturerData(result.advertisementData.manufacturerData)),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data',
            getNiceServiceData(result.advertisementData.serviceData)),
      ],
    );
  }

}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {Key? key, required this.service, required this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.length > 0) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Service'),
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color))
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: Text('Service'),
        subtitle:
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
      required this.characteristic,
      required this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificationPressed})
      : super(key: key);


      // Define the parseValue method here to ensure it's accessible
  String parseValue(String uuid, List<int> value) {
    switch (uuid.toUpperCase().substring(4, 8)) {
      case "2A6E": // Assuming you're using standard UUID for temperature
      case "2A1C": // Additional UUID for temperature if used
        return parseTemperature(value);
      case "2A6F": // Assuming standard UUID for humidity
        return parseHumidity(value);
      default:
        return getNiceHexArray(value); // Fallback to hex display for unknown characteristics
    }
  }
  // Define the characteristic label method here
  String getCharacteristicLabel(String uuid) {
    switch (uuid.toUpperCase().substring(4, 8)) {
      case "2A6E":
      case "2A1C":
        return "Temperature";
      case "2A6F":
        return "Humidity";
      default:
        return "Characteristic";
    }
  }

  // Assuming these methods are globally accessible or defined elsewhere correctly
 String parseTemperature(List<int> value) {
    if (value.length < 2) return "N/A"; // Ensure there are at least 2 bytes for a 16-bit integer

    // Convert two bytes to a 16-bit signed integer (little-endian)
    int tempRaw = value[0] | (value[1] << 8);
    if (tempRaw >= 32768) tempRaw -= 65536; // Convert from unsigned to signed

    // Assuming the temperature is scaled to hundreds of degrees (e.g., 215 represents 21.5 °C)
    double temperature = tempRaw / 100.0;

    // Format to two decimal places
    return "${temperature.toStringAsFixed(2)} °C";
}

String parseHumidity(List<int> value) {
    if (value.length < 4) return "N/A"; // Ensure there are at least 4 bytes for a 32-bit integer

    // Convert four bytes to a 32-bit unsigned integer (little-endian)
    int humidRaw = value[0] | (value[1] << 8) | (value[2] << 16) | (value[3] << 24);

    // Assuming the humidity is scaled to hundredths (e.g., 5050 represents 50.50%)
    double humid = humidRaw / 100.0;

    // Format to two decimal places
    return "${humid.toStringAsFixed(2)}%";
}

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
  stream: characteristic.value,
  initialData: characteristic.lastValue,
  builder: (c, snapshot) {
    final value = snapshot.data ?? [];
    return ExpansionTile(
      title: ListTile(
        title: Text(getCharacteristicLabel(characteristic.uuid.toString())),
        subtitle: Text(parseValue(characteristic.uuid.toString(), value)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.file_download), onPressed: onReadPressed),
          IconButton(icon: Icon(Icons.file_upload), onPressed: onWritePressed),
          IconButton(
            icon: Icon(characteristic.isNotifying ? Icons.sync_disabled : Icons.sync),
            onPressed: onNotificationPressed
          )
        ],
      ),
      children: descriptorTiles,
    );
  },
);
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final BluetoothDevice device;

  const DescriptorTile(
      {Key? key,
      required this.descriptor,
      this.onReadPressed,
      this.onWritePressed,
      required this.device})
      : super(key: key);

 @override
  Widget build(BuildContext context) {
    return Card( // Wrap with a Card for better UI presentation
      child: Column(
        children: <Widget>[
          ListTile(
            title: const Text('Descriptor'),
            subtitle: Text('0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.file_download, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                  onPressed: onReadPressed,
                ),
                IconButton(
                  icon: Icon(Icons.file_upload, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                  onPressed: onWritePressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key? key, required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purpleAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.titleMedium,
        ),
        trailing: Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.titleMedium?.color,
        ),
      ),
    );
  }
}