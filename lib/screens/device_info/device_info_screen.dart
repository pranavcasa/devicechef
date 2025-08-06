import 'package:flutter/material.dart';
import '../../core/device_info.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  String brand = '';
  String model = '';
  String manufacturer = '';
  String androidVersion = '';

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  void _fetchDeviceInfo() async {
    final info = await DeviceInfoHelper.getDeviceInfo();
    setState(() {
      brand = info['brand'] ?? '';
      model = info['model'] ?? '';
      manufacturer = info['manufacturer'] ?? '';
      androidVersion = info['version'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Brand: $brand', style: const TextStyle(fontSize: 18)),
            Text('Model: $model', style: const TextStyle(fontSize: 18)),
            Text('Manufacturer: $manufacturer', style: const TextStyle(fontSize: 18)),
            Text('Android Version: $androidVersion', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
