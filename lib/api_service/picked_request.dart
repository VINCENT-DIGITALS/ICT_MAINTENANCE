import 'dart:convert';
import 'package:http/http.dart' as http;

class PickedRequestsService {
  final String baseUrl = "http://192.168.43.128/ServiceTrackerGithub/api/picked"; // Replace with your actual base URL

  Future<List<Map<String, dynamic>>> fetchPickedRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final List<dynamic> pickedRequests = jsonResponse['data']['pickedRequests'];

          // Return the entire object for each request
          return pickedRequests.map<Map<String, dynamic>>((request) {
            return Map<String, dynamic>.from(request);
          }).toList();
        } else {
          throw Exception("Invalid response structure or empty data.");
        }
      } else {
        throw Exception("Failed to fetch requests: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching pending requests: $e");
    }
  }
}
