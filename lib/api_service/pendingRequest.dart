import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class PendingRequestService {
  final String baseUrl = kBaseUrl; // Use kBaseUrl from api_constants.dart

  Future<List<Map<String, dynamic>>> fetchPendingRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pending'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final List<dynamic> pendingRequests =
              jsonResponse['data']['pendingRequests'];

          // Return the entire object for each request
          return pendingRequests.map<Map<String, dynamic>>((request) {
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

  Future<Map<String, dynamic>> markAsPicked(
      int requestId, String userIdNo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pending/changeToPicked/$requestId/$userIdNo'),
      );

      final jsonResponse = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'Request picked successfully',
          };
        case 404:
          return {
            'success': false,
            'message': 'Service request not found.',
          };
        case 409:
          return {
            'success': false,
            'message':
                'Service request has already been picked by another technician.',
          };
        case 400:
          return {
            'success': false,
            'message': 'Service request is not in a pending state.',
          };
        default:
          return {
            'success': false,
            'message': jsonResponse['message'] ??
                'Failed to pick request: ${response.statusCode}',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error picking request: $e',
      };
    }
  }
}
