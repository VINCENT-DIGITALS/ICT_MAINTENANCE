import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:servicetracker_app/components/appbar.dart';

class NewRequestManualQR extends StatefulWidget {
  const NewRequestManualQR({Key? key}) : super(key: key);

  @override
  _NewRequestManualQRState createState() => _NewRequestManualQRState();
}

class _NewRequestManualQRState extends State<NewRequestManualQR> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void initState() {
    super.initState();
    controller?.pauseCamera();
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
        scannedData = scanData.code;
      });
      controller.pauseCamera();
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

                // 🔹 Title (Centered)
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

        /// **Main Content**
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 📷 **QR Scanner Placeholder**
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner, size: 80, color: Colors.black38),
                ),
                const SizedBox(height: 20),

                /// 📄 **Equipment Info Title**
                const Text(
                  "Equipment Info",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                /// **Serial Number Field**
                _buildTextField("Serial Number", "XXXXXXXXXXXXXXXXXX"),

                /// **Accountable Field**
                _buildTextField("Accountable", "Luis Alejandre Tamani"),

                /// **Division Field**
                _buildDropdownField("Division", "Information Systems Division"),

                const SizedBox(height: 15),

                /// **Description Box**
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy eirmod tempor.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 20),

                /// **Next Button**
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller?.pauseCamera();
                      Navigator.pushNamed(context, '/NewRequestSave').then((_) {
                        controller?.resumeCamera();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007A33),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "NEXT",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Reusable Text Field Widget**
  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            hintText: value,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// **Reusable Dropdown Field**
  Widget _buildDropdownField(String label, String selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: ["Information Systems Division", "Other Division"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {},
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
