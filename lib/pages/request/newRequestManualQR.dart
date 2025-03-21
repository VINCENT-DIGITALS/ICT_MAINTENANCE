import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildDropdownField.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/services/FormProvider.dart';

class NewRequestManualQR extends StatefulWidget {
  const NewRequestManualQR({Key? key}) : super(key: key);

  @override
  _NewRequestManualQRState createState() => _NewRequestManualQRState();
}

class _NewRequestManualQRState extends State<NewRequestManualQR> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedEquipment;
  late TextEditingController serialNumberController = TextEditingController();
  late TextEditingController accountableController = TextEditingController();

  String? selectedDivision;

  final List<String> divisions = [
    "Information Systems Divwwwwwwwwwwwwwwwwwwision",
    "HR Division",
    "Finance Division",
    "Operations Division",
  ];

  @override
  void initState() {
    super.initState();
    controller?.pauseCamera();
    scannedEquipment =
        Provider.of<FormProvider>(context, listen: false).scannedEquipment;
    serialNumberController.text = scannedEquipment ?? "";
    accountableController.text =
        Provider.of<FormProvider>(context, listen: false).accountableperson ??
            "";
    selectedDivision =
        Provider.of<FormProvider>(context, listen: false).accountableDivision;
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
      controller.pauseCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);
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

        /// **Main Content**
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Form(
              key: formProvider.requestFormKeyStep2, // Assign GlobalKey here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Wrap all form fields inside a SizedBox
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.85, // Set width for all children
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 25, 0, 15),
                            child: Container(
                              height: MediaQuery.of(context).size.width *
                                  0.45, // Set width for all children,
                              width: MediaQuery.of(context).size.width *
                                  0.45, // Set width for all children
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.qr_code_scanner,
                                  size: 80, color: Colors.black38),
                            ),
                          ),

                          /// 📷 **QR Scanner Placeholder**

                          const SizedBox(height: 20),

                          /// 📄 **Equipment Info Title**
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Equipment Info",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                          const SizedBox(height: 10),

                          buildTextField(
                            "Serial Number",
                            serialNumberController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Serial number is required"
                                : null,
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            "Accountable",
                            accountableController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Accountable is required"
                                : null,
                          ),
                          const SizedBox(height: 15),
                          buildDropdownField(
                            context,
                            "Division",
                            selectedDivision,
                            divisions,
                            (value) {
                              setState(() => selectedDivision = value);
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? "Division is required"
                                : null,
                          ),

                          const SizedBox(height: 15),

                          /// **Description Box**
                          Container(
                            width: MediaQuery.of(context).size.width *
                                0.85, // Set width for all children
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy eirmod tempor.",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// **Next Button**
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.85, // Set width for all children
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formProvider
                                      .requestFormKeyStep2.currentState!
                                      .validate()) {
                                    // ✅ Proceed to next page
                                    controller?.pauseCamera();
                                    Navigator.pushNamed(
                                            context, '/NewRequestSave')
                                        .then((_) {
                                      controller?.resumeCamera();
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please fill all required fields"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007A33),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "NEXT",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
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
            )),
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
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: ["Information Systems Division", "Other Division"]
              .map((String value) {
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
