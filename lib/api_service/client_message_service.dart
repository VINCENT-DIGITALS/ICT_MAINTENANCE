import 'dart:convert';
import 'package:http/http.dart' as http;

class ClientMessageService {
  final String baseUrl = "http://192.168.43.128/ServiceTrackerGithub/api";

  /// Send a message to a client
  Future<Map<String, dynamic>> sendMessageToClient({
    required String recipientId,
    required String serviceRequestId,
    required String subject,
    required String message,
    String? ticketNumber,
    required int technicianId,
  }) async {
    final url = Uri.parse("$baseUrl/ongoing/sendMessageToClient");

    try {
      // Create the request body
      final body = {
        'recipient_id': recipientId,
        'service_request_id': serviceRequestId,
        'subject': subject,
        'message': message,
        'ticket_number': ticketNumber,
        'technician_id': technicianId,
      };

      // Send the request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      // Parse the response
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Message sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to send message',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending message: $e',
      };
    }
  }
}
