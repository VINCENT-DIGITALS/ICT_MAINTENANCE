import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/components/qrScanner.dart';
import 'package:servicetracker_app/components/request/PickRequestModal.dart';

class PendingRequests extends StatefulWidget {
  final String currentPage;

  const PendingRequests({Key? key, this.currentPage = 'PendingRequests'})
      : super(key: key);

  @override
  _PendingRequestsState createState() => _PendingRequestsState();
}

class _PendingRequestsState extends State<PendingRequests> {
  final ScrollController _scrollController = ScrollController();
  bool hasReports = true; // Change to false to test empty state
  List<dynamic> pendingRequests = [];

  String? selectedReportCategory;
  String? selectedPriorityCategory;

  final List<String> reportCategories = [
    "Computer & Peripheral Services",
    "Network Services",
    "Software Support",
    "Hardware Repair",
  ];

  final List<String> priorityCategories = [
    "Information Systems Divwwwwwwwwwwwwwwwwwwision",
    "HR Division",
    "Finance Division",
    "Operations Division",
  ];

  get http => null;

  @override
  void initState() {
    super.initState();
    // fetchRepairsData();
    pendingRequests = [
      {
        "title": "TN25-0143 Computer Repair",
        "requester": "Mighty Jemuel Sotto",
        "division": "Information Systems Division",
        "requestedDate": "February 14, 2025, 10:00 AM",
        "description":
            "Issue with the system booting up. Needs hardware diagnostics.",
      },
      {
        "title": "TN25-0144 Printer Issue",
        "requester": "John Doe",
        "division": "IT Support",
        "requestedDate": "February 15, 2025, 09:30 AM",
        "description": "Printer is not connecting to the network.",
      },
      {
        "title": "TN25-0144 Printer Issue",
        "requester": "John Doe",
        "division": "IT Support",
        "requestedDate": "February 15, 2025, 09:30 AM",
        "description": "Printer is not connecting to the network.",
      },
      {
        "title": "TN25-0144 Printer Issue",
        "requester": "John Doe",
        "division": "IT Support",
        "requestedDate": "February 15, 2025, 09:30 AM",
        "description": "Printer is not connecting to the network.",
      },
    ];
  }

  Future<void> fetchRepairsData() async {
    final response =
        await http.get(Uri.parse('https://your-api-url.com/repairs'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        pendingRequests =
            data['pendingRequests']; // Replace with actual API response key
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: CurvedEdgesAppBar(
        height: MediaQuery.of(context).size.height * 0.13,
        showFooter: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
          child: Stack(
            alignment: Alignment.center, // Centers the text
            children: [
              // 🔹 Back Icon (Left)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                    // Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

              // 🔹 Title (Centered)
              const Text(
                'Pending Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromRGBO(20, 33, 61, 1),

      /// 🔥 Main Layout with Fixed Bottom Buttons
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85, // Set width
                child: Column(
                  children: [
                    hasReports
                        ? _buildPendingRequest(context, pendingRequests)
                        : _buildEmptyPickedState(context),

                    const SizedBox(height: 80), // Extra space at the bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// 🔹 Fixed Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: const Color.fromRGBO(20, 33, 61, 1), // Match background color
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Last Updated: February 19, 2025, 10:30 AM",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  /// 🛠 Builds a list of Ongoing Repairs (Replace with your real data)
  Widget _buildPendingRequest(BuildContext context, List<dynamic> requests) {
    return Column(
      children: requests.map((request) {
        return Padding(
            padding:
                const EdgeInsets.only(bottom: 10), // Adds spacing between items

            child: Container(
              width: MediaQuery.of(context).size.width * 0.85, // 90% width
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request['title'] ?? "No Title",
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(request['requester'] ?? "Unknown",
                      style: const TextStyle(height: 1.0, fontSize: 14, color: Color(0xFF707070))),
                  Text(request['division'] ?? "Unknown Division", style: const TextStyle(height: 1.0, fontSize: 14, color: Color(0xFF707070))),
                  Text("Requested: ${request['requestedDate'] ?? "N/A"}", style: const TextStyle(height: 1.0, fontSize: 14, color: Color(0xFF707070))),
                  const SizedBox(height: 10),
                  const Text("Subject of request",
                      style:
                          TextStyle(fontWeight: FontWeight.w900,color: Color(0xFF000000), fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    request['description'] ?? "No details available",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF000000), height: 1.0),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                    _buildButton(
                      context, "PICK THIS REQUEST", Color(0xFF45CF7F), () {}),
                  const SizedBox(height: 10),
                ],
              ),
            ));
      }).toList(),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CustomModalPickRequest(
              title: "Request Added to Your Services",
              message:
                  "Complete the details to add this to your ongoing services",
              onConfirm: () {
                Navigator.pop(context); // Close modal first
                onPressed(); // Then navigate
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF007A33)),
        ),
      ),
    );
  }

  /// 🛠 Shows Empty State when there are no Ongoing Repairs
  Widget _buildEmptyPickedState(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85, // 90% of screen width

      padding: const EdgeInsets.fromLTRB(
          20, 5, 20, 5), // Adds spacing inside the container
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light gray background
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers content vertically
        children: const [
          // SizedBox(height: 5),
          Text(
            "Select Incident Report to get started.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
