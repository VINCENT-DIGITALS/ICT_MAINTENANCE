import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http:/192.168.43.128/login.php"; // Change this

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    final data = jsonDecode(response.body);
    return data["success"];
  }
}
