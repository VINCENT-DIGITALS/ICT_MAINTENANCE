import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class CompletedRequestService {
  final String baseUrl = "${kBaseUrl}/completed"; // Replace with your actual base URL

  Future<Map<String, dynamic>> fetchCompletedRequests() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          return {
            'completedRequests': List<Map<String, dynamic>>.from(
                data['completedRequests'] ?? []),
            'evaluatedRequests': List<Map<String, dynamic>>.from(
                data['evaluatedRequests'] ?? []),
            'deniedRequests':
                List<Map<String, dynamic>>.from(data['deniedRequests'] ?? []),
            'cancelledRequests': List<Map<String, dynamic>>.from(
                data['cancelledRequests'] ?? []),
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
