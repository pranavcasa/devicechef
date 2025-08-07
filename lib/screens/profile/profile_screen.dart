import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      body: Center(
        child: user == null
            ? const Text('No user info available')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user['image'] ?? ''),
                  ),
                  const SizedBox(height: 16),
                  Text('${user['firstName']} ${user['lastName']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(user['email'] ?? ''),
                  const SizedBox(height: 8),
                  Text('Username: ${user['username'] ?? ''}'),
                ],
              ),
      ),
    );
  }
}
