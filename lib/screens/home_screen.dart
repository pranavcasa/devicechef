import 'package:devicechef/screens/recipes/recipes_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import 'profile/profile_screen.dart';
import 'device_info/device_info_screen.dart';
import 'image_picker/image_picker_screen.dart';
import '../core/battery_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  int batteryLevel = 0;
  String batteryStatus = "Unknown";

  final pages = const [
    ProfileScreen(),
    DeviceInfoScreen(),
    ImagePickerScreen(),
    RecipeListScreen(), // This should match your recipe list screen
  ];

  @override
  void initState() {
    super.initState();
    BatteryHelper.batteryStream.listen((batteryData) {
      if (mounted) {
        setState(() {
          batteryLevel = batteryData["percentage"] as int;
          batteryStatus = batteryData["status"] as String;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignment App')),
      drawer: CustomDrawer(
        onSelect: (index) => setState(() => selectedIndex = index),
      ),
      body: Stack(
        children: [
          pages[selectedIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Battery: $batteryLevel% ($batteryStatus)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ), 
    );
  }
}