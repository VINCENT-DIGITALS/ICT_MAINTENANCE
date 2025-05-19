import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/services/FormProvider.dart';

class NewRequestQR extends StatefulWidget {
  const NewRequestQR({Key? key}) : super(key: key);

  @override
  _NewRequestQRState createState() => _NewRequestQRState();
}

class _NewRequestQRState extends State<NewRequestQR> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedEquipment;
  bool isScannerActive = false; // 👈 Controls scanner state

  @override
  void initState() {
    super.initState();
    scannedEquipment =
        Provider.of<FormProvider>(context, listen: false).scannedEquipment;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedEquipment = scanData.code;
      });

      // ✅ Save scanned data to FormProvider
      final formProvider = Provider.of<FormProvider>(context, listen: false);
      formProvider.updateForm(scannedEquipment: scannedEquipment);

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
            backgroundColor: const Color(0xFF14213D),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Stack(
                alignment: Alignment.center, // Keeps everything centered
                children: [
                  // 🔹 Back Icon (Left)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // 🔹 Title with Icon (Centered & Resizable)
                  Row(
                    mainAxisSize:
                        MainAxisSize.min, // Prevents unnecessary stretching
                    children: [
                      const SizedBox(width: 8), // Space between icon and text
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.5, // Responsive width
                        child: AutoSizeText(
                          'New Request',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30, // Max size
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 12, // Shrinks if needed
                          overflow: TextOverflow.ellipsis, // Prevents overflow
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Equipment Info Title - moved higher up
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 0, 16),
                    child: Text(
                      "Equipment Info",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  /// Wrap all form fields inside a SizedBox
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 📷 **QR Scanner Box**
                          GestureDetector(
                            onTap: _startScanner, // 🔹 Tap to enable scanner
                            child: Container(
                              height: 250,
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black38, width: 2),
                              ),
                              child: isScannerActive
                                  ? QRView(
                                      key: qrKey,
                                      onQRViewCreated: _onQRViewCreated,
                                    )
                                  : const Center(
                                      child: Text(
                                        "Tap to Scan QR Code",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 📄 **QR Scan Text**
                          Text(
                            scannedEquipment ??
                                "Scan QR/Serial Number of Equipment",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          // 🔘 **Manual Entry Button**
                          Padding(
                            padding: EdgeInsets.zero,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller?.pauseCamera();
                                  Navigator.pushNamed(
                                          context, '/NewRequestManualQR')
                                      .then((_) {
                                    controller?.resumeCamera();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007A33),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // ✅ Center content
                                  mainAxisSize:
                                      MainAxisSize.min, // ✅ Avoid extra space
                                  children: const [
                                    Flexible(
                                      child: AutoSizeText(
                                        "ENTER DETAILS MANUALLY",
                                        style: TextStyle(
                                          fontSize: 16, // Max font size
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign
                                            .center, // ✅ Keep text centered
                                        maxLines:
                                            1, // ✅ Ensures it stays in one line
                                        minFontSize:
                                            10, // ✅ Auto shrinks when needed
                                      ),
                                    ),
                                  ],
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
          )),
    );
  }
}
