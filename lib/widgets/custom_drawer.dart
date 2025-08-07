import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onSelect;
  const CustomDrawer({Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            // Drawer Header with gradient and avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Device Chef',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.person,
                    text: 'Profile',
                    onTap: () => onSelect(0),
                  ),
                  _buildDrawerItem(
                    icon: Icons.devices,
                    text: 'Device Info',
                    onTap: () => onSelect(1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.image,
                    text: 'Image Picker',
                    onTap: () => onSelect(2),
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long,
                    text: 'Recipes',
                    onTap: () => onSelect(3),
                  ),
                  const Divider(height: 30),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    text: 'Logout',
                    color: Colors.red,
                    onTap: () async {
                      await Provider.of<AuthProvider>(context, listen: false).logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      horizontalTitleGap: 5,
      onTap: onTap,
      hoverColor: Colors.blue.withOpacity(0.1),
      splashColor: Colors.blue.withOpacity(0.2),
    );
  }
}
