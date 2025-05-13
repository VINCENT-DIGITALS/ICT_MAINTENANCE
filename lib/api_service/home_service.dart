import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardService {
  final String baseUrl = 'http://192.168.43.128/ServiceTrackerGithub/api';

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
}
