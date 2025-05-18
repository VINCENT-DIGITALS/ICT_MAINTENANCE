import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class IncidentReportService {
  final String baseUrl = kBaseUrl;

  Future<Map<String, dynamic>> fetchIncidentReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/incident-reports'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          return {
            'incidents': List<Map<String, dynamic>>.from(data['incidents'] ?? []),
            'incidentsCount': data['incidentsCount'] ?? 0,
            'categories': Map<String, dynamic>.from(data['categories'] ?? {}),
            'technicians': List<Map<String, dynamic>>.from(data['technicians'] ?? []),
          };
        } else {
          throw Exception("Invalid response structure or empty data.");
        }
      } else {
        throw Exception("Failed to fetch incident reports: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching incident reports: $e");
    }
  }

  Future<Map<String, dynamic>> resolveIncident({
    required int id,
    required String findings,
    required String recommendations,
  }) async {
    final url = Uri.parse('$baseUrl/incident-reports/resolve');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'findings': findings,
          'recommendations': recommendations,
        }),
      );
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        return jsonResponse;
      } else {
        throw Exception(jsonResponse['data']?['message'] ?? 'Failed to resolve incident.');
      }
    } catch (e) {
      throw Exception('Error resolving incident: $e');
    }
  }
}
