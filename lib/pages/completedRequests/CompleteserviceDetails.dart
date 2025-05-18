import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:servicetracker_app/api_service/ongoing_request.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/equipmentInfoModal.dart';
import 'package:servicetracker_app/components/imageViewer.dart';
import 'package:servicetracker_app/components/request/saveProgressModal.dart';
import 'package:servicetracker_app/components/serviceHistoryModal.dart';
import 'package:servicetracker_app/components/serviceStatus.dart';
import 'package:servicetracker_app/components/showrequestdetails.dart';
import 'package:servicetracker_app/pages/ongoingRequests/equipmentDetails.dart';
import 'package:servicetracker_app/pages/ongoingRequests/messageClient.dart';
import 'package:servicetracker_app/pages/ongoingRequests/UpdateStatusScreen.dart';

class CompleteServiceDetails extends StatefulWidget {
  final Map<String, dynamic>? requestData;
  final int? requestId;
  const CompleteServiceDetails({
    Key? key,
    this.requestData,
    this.requestId,
  }) : super(key: key);

  @override
  _CompleteServiceDetailsState createState() => _CompleteServiceDetailsState();
}

class _CompleteServiceDetailsState extends State<CompleteServiceDetails> {
  final requestService = OngoingRequestService();
  Map<String, dynamic>? serviceRequest;
  List<dynamic> history = [];
  String? workingTime;
  bool isLoading = true; // Optional: show loading indicator
  // Add timer variables
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  @override
  void initState() {
    super.initState();

    // Check if requestData is provided
    if (widget.requestData != null && widget.requestData!.containsKey('id')) {
      final requestId = widget.requestData!['id'].toString();
      loadDetails(requestId);
    }
    // Or if just the ID is provided
    else if (widget.requestId != null) {
      loadDetails(widget.requestId.toString());
    } else {
      print("No request data or ID available to load details");
    }
  }

  void loadDetails(String requestId) async {
    try {
      final details =
          await requestService.fetchRequestWithHistoryAndWorkingTime(requestId);

      setState(() {
        serviceRequest = details['serviceRequest'];
        history = details['statusHistory'];
        workingTime = details['workingTimeFormatted'];
      });
    } catch (e) {
      print("Failed to load request details: $e");
    }
  }

