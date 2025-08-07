import 'package:flutter/material.dart';
import '../../core/device_info.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  Map<String, String> deviceInfo = {
    'brand': '',
    'model': '',
    'manufacturer': '',
    'version': '',
    'processor': '',
    'ram': '',
    'storage': '',
    'screenSize': '',
    'batteryCapacity': '',
  };

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  void _fetchDeviceInfo() async {
    final info = await DeviceInfoHelper.getDeviceInfo();
    setState(() {
      deviceInfo = info;
    });
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required List<String> subtitles,
    Color color = Colors.blue,
  }) {
    return Card( 
     //levation: 3,
     color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...subtitles.map(
                    (sub) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        sub,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = deviceInfo['brand']!.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Device Info')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  buildInfoCard(
                    icon: Icons.system_update_alt,
                    color: Colors.green,
                    title: "System",
                    subtitles: [
                      "Brand: ${deviceInfo['brand']}",
                      "Manufacturer: ${deviceInfo['manufacturer']}",
                      "Model: ${deviceInfo['model']}",
                      "Android Version: ${deviceInfo['version']}",
                    ],
                  ),
                  buildInfoCard(
                    icon: Icons.memory,
                    color: Colors.orange,
                    title: "Hardware",
                    subtitles: [
                      "Processor: ${deviceInfo['processor']}",
                      "RAM: ${deviceInfo['ram']}",
                      "Storage: ${deviceInfo['storage']}",
                    ],
                  ),
                  buildInfoCard(
                    icon: Icons.phone_android,
                    color: Colors.blue,
                    title: "Display",
                    subtitles: [
                      "Screen Size: ${deviceInfo['screenSize']}",
                    ],
                  ),
                  buildInfoCard(
                    icon: Icons.battery_full,
                    color: Colors.red,
                    title: "Battery",
                    subtitles: [
                      "Capacity: ${deviceInfo['batteryCapacity']}",
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
