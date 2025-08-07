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
            // Beautiful Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    text: 'Profile',
                    onTap: () => onSelect(0),
                  ),
                  _buildDrawerItem(
                    icon: Icons.devices_other,
                    text: 'Device Info',
                    onTap: () => onSelect(1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.image_outlined,
                    text: 'Image Picker',
                    onTap: () => onSelect(2),
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt,
                    text: 'Recipes',
                    onTap: () => onSelect(3),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(thickness: 1),
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          hoverColor: Colors.blue.withOpacity(0.08),
          splashColor: Colors.blue.withOpacity(0.1),
        ),
      ),
    );
  }
}
