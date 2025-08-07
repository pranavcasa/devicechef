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
    RecipeListScreen(),
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

  Widget _buildBatteryFab() {
  
    IconData batteryIcon;
    if (batteryStatus == "Charging") {
      batteryIcon = Icons.battery_charging_full;
    } else if (batteryStatus == "Full") {
      batteryIcon = Icons.battery_full;
    } else {
      batteryIcon = Icons.battery_std;
    }

  
    Color batteryColor;
    if (batteryLevel < 20) {
      batteryColor = Colors.red;
    } else if (batteryStatus == "Charging") {
      batteryColor = Colors.green;
    } else {
      batteryColor = Colors.blueGrey;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) =>
          ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
      child: Container(
        key: ValueKey("$batteryLevel-$batteryStatus"),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: batteryStatus == "Charging"
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: 2,
                  )
                ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              batteryIcon,
              color: batteryColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              '$batteryLevel%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: batteryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDrawerSelect(int index) {
    setState(() => selectedIndex = index);
    Navigator.pop(context);
  }

  
  Positioned _getBatteryFabPositioned() {
    double? left;
    double? right;

   
    if (selectedIndex == 0 || selectedIndex == 2 || selectedIndex == 3) {
     
      left = 16;
    } else if (selectedIndex == 1) {
     
      right = 16;
    }

    return Positioned(
      left: left,
      right: right,
      bottom: 80,
      child: _buildBatteryFab(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Device Chef'),
        actions: [],
      ),
      drawer: CustomDrawer(
        onSelect: _onDrawerSelect,
      ),
      body: Stack(
        children: [
          pages[selectedIndex],

        
          _getBatteryFabPositioned(),
        ],
      ),
    );
  }
}
