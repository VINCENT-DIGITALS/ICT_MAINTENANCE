import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/equipmentInfoModal.dart';
import 'package:servicetracker_app/components/imageViewer.dart';
import 'package:servicetracker_app/components/request/saveProgressModal.dart';
import 'package:servicetracker_app/components/serviceHistoryModal.dart';
import 'package:servicetracker_app/components/serviceStatus.dart';

class IncidentReportDetails extends StatefulWidget {
  const IncidentReportDetails({Key? key}) : super(key: key);

  @override
  _IncidentReportDetailsState createState() => _IncidentReportDetailsState();
}

class _IncidentReportDetailsState extends State<IncidentReportDetails> {
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
                  width: MediaQuery.of(context).size.width * 0.85, // Set width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        "Incident No. 117",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),

                      const Text(
                        "PhilRice - Negros Internet is Down, Globe ISP",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),

                      const Text(
                        "Reported by: Ranniel Lauriaga\nFebruary 11, 2025, 01:00 PM",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),

                      // Priority Level
                      const Text(
                        "Priority Level: Normal",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      // Incident Details
                      const Text(
                        "Incident Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("Date and Time of Incident:"),
                      const Text(
                        "February 10, 2025, 10:00 AM",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("Incident Type:"),
                      const Text(
                        "Others",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("Location of Incident:"),
                      const Text(
                        "PhilRice Negros",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("Problem Description:"),
                      const Text(
                        "PhilRice - Negros Internet is Down, Globe ISP",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("Impact/s:"),
                      const Text(
                        "No internet access",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("Affected Area/s:"),
                      const Text(
                        "PhilRice - Negros",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 15),

                      // Additional Details
                      const Text(
                        "Additional Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("Verified by:"),
                      const Text(
                        "Consolacion D. Diaz",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      // Documentation Section
                      const Text(
                        "Documentation",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 120,
                        width: MediaQuery.of(context).size.width *
                            0.85, // Set button width
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Edit Details Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.85, // Set button width
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle edit action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "EDIT DETAILS",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Findings and Recommendations
                      const Text(
                        "Findings and Recommendations",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.85, // Set button width
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "No actions taken yet.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Add Findings Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.85, // Set button width
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle add findings action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "ADD FINDINGS",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Edit Details Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.85, // Set button width
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle edit action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "SAVE REPORT AS PDF",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
}
