import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:servicetracker_app/api_service/incident_report_service.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/pages/incidentReports/IncidentReportResolvedPage.dart';
import 'package:servicetracker_app/pages/incidentReports/EditIncidentReport.dart';
import 'package:servicetracker_app/auth/sessionmanager.dart'; // Add this import

class IncidentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> incident;
  const IncidentDetailsPage({Key? key, required this.incident}) : super(key: key);

  @override
  _IncidentDetailsPageState createState() => _IncidentDetailsPageState();
}

class _IncidentDetailsPageState extends State<IncidentDetailsPage> {
  final incidentService = IncidentReportService();
  final SessionManager _sessionManager = SessionManager(); // Add session manager
  Map<String, dynamic>? incidentData;
  bool isLoading = true;
  String? currentUserId; // Add variable to store current user ID

  @override
  void initState() {
    super.initState();
    // Initialize incident data from widget
    incidentData = widget.incident;
    
    // Load incident history if available
    loadIncidentData();
    
    // Get current user ID from session
    _getCurrentUserId();
  }
  
  // Improved method to get current user ID
  void _getCurrentUserId() async {
    try {
      final user = await _sessionManager.getUser();
      if (user != null && user['id'] != null) {
        setState(() {
          currentUserId = user['id'].toString();
        });
        print("Current user ID: $currentUserId"); // Add logging for debugging
      } else {
        print("User data is incomplete or missing");
      }
    } catch (e) {
      print("Error getting current user: $e");
    }
  }
  
  void loadIncidentData() async {
    try {
      // Fetch incident data - keeping method to allow for future enhancements
      final historyData = await incidentService.getIncidentHistory(
          incidentData?['id'].toString() ?? '');

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Failed to load incident data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return "${_monthName(date.month)} ${date.day}, ${date.year}, ${_formatTime(date)}";
    } catch (_) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final suffix = date.hour >= 12 ? "PM" : "AM";
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $suffix";
  }

  @override
  Widget build(BuildContext context) {
    // Define the standard width to use throughout the UI
    final standardWidth = MediaQuery.of(context).size.width * 0.85;
    
    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.height * 0.22
              : MediaQuery.of(context).size.height * 0.13,
          showFooter: false,
          backgroundColor: const Color(0xFF14213D),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Incident No. ${incidentData?['id'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: isLoading 
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        width: standardWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Status: ',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                    children: [
                                      TextSpan(
                                        text: incidentData?['status'] ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: incidentData?['status'] == 'Resolved' 
                                              ? Colors.green 
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                
                                // Reporter avatar
                                CircleAvatar(
                                  radius: 10, // small circle
                                  backgroundColor: Colors.grey[400],
                                  child: Container(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            
                            // Incident title
                            Text(
                              incidentData?['incident_name'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold
                              ),
                            ),

                            const SizedBox(height: 10),
                            
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                children: [
                                  const TextSpan(
                                    text: 'Reported by: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: incidentData?['reporter_name'] ?? 'Unknown',
                                  ),
                                ],
                              ),
                            ),

                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                children: [
                                  const TextSpan(
                                    text: 'Date Reported: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: _formatDate(incidentData?['date_reported']),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),
                            
                            // Priority level
                            Container(
                              width: standardWidth,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: incidentData?['priority_level'] == 'High'
                                    ? Colors.red
                                    : Color(0xFF007A33), // Green for Normal priority
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${incidentData?['priority_level'] ?? 'Normal'} PRIORITY",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Incident details container
                            Container(
                              width: standardWidth,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Incident Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  
                                  // Structured layout with all required fields
                                  _buildDetailRow('Subject', incidentData?['subject'] ?? 'No Subject Available'),
                                  _buildDetailRow('Description', incidentData?['description'] ?? 'No Description Available'),
                                  _buildDetailRow('Incident Nature', incidentData?['incident_nature'] ?? 'Not Available'),
                                  _buildDetailRow('Incident Date', _formatDate(incidentData?['incident_date'])),
                                  _buildDetailRow('Location', incidentData?['location'] ?? 'No Location Available'),
                                  _buildDetailRow('Impact', incidentData?['impact'] ?? 'No Impact Information Available'),
                                  _buildDetailRow('Affected Areas', incidentData?['affected_areas'] ?? 'No Affected Areas Information Available'),
                                  
                                  const SizedBox(height: 15),
                                  
                                  // Reporter details section
                                  const Text(
                                    'Reporter Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  _buildDetailRow('Name', incidentData?['reporter_name'] ?? 'Unknown'),
                                  _buildDetailRow('Position', incidentData?['reporter_position'] ?? 'Not Available'),
                                  
                                  const SizedBox(height: 15),
                                  
                                  // Verifier and approver section
                                  const Text(
                                    'Verification & Approval',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  _buildDetailRow('Verifier', incidentData?['verifier_name'] ?? 'Not Assigned'),
                                  _buildDetailRow('Approver', incidentData?['approver_name'] ?? 'Not Assigned'),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Only show Edit incident button if reporter_id matches currentUserId
                                  if (currentUserId != null && 
                                      incidentData?['reporter_id']?.toString() == currentUserId)
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to edit incident page using MaterialPageRoute
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditIncidentReport(
                                                incident: incidentData!,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Edit Incident',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Findings and Recommendations section (if available)
                            if (incidentData?['findings'] != null) Container(
                              width: standardWidth,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Findings and Recommendations',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                      children: [
                                        const TextSpan(
                                          text: 'Findings: ',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: incidentData?['findings'] ?? 'N/A',
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 10),
                                  
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      children: [
                                        const TextSpan(
                                          text: 'Recommendations: ',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: incidentData?['recommendations'] ?? 'N/A',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Mark as Resolved Button (only show if not already resolved)
                            if (incidentData?['status'] != 'Resolved')
                              SizedBox(
                                width: standardWidth,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => IncidentReportResolvedPage(
                                          incidentNumber: incidentData?['id'].toString() ?? '',
                                          incidentName: incidentData?['incident_name'] ?? 'Unnamed Incident',
                                          isResolved: false,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007A33),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    "MARK AS RESOLVED",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Add this helper method inside the class to create consistent detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
            ),
          ],
        ),
      ),
    );
  }
}
