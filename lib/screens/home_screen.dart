import 'package:devicechef/screens/recipes/recipes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int selectedIndex = 0;
  int batteryLevel = 0;
  String batteryStatus = "Unknown";
  
  late AnimationController _pageAnimationController;
  late AnimationController _batteryAnimationController;
  late AnimationController _appBarAnimationController;
  late Animation<double> _pageSlideAnimation;
  late Animation<double> _batteryScaleAnimation;
  late Animation<double> _appBarFadeAnimation;

  final pages = const [
    ProfileScreen(),
    DeviceInfoScreen(),
    ImagePickerScreen(),
    RecipeListScreen(),
  ];

  final pageNames = [
    "Profile",
    "Device Info", 
    "Image Tools",
    "Recipes"
  ];

  final pageIcons = [
    Icons.person_rounded,
    Icons.phone_android_rounded,
    Icons.camera_alt_rounded,
    Icons.restaurant_rounded,
  ];

  final pageColors = [
    Colors.blue, 
    Colors.blue,
    Color(0xFF3B82F6), 
    Colors.blue.shade500,
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _batteryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _pageSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _batteryScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _batteryAnimationController,
      curve: Curves.elasticOut,
    ));

    _appBarFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _pageAnimationController.forward();
    _batteryAnimationController.repeat(reverse: true);
    _appBarAnimationController.forward();

    // Battery listener
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
  void dispose() {
    _pageAnimationController.dispose();
    _batteryAnimationController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  Widget _buildEnhancedBatteryFab() {
    IconData batteryIcon;
    List<Color> gradientColors;
    
    if (batteryStatus == "Charging") {
      batteryIcon = Icons.battery_charging_full_rounded;
      gradientColors = [Colors.green.shade400, Colors.green.shade600];
    } else if (batteryStatus == "Full") {
      batteryIcon = Icons.battery_full_rounded;
      gradientColors = [Colors.blue.shade400, Colors.blue.shade600];
    } else if (batteryLevel < 20) {
      batteryIcon = Icons.battery_alert_rounded;
      gradientColors = [Colors.red.shade400, Colors.red.shade600];
    } else {
      batteryIcon = Icons.battery_std_rounded;
      gradientColors = [Colors.grey.shade400, Colors.grey.shade600];
    }

    return AnimatedBuilder(
      animation: _batteryScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: batteryStatus == "Charging" ? _batteryScaleAnimation.value : 1.0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: RotationTransition(
                turns: Tween<double>(begin: 0.1, end: 0.0).animate(animation),
                child: child,
              ),
            ),
            child: GestureDetector(
              key: ValueKey("$batteryLevel-$batteryStatus"),
              onTap: () {
                HapticFeedback.lightImpact();
                _showBatteryDetails();
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.3),
                      blurRadius: batteryStatus == "Charging" ? 20 : 12,
                      spreadRadius: batteryStatus == "Charging" ? 4 : 2,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      batteryIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$batteryLevel%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBatteryDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Battery Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBatteryDetailItem('Level', '$batteryLevel%', Icons.battery_std),
                _buildBatteryDetailItem('Status', batteryStatus, Icons.info_outline),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: pageColors[selectedIndex]),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _onDrawerSelect(int index) {
    if (index != selectedIndex) {
      _pageAnimationController.reset();
      setState(() => selectedIndex = index);
      _pageAnimationController.forward();
      HapticFeedback.selectionClick();
    }
    Navigator.pop(context);
  }

  Positioned _getBatteryFabPositioned() {
    double? left;
    double? right;

    if (selectedIndex == 0 || selectedIndex == 2 || selectedIndex == 3) {
      left = 20;
    } else if (selectedIndex == 1) {
      right = 20;
    }

    return Positioned(
      left: left,
      right: right,
      bottom: 30,
      child: _buildEnhancedBatteryFab(),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              pageColors[selectedIndex].withOpacity(0.8),
              pageColors[selectedIndex],
            ],
          ),
        ),
      ),
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      title: AnimatedBuilder(
        animation: _appBarFadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _appBarFadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.3, 0),
                end: Offset.zero,
              ).animate(_appBarFadeAnimation),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      pageIcons[selectedIndex],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    pageNames[selectedIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showNotificationPanel();
            },
          ),
        ),
      ],
    );
  }

  void _showNotificationPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.notifications_rounded, color: pageColors[selectedIndex]),
            const SizedBox(width: 12),
            const Text('Notifications'),
          ],
        ),
        content: const Text('No new notifications at the moment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: pageColors[selectedIndex]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildEnhancedAppBar(),
      drawer: CustomDrawer(
        onSelect: _onDrawerSelect,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              pageColors[selectedIndex].withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Page content with slide animation
            AnimatedBuilder(
              animation: _pageSlideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(_pageSlideAnimation),
                  child: FadeTransition(
                    opacity: _pageSlideAnimation,
                    child: pages[selectedIndex],
                  ),
                );
              },
            ),
            
            // Enhanced battery FAB
            _getBatteryFabPositioned(),
          ],
        ),
      ),
    );
  }
}

// Custom BlurFilter class for backdrop effect
class BlurFilter {
  static Widget blur({required double sigmaX, required double sigmaY}) {
    return Container(); // Placeholder - you might want to implement actual blur
  }}