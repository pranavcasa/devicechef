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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(decoration: BoxDecoration(color: Colors.blue), child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24))),
          ListTile(title: const Text('Profile'), onTap: () => onSelect(0)),
          ListTile(title: const Text('Device Info'), onTap: () => onSelect(1)),
          ListTile(title: const Text('Image Picker'), onTap: () => onSelect(2)),
          ListTile(title: const Text('Recipes'), onTap: () => onSelect(3)),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}
