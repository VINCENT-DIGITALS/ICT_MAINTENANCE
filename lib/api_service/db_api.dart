import 'dart:convert';
import 'package:http/http.dart' as http;
  
class ApiService {
  static const String baseUrl = "http://vincent-digitals.atwebpages.com/flutter_api/api.php";

  // Add User
  static Future<void> addUser(String name, String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl?action=addUser"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
      }),
    );

    print(response.body);
  }

  // Get Users
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse("$baseUrl?action=getUsers"));

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data["users"];
  }
}
