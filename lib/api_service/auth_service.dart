import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      "http://vincent-digitals.atwebpages.com/flutter_api/auth/login.php"; // Change this

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    final data = jsonDecode(response.body);
    if (data["success"]) {
      return true;
    } else {
      return false;
    }
  }
}
