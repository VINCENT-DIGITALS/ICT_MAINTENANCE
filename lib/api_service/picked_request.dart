import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class PickedRequestsService {
  final String baseUrl = kBaseUrl; // Use kBaseUrl from api_constants.dart

  Future<List<Map<String, dynamic>>> fetchPickedRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/picked'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final List<dynamic> pickedRequests =
              jsonResponse['data']['pickedRequests'];

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

  Future<Map<String, dynamic>> markAsOngoing(
      int requestId, String userIdNo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/picked/changeToOngoing/$requestId/$userIdNo'),
      );

      final jsonResponse = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          return {
            'success': true,
            'message':
                jsonResponse['message'] ?? 'Service request marked as ongoing.',
          };
        case 404:
          return {
            'success': false,
            'message': 'Service request not found.',
          };
        case 409:
          return {
            'success': false,
            'message': 'Service request is already in ongoing status.',
          };
        case 400:
          return {
            'success': false,
            'message': 'Service request is not in a picked state.',
          };
        default:
          return {
            'success': false,
            'message': jsonResponse['message'] ??
                'Failed to update request status: ${response.statusCode}',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating request: $e',
      };
    }
  } 
}
