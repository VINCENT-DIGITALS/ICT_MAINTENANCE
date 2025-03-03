import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/equipmentInfoModal.dart';
import 'package:servicetracker_app/components/imageViewer.dart';
import 'package:servicetracker_app/components/request/saveProgressModal.dart';
import 'package:servicetracker_app/components/serviceHistoryModal.dart';
import 'package:servicetracker_app/components/serviceStatus.dart';

class ServiceDetails extends StatefulWidget {
  const ServiceDetails({Key? key}) : super(key: key);

  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height: MediaQuery.of(context).size.height * 0.13,
          showFooter: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            child: Stack(
              alignment: Alignment.center, // Centers the text
              children: [
                // 🔹 Back Icon (Left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/MyServices');
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
                  'TN25-0143',
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
                            const Text(
                              "TN25-0143 Computer Repair",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Mighty Jemuel Sotto\nInformation Systems Division",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Requested: February 14, 2025, 10:00AM",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 15),

                            // Subject of request
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Subject of request",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy eirmod tempor.",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),

                            // View Equipment Info Button
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.85, // Set button width
                              child: ElevatedButton(
                                onPressed: () {
                                  showEquipmentInfoModal(context, {
                                    "serialNumber": "##############",
                                    "accountable": "Luis Alejandre Tamani",
                                    "division": "Information Systems Division",
                                    "dateAcquired": "January 5, 2019",
                                    "description":
                                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[400],
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
                                    showServiceHistoryModal(context, [
                                      {
                                        "title": "TN25-0143 Computer Repair",
                                        "requestDate":
                                            "February 15, 2025, 10:30 AM",
                                        "completionDate":
                                            "February 18, 2025, 2:45 PM",
                                        "technician": "John Doe",
                                      },
                                      {
                                        "title": "TN25-0143 Computer Repair",
                                        "requestDate":
                                            "February 15, 2025, 10:30 AM",
                                        "completionDate":
                                            "February 18, 2025, 2:45 PM",
                                        "technician": "John Doe",
                                      },
                                    ]);
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
                            const SizedBox(height: 10),

                            // Status History
                            statusItem(context, "02/14/2025\n10:00AM",
                                "Repair requested"),
                            statusItem(context, "02/14/2025\n2:15PM",
                                "Request received\nTechnician: Ranniel Lauriaga\nLocation: Library",
                                imagePath: "assets/images/LOGOAPP.png"),
                            statusItem(context, "02/14/2025\n3:15PM",
                                "Change of location:\nISD Server Room"),
                            statusItem(context, "02/15/2025\n9:00AM",
                                "Updated status:\nServiceable - for item procurement"),
                            const SizedBox(height: 20),

                            // Update Status Button
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.85, // Set button width
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/UpdateRequest');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  "UPDATE STATUS",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ]))),
            ],
          ),
        ),
      ),
    );
  }
}
