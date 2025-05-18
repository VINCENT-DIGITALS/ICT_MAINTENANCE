import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class NetworkService {
  static const String baseUrl = kBaseUrl;
  static const Duration timeout = Duration(seconds: 5);

  /// Checks if the device is connected to any network
  static Future<bool> isConnectedToNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Checks if the API server is reachable
  static Future<bool> isApiReachable() async {
    try {
      // Use a health check endpoint (you might need to create one in your API)
      final response = await http.get(Uri.parse('$baseUrl/ping'))
          .timeout(timeout);
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } on TimeoutException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Comprehensive check for both network connectivity and API reachability
  static Future<Map<String, dynamic>> checkConnectivity() async {
    bool hasNetwork = await isConnectedToNetwork();
    
    if (!hasNetwork) {
      return {
        'isConnected': false,
        'message': 'No network connection detected',
      };
    }
    
    bool canReachApi = await isApiReachable();
    
    if (!canReachApi) {
      return {
        'isConnected': false,
        'message': 'Cannot connect to service tracker server',
      };
    }
    
    return {
      'isConnected': true,
      'message': 'Connected to server',
    };
  }
}