import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicetracker_app/components/AddRequestModal.dart';
import 'package:servicetracker_app/components/messageSentModal.dart';
import 'api_constants.dart';
import 'package:flutter/material.dart';
import 'package:servicetracker_app/auth/sessionmanager.dart';

class DashboardService {
  final String baseUrl = kBaseUrl;

  Future<Map<String, dynamic>> fetchDashboardData() async {
    final url = Uri.parse('$baseUrl/dashboard');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return data['data'];
        } else {
          throw Exception("API returned false status");
        }
      } else {
        throw Exception("Failed to load dashboard data");
      }
    } catch (e) {
      throw Exception("Error fetching dashboard data: $e");
    }
  }

  Future<Map<String, dynamic>> fetchFilteredDashboardData(
      String technicianId) async {
    // First get all the dashboard data
    final dashboardData = await fetchDashboardData();

    // Create a copy of the dashboard data to modify
    final Map<String, dynamic> filteredData =
        Map<String, dynamic>.from(dashboardData);

    // Lists that need to be filtered by technician_id
    final listsToFilter = [
      'pickedRequests',
      'ongoingRequests',
      'pausedRequests',
      'completedRequests',
      'evaluatedRequests',
      'cancelledRequests',
      'deniedRequests'
    ];

    // Filter each list to only include items where technician_id matches the session ID
    for (final key in listsToFilter) {
      if (filteredData.containsKey(key) && filteredData[key] is List) {
        filteredData[key] = (filteredData[key] as List)
            .where((request) =>
                request is Map &&
                request.containsKey('technician_id') &&
                request['technician_id'] == technicianId)
            .toList();
      }
    }

    // Update the counts for each filtered list
    filteredData['pickedRequestsCount'] =
        filteredData['pickedRequests']?.length ?? 0;
    filteredData['ongoingRequestsCount'] =
        filteredData['ongoingRequests']?.length ?? 0;
    filteredData['pausedOngoingRequestsCount'] =
        filteredData['pausedRequests']?.length ?? 0;
    filteredData['completedRequestsCount'] =
        filteredData['completedRequests']?.length ?? 0;
    filteredData['evaluatedRequestsCount'] =
        filteredData['evaluatedRequests']?.length ?? 0;
    filteredData['cancelledRequestsCount'] =
        filteredData['cancelledRequests']?.length ?? 0;
    filteredData['deniedRequestsCount'] =
        filteredData['deniedRequests']?.length ?? 0;

    return filteredData;
  }

  Future<bool> checkPendingRequestsLimitAndPrompt(BuildContext context) async {
    final session = SessionManager();
    final user = await session.getUser();
    final String? philriceId = user?['philrice_id'];

    if (philriceId == null) {
      print("No philrice_id found in session");
      return false;
    }

    final url = Uri.parse(
        '$baseUrl/dashboard/checkUserPendingRequestsLimit/$philriceId');

    try {
      print("Checking pending requests limit for user: $philriceId");

      final response = await http.post(url,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode({"philrice_id": philriceId}));

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract data from response
        final hasReachedLimit = data['data']['has_reached_limit'] ?? false;
        final limitType = data['data']['limit_type'] ?? 'none';
        final message = data['data']['message'] ?? 'You have reached the maximum limit.';
        final unratedCount = data['data']['unrated_requests_count'] ?? 0;
        final pendingCount = data['data']['pending_requests_count'] ?? 0;
        final maxAllowed = data['data']['max_allowed'] ?? 3;

        // Debug the actual values
        print("Has reached limit: $hasReachedLimit");
        print("Limit type: $limitType");
        print("Pending count: $pendingCount/$maxAllowed");
        print("Unrated count: $unratedCount");
        print("Message: $message");

        if (hasReachedLimit && context.mounted) {
          // Create title based on limit type
          String title = limitType == 'unrated' 
              ? "Please Rate Your Completed Requests"
              : "Maximum Pending Requests Reached";
              
          // Build modal dialog based on limit type
          if (limitType == 'unrated') {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: CustomAddRequestModal(
                          title: title,
                          message: "Please rate your completed requests before creating a new request. You have $unratedCount or more completed requests that need to be rated first.",
                          onConfirm: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // For pending requests limit
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: CustomAddRequestModal(
                          title: title,
                          message: "You have reached the maximum limit of $maxAllowed pending service requests. Please wait for your existing requests to be processed before submitting new ones.",
                          onConfirm: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return true;
        } else {
          print("You can submit more requests. Pending: $pendingCount/$maxAllowed");
        }
      } else {
        print("Error response: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception when checking pending requests limit: $e");
    }

    return false;
  }

  Future<Map<String, dynamic>> storeNewRequest(
      Map<String, dynamic> requestData) async {
    final url = Uri.parse('$baseUrl/dashboard/storeNewRequest');
    try {
      // Send as form-urlencoded data which Laravel expects for Request $request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestData
            .map((key, value) => MapEntry(key, value?.toString() ?? "")),
      );

      try {
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 302) {
          // Handle redirect - get redirect location
          final redirectLocation = response.headers['location'];
          return {
            'status': false,
            'data': {
              'message':
                  'Server redirected to: $redirectLocation. This usually means the endpoint URL is incorrect or you need to be authenticated.'
            }
          };
        } else {
          return {
            'status': false,
            'data': {
              'message':
                  'Server returned status code ${response.statusCode}: ${response.body}'
            }
          };
        }
      } catch (e) {
        return {
          'status': false,
          'data': {
            'message':
                'Error parsing server response: $e. Response body: ${response.body.substring(0, 100)}...'
          }
        };
      }
    } catch (e) {
      return {
        'status': false,
        'data': {'message': 'Error creating service request: $e'}
      };
    }
  }
}