  // Format duration to readable string (hh:mm:ss)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);
    return "${twoDigitHours}:${twoDigitMinutes}:${twoDigitSeconds}";
  }

  @override
  void dispose() {
    // Cancel timer when widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return "${_monthName(date.month)} ${date.day}, ${date.year}, ${_formatTime(date)}";
    } catch (_) {
      return "Invalid Date";
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
    if (serviceRequest == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.height * 0.22
              : MediaQuery.of(context).size.height * 0.13,
          showFooter: false,
          backgroundColor: const Color(0xFF14213D),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/CompletedRequests');
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),

                /// ✅ Title expands but still constrained for overflow in landscape
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      serviceRequest!['ticket']?['ticket_full'] ??
                          'No Ticket Available',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: SizedBox(
                      width:
                          MediaQuery.of(context).size.width * 0.85, // Set width
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Row(
                              children: [
                                // Text part
                                RichText(
                                  text: TextSpan(
                                    text: 'Status: ',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                    children: [
                                      TextSpan(
                                        text: 'Ongoing',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' by',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Avatar part
                                CircleAvatar(
                                  radius: 10, // small circle
                                  backgroundColor:
                                      Colors.grey[400], // gray color
                                  child:
                                      Container(), // empty or put initials/text if needed
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                                children: [
                                  const TextSpan(
                                    text: 'Date Requested: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: serviceRequest?['created_at'] != null
                                        ? _formatDate(
                                            serviceRequest!['created_at'])
                                        : 'No Date Available',
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                                children: [
                                  const TextSpan(
                                    text: 'Date Completed: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: serviceRequest?['completion_date'] !=
                                            null
                                        ? _formatDate(
                                            serviceRequest!['completion_date'])
                                        : 'No Date Available',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),
                            RichText(
                              text: TextSpan(
                                text: "Working time: ",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: workingTime ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),

                            RichText(
                              text: TextSpan(
                                text: "Rating: ",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: workingTime ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Rating Recievd: ",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: workingTime ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Subject of request container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      children: [
                                        const TextSpan(
                                          text: 'Subject: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: serviceRequest?[
                                                  'request_title'] ??
                                              'No Subject Available',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                      children: [
                                        const TextSpan(
                                          text: 'Description: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: serviceRequest?[
                                                  'request_description'] ??
                                              'No Description Available',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        showRequestDetailsModal(
                                            context, serviceRequest!);
                                      },
                                      child: const Text(
                                        'See Request Details',
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.85, // Set button width
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessageClient(
                                        serviceData: {
                                          "id": serviceRequest?['id'],
                                          "requesterId":
                                              serviceRequest?['requester']
                                                  ?['id'],
                                          "requester_name":
                                              serviceRequest?['requester']
                                                      ?['name'] ??
                                                  'No Requester Name Available',
                                          "ticket": serviceRequest?['ticket'],
                                          "accountable":
                                              serviceRequest?['accountable'] ??
                                                  'No Accountable Available',
                                          "request_title": serviceRequest?[
                                                  'request_title'] ??
                                              'No Title Available',
                                        },
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF45CF7F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  "MESSAGE CLIENT",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // View Equipment Info Button
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.85, // Set button width
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EquipmentDetails(
                                        // Pass both the equipment data and the history
                                        equipmentData: {
                                          "ticket": serviceRequest?['ticket']
                                                  ?['ticket_full'] ??
                                              'No Ticket Available',
                                          "title": serviceRequest?[
                                                  'request_title'] ??
                                              'No Title Available',
                                          "serialNumber": serviceRequest?[
                                                  'serial_number'] ??
                                              'No Serial Number Available',
                                          "accountable":
                                              serviceRequest?['accountable'] ??
                                                  'No Accountable Available',
                                          "division":
                                              serviceRequest?['location'] ??
                                                  'No Division Available',
                                          "dateAcquired":
                                              serviceRequest?['created_at'] ??
                                                  'No Date Acquired Available',
                                          "description": serviceRequest?[
                                                  'request_description'] ??
                                              'No Description Available',
                                        },
                                        historyData:
                                            history, // Pass the status history directly
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF45CF7F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  "VIEW EQUIPMENT INFO",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Status Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Status",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Cast the List<dynamic> to List<Map<String, dynamic>>
                                    final castHistory =
                                        history.cast<Map<String, dynamic>>();
                                    showServiceHistoryModal(
                                        context, castHistory);
                                  },
                                  child: const Text(
                                    "View Service History",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            // Display latest status history (up to 3 items)
                            if (history.isEmpty)
                              Center(
                                child: Text(
                                  "No status history available",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic),
                                ),
                              )
                            else
                              ...(() {
                                // Get up to 3 most recent history items
                                final displayHistory = history.length > 3
                                    ? history.sublist(history.length - 3)
                                    : List.from(history);

                                // Display in reverse chronological order (newest first)
                                return displayHistory.reversed.map((item) {
                                  // Format the date from created_at
                                  final DateTime createdDate =
                                      DateTime.parse(item['created_at']);
                                  final String formattedDate =
                                      "${createdDate.month.toString().padLeft(2, '0')}/${createdDate.day.toString().padLeft(2, '0')}/${createdDate.year}\n"
                                      "${createdDate.hour % 12 == 0 ? 12 : createdDate.hour % 12}:${createdDate.minute.toString().padLeft(2, '0')}${createdDate.hour >= 12 ? 'PM' : 'AM'}";

                                  // Capitalize status
                                  final String statusCapitalized =
                                      item['status'] != null
                                          ? item['status']
                                                  .toString()
                                                  .substring(0, 1)
                                                  .toUpperCase() +
                                              item['status']
                                                  .toString()
                                                  .substring(1)
                                          : '';

                                  // Combine status and remarks
                                  String statusText =
                                      "$statusCapitalized: ${item['remarks'] ?? ''}";

                                  // Add technician name
                                  if (item['technician_name'] != null) {
                                    statusText +=
                                        "\nTechnician: ${item['technician_name']}";
                                  }

                                  // Call statusItem without the imagePath parameter
                                  return statusItem(
                                      context, formattedDate, statusText);
                                }).toList();
                              })(),
                            const SizedBox(height: 20),

                            // Update Status Button
                            // SizedBox(
                            //   width: MediaQuery.of(context).size.width *
                            //       0.85, // Set button width
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) => UpdateStatusScreen(
                            //             requestData: serviceRequest,
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: Colors.green[400],
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(8),
                            //       ),
                            //       padding:
                            //           const EdgeInsets.symmetric(vertical: 12),
                            //     ),
                            //     child: const Text(
                            //       "UPDATE STATUS",
                            //       style: TextStyle(
                            //           color: Colors.white,
                            //           fontWeight: FontWeight.bold),
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 20),
                          ]))),
            ],
          ),
        ),
      ),
    );
  }
}
