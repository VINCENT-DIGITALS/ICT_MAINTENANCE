import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
  void initState() {
    super.initState();
    _checkCameraPermission(); // 🔥 Check permissions on start
  }

  /// 🔥 **Check and Request Camera Permission**
  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;

    if (!status.isGranted) {
      var result = await Permission.camera.request();
      if (!result.isGranted) {
        _showPermissionDialog();
      }
    }
  }

  /// ❌ **Show Dialog if Camera is Denied**
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text("Please allow camera access to scan QR codes."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Open device settings
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height:
              MediaQuery.of(context).size.height * 0.13, // 50% of screen height
          showFooter: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mabuhay, Ranniel!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  }, // Logout or Profile
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
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
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width * 0.85, // Set width
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      children: [
                        /// 🔹 Title: Picked Repairs
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 25, 0, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Picked Requests",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.35, // Consistent button width
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: hasOngoingRepairs
                                      ? TextButton(
                                          onPressed: () {},
                                          child: const Text(
                                            "See all services",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 🔹 List of Picked Requests (Or Empty State)
                        hasOngoingRepairs
                            ? _buildPickedRequests(context)
                            : Column(
                                children: [_buildEmptyPickedState(context)]),

                        /// 🔹 Title: Ongoing Services
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 25, 0, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Ongoing Services",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.35, // Consistent button width
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: hasOngoingRepairs
                                      ? TextButton(
                                          onPressed: () {},
                                          child: const Text(
                                            "See all services",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 🔹 List of Ongoing Repairs (Or Empty State)
                        hasOngoingRepairs
                            ? _buildOngoingRepairs(context)
                            : Column(
                                children: [_buildEmptyOngoingState(context)]),

                        const SizedBox(
                            height:
                                80), // Extra space to prevent content from being hidden
                      ],
                    ),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 10), // Simplified padding
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 2222222),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.85, // 90% of screen width
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/newRequest');
                    },
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
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      decoration: BoxDecoration(
        color: Color(0xFFFCA311), // Orange background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40), // Curved top-left
          topRight: Radius.circular(40), // Curved top-right
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton("INCIDENT REPORTS", () {
            Navigator.pushNamed(context, '/IncidentReports'); 
          }, context),
          const SizedBox(width: 10), // Space between buttons
          _buildActionButton("PENDING REQUESTS", () {
             Navigator.pushNamed(context, '/PendingRequests'); 
          }, context),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, VoidCallback onPressed, BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85, // Set button width
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14213D), // Dark blue
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
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
              const SizedBox(width: 15), // Space between text and icon
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 36,
              ),
            ],
          ),
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
          width:
              MediaQuery.of(context).size.width * 0.85, // 90% of screen width

          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TN25-0143 Computer Repair",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 5),
              const Text(
                "Mighty Jemuel Sotto",
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                "Information Systems Division",
                style: TextStyle(
                  height: 1.0, // Reduces spacing
                ),
              ),
              const Text(
                "Requested: February 14, 2025, 10:00 AM",
                style: TextStyle(
                  height: 1.0, // Reduces spacing
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Subject of request",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  height: 1.0, // Reduces spacing
                ),
              ),
              const SizedBox(height: 2), // Reduce spacing here
              Text(
                "asasd cscsdcvsdvv dvv asasd cscsdcvsdvv dvvsdsdsdsdsdsdsdsdsc dvddv ",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.2, // Adjust line height for tighter spacing
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: 3,
              ),

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
                    color: Colors.black,
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
          width:
              MediaQuery.of(context).size.width * 0.85, // 90% of screen width
          // margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TN25-0143 Computer Repair",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 5),
              const Text(
                "Mighty Jemuel Sotto",
                style: const TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF707070),
                  height: 1.2, // Adjust line height for tighter spacing
                ),
              ),
              const Text(
                "Information Systems Division",
                style: const TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF707070),

                  height: 1.2, // Adjust line height for tighter spacing
                ),
              ),
              const Text(
                "Requested: February 14, 2025, 10:00 AM",
                style: const TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF707070),
                  height: 1.2, // Adjust line height for tighter spacing
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Current Location: ISD Server Room",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.2, // Adjust line height for tighter spacing
                ),
              ),

              const Text(
                "Status: Serviceable - for repair",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.2, // Adjust line height for tighter spacing
                ),
              ),

              const Text(
                "Last Updated: February 19, 2025 | 3:00PM",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.2, // Adjust line height for tighter spacing
                ),
              ),
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
                    color: Colors.black,
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
