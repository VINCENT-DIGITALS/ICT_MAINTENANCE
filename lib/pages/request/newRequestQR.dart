import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:servicetracker_app/components/appbar.dart';

class NewRequestQR extends StatefulWidget {
  const NewRequestQR({Key? key}) : super(key: key);

  @override
  _NewRequestQRState createState() => _NewRequestQRState();
}

class _NewRequestQRState extends State<NewRequestQR> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;
  bool isScannerActive = false; // 👈 Controls scanner state

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code;
      });

      // Pause the camera and navigate to the next page
      controller.pauseCamera();
      Navigator.pushNamed(context, '/NewRequestSave').then((_) {
        controller.resumeCamera();
      });
    });
  }

  void _startScanner() {
    setState(() {
      isScannerActive = true; // 👈 Enables scanner when tapped
    });
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
              alignment: Alignment.center,
              children: [
                // 🔹 Back Icon
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      controller?.pauseCamera();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                // 🔹 Title
                const Text(
                  'New Request',
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

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 📷 **QR Scanner Box**
              GestureDetector(
                onTap: _startScanner, // 🔹 Tap to enable scanner
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black38, width: 2),
                  ),
                  child: isScannerActive
                      ? QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                        )
                      : const Center(
                          child: Text(
                            "Tap to Scan QR Code",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // 📄 **QR Scan Text**
              Text(
                scannedData ?? "Scan QR/Serial Number of Equipment",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 🔘 **Manual Entry Button**
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: ElevatedButton(
                  onPressed: () {
                    controller?.pauseCamera();
                    Navigator.pushNamed(context, '/NewRequestManualQR').then((_) {
                      controller?.resumeCamera();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A33),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "ENTER DETAILS MANUALLY",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
