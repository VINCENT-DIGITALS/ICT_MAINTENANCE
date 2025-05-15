import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OngoingRequestService {
  final String baseUrl =
      "http://192.168.43.128/ServiceTrackerGithub/api/ongoing";

  Future<Map<String, dynamic>> fetchOngoingAndPausedRequests() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          return {
            'ongoingRequests':
                List<Map<String, dynamic>>.from(data['ongoingRequests'] ?? []),
            'pausedRequests':
                List<Map<String, dynamic>>.from(data['pausedRequests'] ?? []),
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

  Future<Map<String, dynamic>> fetchRequestWithHistoryAndWorkingTime(
      String requestId) async {
    final url = Uri.parse("$baseUrl/historyDetails/$requestId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          return {
            'serviceRequest': data['serviceRequest'],
            'statusHistory':
                List<Map<String, dynamic>>.from(data['statusHistory']),
            'workingTimeSeconds': data['workingTimeSeconds'],
            'workingTimeFormatted': data['workingTimeFormatted'],
          };
        } else {
          throw Exception("Invalid response format or no data.");
        }
      } else {
        throw Exception("Failed to fetch details: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching request details: $e");
    }
  }

// Method to fetch available technicians for selection
  Future<List<Map<String, dynamic>>> fetchTechnicians() async {
    try {
      final response = await http.get(Uri.parse(
          "http://192.168.43.128/ServiceTrackerGithub/api/technicians"));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception("Invalid response format or no data.");
        }
      } else {
        throw Exception("Failed to fetch technicians: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching technicians: $e");
    }
  }
// Add this method to the OngoingRequestService class

// Method to update technicians for a service request
  Future<Map<String, dynamic>> updateTechnicians({
    required int requestId,
    required String primaryTechnicianId,
    required List<String> secondaryTechnicianIds,
    String? remarks,
    required String actingUserId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/service-requests/update-technicians");

      // Prepare request body according to API expectations
      final requestBody = {
        'request_id': requestId , // Convert to int as required by API
        'primary_technician_id': primaryTechnicianId,
        'secondary_technician_ids': secondaryTechnicianIds,
        'remarks': remarks ?? 'Updated via mobile app',
        'acting_user_id': actingUserId,
      };

      // Make POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return jsonResponse;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to update technicians: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating technicians: $e');
    }
  }

  // Helper method for status updates with common parameters
  Future<Map<String, dynamic>> _updateRequestStatus({
    required String requestId,
    required String philriceId,
    required String endpoint,
    String? remarks,
    int? problemId,
    int? actionId,
    File? documentationImage,
    String? location,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/$endpoint");

      // Create multipart request for file upload
      var request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['request_id'] = requestId;
      request.fields['philrice_id'] = philriceId;

      if (remarks != null) {
        request.fields['remarks'] = remarks;
      }
      if (problemId != null) {
        request.fields['problem_id'] = problemId.toString();
      }
      if (actionId != null) {
        request.fields['action_id'] = actionId.toString();
      }
      if (location != null) {
        request.fields['location'] = location;
      }

      // Add the image file if provided
      if (documentationImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'documentation',
            documentationImage.path,
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();

      // Get the response
      final response = await http.Response.fromStream(streamedResponse);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ??
              'Update failed with status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating request status: $e',
      };
    }
  } // Mark request as COMPLETED

  Future<Map<String, dynamic>> markAsCompleted({
    required String requestId,
    required String philriceId,
    String? remarks,
    int? problemId,
    int? actionId,
    File? documentationImage,
    String? location,
  }) async {
    return _updateRequestStatus(
      requestId: requestId,
      philriceId: philriceId,
      endpoint: 'complete',
      remarks: remarks,
      problemId: problemId,
      actionId: actionId,
      documentationImage: documentationImage,
      location: location,
    );
  } // Mark request as PAUSED

  Future<Map<String, dynamic>> markAsPaused({
    required String requestId,
    required String philriceId,
    String? remarks,
    int? problemId,
    int? actionId,
    File? documentationImage,
    String? location,
  }) async {
    return _updateRequestStatus(
      requestId: requestId,
      philriceId: philriceId,
      endpoint: 'pause',
      remarks: remarks,
      problemId: problemId,
      actionId: actionId,
      documentationImage: documentationImage,
      location: location,
    );
  } // Mark request as DENIED

  Future<Map<String, dynamic>> markAsDenied({
    required String requestId,
    required String philriceId,
    String? remarks,
    int? problemId,
    int? actionId,
    File? documentationImage,
    String? location,
  }) async {
    return _updateRequestStatus(
      requestId: requestId,
      philriceId: philriceId,
      endpoint: 'deny',
      remarks: remarks,
      problemId: problemId,
      actionId: actionId,
      documentationImage: documentationImage,
      location: location,
    );
  } // Mark request as CANCELLED

  Future<Map<String, dynamic>> markAsCancelled({
    required String requestId,
    required String philriceId,
    String? remarks,
    int? problemId,
    int? actionId,
    File? documentationImage,
    String? location,
  }) async {
    return _updateRequestStatus(
      requestId: requestId,
      philriceId: philriceId,
      endpoint: 'cancel',
      remarks: remarks,
      problemId: problemId,
      actionId: actionId,
      documentationImage: documentationImage,
      location: location,
    );
  }

  // Mark request as ONGOING
  Future<Map<String, dynamic>> markAsOngoing({
    required String requestId,
    required String philriceId,
    String? remarks,
    int? problemId,
    int? actionId,
    File? documentationImage,
    String? location,
  }) async {
    return _updateRequestStatus(
      requestId: requestId,
      philriceId: philriceId,
      endpoint: 'ongoing',
      remarks: remarks,
      problemId: problemId,
      actionId: actionId,
      documentationImage: documentationImage,
      location: location,
    );
  }

  // Method to fetch available problems for selection
  // Future<List<Map<String, dynamic>>> fetchProblems() async {
  //   try {
  //     final response = await http.get(Uri.parse("$baseUrl/problems"));

  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);

  //       if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
  //         return List<Map<String, dynamic>>.from(jsonResponse['data']);
  //       } else {
  //         throw Exception("Invalid response format or no data.");
  //       }
  //     } else {
  //       throw Exception("Failed to fetch problems: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     throw Exception("Error fetching problems: $e");
  //   }
  // }

  // // Method to fetch available actions for selection
  // Future<List<Map<String, dynamic>>> fetchActions() async {
  //   try {
  //     final response = await http.get(Uri.parse("$baseUrl/actions"));

  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);

  //       if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
  //         return List<Map<String, dynamic>>.from(jsonResponse['data']);
  //       } else {
  //         throw Exception("Invalid response format or no data.");
  //       }
  //     } else {
  //       throw Exception("Failed to fetch actions: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     throw Exception("Error fetching actions: $e");
  //   }
  // }




}
