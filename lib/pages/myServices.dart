import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/qrScanner.dart';

class MyServices extends StatefulWidget {
  final String currentPage;

  const MyServices({Key? key, this.currentPage = 'MyServices'})
      : super(key: key);

  @override
  _MyServicesState createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  final ScrollController _scrollController = ScrollController();
  bool hasOngoingRepairs = true; // Change to false to test empty state
  List<dynamic> pickedRequests = [];
  List<dynamic> ongoingRepairs = [];
  List<dynamic> completeRepairs = [];

  get http => null;

  @override
  void initState() {
    super.initState();
    // fetchRepairsData();
    pickedRequests = [
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
    ];

    ongoingRepairs = [
      {
        "title": "TN25-0145 Server Maintenance",
        "requester": "Jane Smith",
        "division": "Network Administration",
        "requestedDate": "February 13, 2025, 2:00 PM",
        "location": "Data Center",
        "status": "Ongoing - Awaiting Parts",
        "lastUpdated": "February 19, 2025 | 3:00 PM",
      },
      {
        "title": "TN25-0146 Laptop Repair",
        "requester": "Alice Johnson",
        "division": "Development Team",
        "requestedDate": "February 12, 2025, 11:45 AM",
        "location": "IT Lab",
        "status": "Being Diagnosed",
        "lastUpdated": "February 18, 2025 | 10:15 AM",
      },
    ];
    completeRepairs = [
      {
        "title": "TN25-0145 Server Maintenance",
        "requester": "Jane Smith",
        "division": "Network Administration",
        "requestedDate": "February 13, 2025, 2:00 PM",
        "location": "Data Center",
        "status": "Ongoing - Awaiting Parts",
        "lastUpdated": "February 19, 2025 | 3:00 PM",
      },
      {
        "title": "TN25-0146 Laptop Repair",
        "requester": "Alice Johnson",
        "division": "Development Team",
        "requestedDate": "February 12, 2025, 11:45 AM",
        "location": "IT Lab",
        "status": "Being Diagnosed",
        "lastUpdated": "February 18, 2025 | 10:15 AM",
      },
    ];
  }

  Future<void> fetchRepairsData() async {
    final response =
        await http.get(Uri.parse('https://your-api-url.com/repairs'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        pickedRequests =
            data['pickedRequests']; // Replace with actual API response key
        ongoingRepairs =
            data['ongoingRepairs']; // Replace with actual API response key
        completeRepairs =
            data['completeRepairs']; // Replace with actual API response key
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
                'My Services',
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
      backgroundColor: Colors.white,

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
                    /// 🔹 Picked Requests Title & List
                    _buildSectionTitle("Picked Requests"),
                    hasOngoingRepairs
                        ? _buildPickedRequests(context, pickedRequests)
                        : _buildEmptyPickedState(context),

                    /// 🔹 Ongoing Services Title & List
                    _buildSectionTitle("Ongoing Services"),
                    hasOngoingRepairs
                        ? _buildOngoingRepairs(context, ongoingRepairs)
                        : _buildEmptyOngoingState(context),

                    /// 🔹 Completed Services Title & List
                    _buildSectionTitle("Completed Services"),
                    hasOngoingRepairs
                        ? _buildCompleteRepairs(context, completeRepairs)
                        : _buildEmptyPickedState(context),

                    const SizedBox(height: 80), // Extra space at the bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 25, 0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 🛠 Builds a list of Ongoing Repairs (Replace with your real data)
  Widget _buildPickedRequests(BuildContext context, List<dynamic> requests) {
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
                      style: const TextStyle(fontSize: 14)),
                  Text(request['division'] ?? "Unknown Division"),
                  Text("Requested: ${request['requestedDate'] ?? "N/A"}"),
                  const SizedBox(height: 10),
                  const Text("Subject of request",
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    request['description'] ?? "No details available",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500, height: 1.2),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "COMPLETE DETAILS",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Remove from my list",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      }).toList(),
    );
  }

  /// 🛠 Builds a list of Ongoing Repairs (Replace with your real data)
  Widget _buildOngoingRepairs(BuildContext context, List<dynamic> repairs) {
    return Column(
      children: repairs.map((repair) {
        return Padding(
            padding:
                const EdgeInsets.only(bottom: 10), // Adds spacing between items

            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: BoxDecoration(
               color: const Color(0xFFEEEEEE), // Equivalent to Colors.grey[200]
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repair['title'] ?? "No Title",
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(repair['requester'] ?? "Unknown",
                      style: const TextStyle(fontSize: 14)),
                  Text(repair['division'] ?? "Unknown Division"),
                  Text("Requested: ${repair['requestedDate'] ?? "N/A"}"),
                  const SizedBox(height: 5),
                  Text("Current Location: ${repair['location'] ?? "Unknown"}"),
                  Text("Status: ${repair['status'] ?? "Unknown"}"),
                  Text("Last Updated: ${repair['lastUpdated'] ?? "N/A"}"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "COMPLETE DETAILS",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ));
      }).toList(),
    );
  }

  /// 🛠 Builds a list of Ongoing Repairs (Replace with your real data)
  Widget _buildCompleteRepairs(BuildContext context, List<dynamic> repairs) {
    return Column(
      children: repairs.map((repair) {
        return Padding(
            padding:
                const EdgeInsets.only(bottom: 10), // Adds spacing between items

            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repair['title'] ?? "No Title",
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(repair['requester'] ?? "Unknown",
                      style: const TextStyle(fontSize: 14)),
                  Text(repair['division'] ?? "Unknown Division"),
                  Text("Requested: ${repair['requestedDate'] ?? "N/A"}"),
                  const SizedBox(height: 5),
                  Text("Current Location: ${repair['location'] ?? "Unknown"}"),
                  Text("Status: ${repair['status'] ?? "Unknown"}"),
                  Text("Last Updated: ${repair['lastUpdated'] ?? "N/A"}"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "COMPLETE DETAILS",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ));
      }).toList(),
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
            "Select from pending requests to get started.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOngoingState(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85, // 90% of screen width

      padding: const EdgeInsets.fromLTRB(
          30, 5, 30, 5), // Adds spacing inside the container
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light gray background
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers content vertically
        children: const [
          Text(
            "You have no ongoing services.", // Matches the text in the image
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          // SizedBox(height: 5),
          Text(
            "Add a new request or select from pending requests to get started.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
