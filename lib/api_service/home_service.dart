import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

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

  Future<Map<String, dynamic>> fetchFilteredDashboardData(String technicianId) async {
    // First get all the dashboard data
    final dashboardData = await fetchDashboardData();
    
    // Create a copy of the dashboard data to modify
    final Map<String, dynamic> filteredData = Map<String, dynamic>.from(dashboardData);
    
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
    filteredData['pickedRequestsCount'] = filteredData['pickedRequests']?.length ?? 0;
    filteredData['ongoingRequestsCount'] = filteredData['ongoingRequests']?.length ?? 0;
    filteredData['pausedOngoingRequestsCount'] = filteredData['pausedRequests']?.length ?? 0;
    filteredData['completedRequestsCount'] = filteredData['completedRequests']?.length ?? 0;
    filteredData['evaluatedRequestsCount'] = filteredData['evaluatedRequests']?.length ?? 0;
    filteredData['cancelledRequestsCount'] = filteredData['cancelledRequests']?.length ?? 0;
    filteredData['deniedRequestsCount'] = filteredData['deniedRequests']?.length ?? 0;
    
    return filteredData;
  }
}