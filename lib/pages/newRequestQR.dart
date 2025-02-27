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
      // Pause the camera after detecting a QR code
      controller.pauseCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height: MediaQuery.of(context).size.height * 0.1,
          showFooter: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context), // Go Back
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'New Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,

        /// 🔹 **Main Content**
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 📷 **QR Scanner Box**
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black38, width: 2),
                ),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
              const SizedBox(height: 10),

              /// 📄 **QR Scan Text**
              const Text(
                "Scan QR/Serial Number of Equipment",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// 📌 **Display Scanned Data**
              Text(
                scannedData ?? "No data scanned yet",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              /// 🔘 **Manual Entry Button**
              ElevatedButton(
                onPressed: () {
                  controller
                      ?.pauseCamera(); // ⏸️ Pause the camera before navigation
                  Navigator.pushNamed(context, '/NewRequestSave').then((_) {
                    controller
                        ?.resumeCamera(); // ▶️ Resume camera when coming back (if needed)
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A33),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
            ],
          ),
        ),
      ),
    );
  }
}
