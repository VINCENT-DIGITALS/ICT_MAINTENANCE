import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servicetracker_app/api_service/api_constants.dart';
import 'package:servicetracker_app/auth/sessionmanager.dart';

class IncidentReportService {
  final SessionManager _sessionManager = SessionManager();
  final String baseUrl = kBaseUrl;

  Future<Map<String, dynamic>> fetchIncidentReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/incident-reports'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          return {
            'incidents':
                List<Map<String, dynamic>>.from(data['incidents'] ?? []),
            'incidentsCount': data['incidentsCount'] ?? 0,
            'categories': Map<String, dynamic>.from(data['categories'] ?? {}),
            'technicians':
                List<Map<String, dynamic>>.from(data['technicians'] ?? []),
          };
        } else {
          throw Exception("Invalid response structure or empty data.");
        }
      } else {
        throw Exception(
            "Failed to fetch incident reports: ${response.statusCode}");
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
        throw Exception(
            jsonResponse['data']?['message'] ?? 'Failed to resolve incident.');
      }
    } catch (e) {
      throw Exception('Error resolving incident: $e');
    }
  }

  Future<Map<String, dynamic>> submitIncidentReport({
    required String priorityLevel,
    required String incidentName,
    required String incidentNature,
    required DateTime incidentDate,
    required TimeOfDay incidentTime,
    required String location,
    String? subject,
    String? description,
    String? impact,
    String? affectedAreas,
    String? verifierId,
    String? approverId,
  }) async {
    try {
      final token = await _sessionManager.getToken();
      final user = await _sessionManager.getUser();
      final int reporterId = int.parse(user!['id'].toString());

      // Format the date and time as required by the API
      final String formattedDate =
          "${incidentDate.year}-${incidentDate.month.toString().padLeft(2, '0')}-${incidentDate.day.toString().padLeft(2, '0')}";
      final String formattedTime =
          "${incidentTime.hour.toString().padLeft(2, '0')}:${incidentTime.minute.toString().padLeft(2, '0')}:00";

      final Map<String, dynamic> requestData = {
        'priority_level': priorityLevel,
        'incident_name': incidentName,
        'subject': subject,
        'description': description,
        'incident_nature': incidentNature,
        'incident_date': formattedDate,
        'incident_time': formattedTime,
        'location': location,
        'reporter_id': reporterId,
        'impact': impact,
        'affected_areas': affectedAreas,
      };

      // Add optional fields if provided
      if (verifierId != null) {
        requestData['verifier_id'] = verifierId;
      }

      if (approverId != null) {
        requestData['approver_id'] = approverId;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/incident-reports/store'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        return responseData;
      } else {
        throw Exception(
            'Failed to submit incident report: ${responseData['data']['message']}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
