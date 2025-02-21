import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/qrScanner.dart';

class HomePage extends StatefulWidget {
  final String currentPage;

  const HomePage({Key? key, this.currentPage = 'home'}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool hasOngoingRepairs = true; // Change to false to test empty state

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height:
              MediaQuery.of(context).size.height * 0.1, // 50% of screen height
          showFooter: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 10),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.arrow_back, color: Colors.white),
              // ),
              const Text(
                'Mabuhay, Ranniel!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {}, // Logout or Profile
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,

        /// 🔥 Main Layout with Fixed Bottom Buttons
        body: Column(
          children: [
            /// 🔹 Scrollable Ongoing Repairs
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 15),
                    children: [
                      /// 🔹 Title: Ongoing Repairs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Picked Requests",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "See all services",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),

                      /// 🔹 List of Ongoing Repairs (Or Empty State)
                      hasOngoingRepairs
                          ? _buildPickedRequests(context)
                          : Column(
                              children: [
                                _buildEmptyPickedState(context),
                              ],
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Ongoing Services",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "See all services",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),

                      /// 🔹 List of Ongoing Repairs (Or Empty State)
                      hasOngoingRepairs
                          ? _buildOngoingRepairs(context)
                          : Column(
                              children: [
                                _buildEmptyOngoingState(context),
                              ],
                            ),
                      const SizedBox(
                          height: 80), // Extra space to prevent hiding content
                    ],
                  ),

                  /// 🔥 Overlay Fade Effect (Shows Scrollable Area)
                  Positioned(
                    bottom:
                        0, // Adjust height to position just above the buttons
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // hasOngoingRepairs
            //     ? Column(
            //         children: [
            //           _buildAddRequestButtons(),
            //           _buildPendingButtons(),
            //         ],
            //       )
            //     :
            Column(
              children: [
                _buildAddRequestButtons(),
                _buildPendingButtons(context),
              ],
            )

            /// 🔹 Fixed Bottom Buttons
          ],
        ),
      ),
    );
  }

  /// 🔹 Open QR Scanner
  void _scanQRCode() async {
    final String? scannedValue = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (scannedValue != null) {
      // Handle scanned value (e.g., show a dialog or navigate)
      _showScannedDialog(scannedValue);
    }
  }

  /// 🔹 Show Scanned Value in a Dialog
  void _showScannedDialog(String scannedValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Scanned Code"),
        content: Text("Scanned Value: $scannedValue"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// 🛠 Bottom Section with Buttons
  Widget _buildAddRequestButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 10), // Simplified padding
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  child: ElevatedButton(
                    onPressed: _scanQRCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007A33),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "ADD NEW REQUEST",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ))

          /// 🔥 Add New Request Button (Always Visible)
        ],
      ),
    );
  }

  Widget _buildPendingButtons(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18, // 12% of screen height
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFA500), // Orange background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40), // Curved top-left
          topRight: Radius.circular(40), // Curved top-right
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton("INCIDENT REPORTS", () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => IncidentReportsPage()),
            // );
          }),
          const SizedBox(width: 10), // Space between buttons
          _buildActionButton("PENDING REQUESTS", () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => PendingRequestsPage()),
            // );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A213B), // Dark blue
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8), // Slightly rounded button corners
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Ensures content is centered properly
          children: [
            Text(
              text.replaceAll(" ", "\n"), // Splits words into two lines
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center, // Centers the text
            ),
            const SizedBox(height: 5), // Space between text and icon
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 🛠 Builds a list of Ongoing Repairs (Replace with your real data)
  Widget _buildPickedRequests(BuildContext context) {
    return Column(
      children: List.generate(
        1,
        (index) => Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TN25-0143 Computer Repair",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Mighty Jemuel Sotto",
                style: TextStyle(fontSize: 14),
              ),
              const Text("Information Systems Division"),
              const Text("Requested: February 14, 2025, 10:00 AM"),
              const SizedBox(height: 5),
              const Text("Current Location: ISD Server Room"),
              const SizedBox(height: 5),
              const Text("Status: Serviceable - for repair"),
              const SizedBox(height: 20),
              // GREEN BUTTON
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize:
                      const Size(double.infinity, 50), // Full width button
                ),
                child: const Text(
                  "COMPLETE DETAILS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // TEXT BUTTON (Remove from my list)
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Remove from my list",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🛠 Builds a list of Ongoing Repairs (Replace with your real data)
  Widget _buildOngoingRepairs(BuildContext context) {
    return Column(
      children: List.generate(
        1,
        (index) => Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TN25-0143 Computer Repair",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Mighty Jemuel Sotto",
                style: TextStyle(fontSize: 14),
              ),
              const Text("Information Systems Division"),
              const Text("Requested: February 14, 2025, 10:00 AM"),
              const SizedBox(height: 5),
              const Text("Current Location: ISD Server Room"),
              const SizedBox(height: 5),
              const Text("Status: Serviceable - for repair"),
              const SizedBox(height: 20),
              // GREEN BUTTON
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize:
                      const Size(double.infinity, 50), // Full width button
                ),
                child: const Text(
                  "COMPLETE DETAILS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// 🛠 Shows Empty State when there are no Ongoing Repairs
  Widget _buildEmptyPickedState(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width

      padding: const EdgeInsets.all(16), // Adds spacing inside the container
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light gray background
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers content vertically
        children: const [
          SizedBox(height: 5),
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
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width

      padding: const EdgeInsets.all(16), // Adds spacing inside the container
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
          SizedBox(height: 5),
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
