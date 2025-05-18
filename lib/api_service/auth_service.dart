import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class AuthService {
  final String baseUrl = "${kBaseUrl}/login";

  Future<Map<String, dynamic>> login(String philriceId, String password) async {
    final response = await http.post(
      Uri.parse("${kBaseUrl}/login"),
      body: jsonEncode({
        "philrice_id": philriceId,
        "password": password,
      }),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );
    // final response = await http.post(
    //   Uri.parse(
    //       "http://vincent-digitals.atwebpages.com/flutter_api/auth/login.php"),
    //   body: jsonEncode({
    //     "philrice_id": philriceId,
    //     "password": password,
    //   }),
    //   headers: {
    //     "Content-Type": "application/json",
    //     "Accept": "application/json",
    //   },
    // );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "success": true,
        "token": data["token"],
        "user": data["user"],
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        "success": false,
        "message": error["error"] ?? "Login failed",
      };
    }
  }
}
