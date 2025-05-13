import 'dart:convert';
import 'package:http/http.dart' as http;

class CompletedRequestService {
  final String baseUrl = "http://192.168.43.128/ServiceTrackerGithub/api/completed"; // Replace with your actual base URL

  Future<List<Map<String, dynamic>>> fetchCompletedRequests() async {
   try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          return {
            'ongoingRequests': List<Map<String, dynamic>>.from(data['ongoingRequests'] ?? []),
            'pausedRequests': List<Map<String, dynamic>>.from(data['pausedRequests'] ?? []),
          };
        } else {
          throw Exception("Invalid response structure or empty data.");
        }
      } else {
        throw Exception("Failed to fetch requests: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching requests: $e");
    }
  }
}
