import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    await Provider.of<AuthProvider>(context, listen: false).fetchProfile();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(child: Text("Failed to load profile."));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user['image']),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "${user['firstName']} ${user['lastName']}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(title: Text("Username: ${user['username']}")),
            ListTile(title: Text("Email: ${user['email']}")),
            ListTile(title: Text("Phone: ${user['phone']}")),
            ListTile(title: Text("Gender: ${user['gender']}")),
            ListTile(title: Text("Age: ${user['age']}")),
            ListTile(title: Text("Birthdate: ${user['birthDate']}")),
            ListTile(title: Text("Blood Group: ${user['bloodGroup']}")),
            ListTile(title: Text("Eye Color: ${user['eyeColor']}")),
            ListTile(title: Text("Hair: ${user['hair']['color']} - ${user['hair']['type']}")),
            ListTile(
              title: Text("Address: ${user['address']['address']}, ${user['address']['city']}, ${user['address']['country']}"),
            ),
            ListTile(
              title: Text("University: ${user['university']}"),
            ),
            ListTile(
              title: Text("Company: ${user['company']['name']}"),
              subtitle: Text("${user['company']['title']} - ${user['company']['department']}"),
            ),
            ListTile(
              title: Text("Crypto Wallet: ${user['crypto']['wallet']} (${user['crypto']['coin']})"),
            ),
          ],
        ),
      ),
    );
  }
}
