import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class AuthService {
  static const baseUrl = 'https://dummyjson.com/auth';

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      log("Response from auth service: ${response.body}");
      final data = jsonDecode(response.body);
      return {
        'token': data['accessToken'], // <-- change here
        'user': data,
      };
    }
    return null;
  }
}
