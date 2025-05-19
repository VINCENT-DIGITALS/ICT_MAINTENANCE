import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:servicetracker_app/auth/sessionmanager.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildDropdownField.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/components/request/ButtonRequestModal.dart';
import 'package:servicetracker_app/components/request/PickRequestModal.dart';
import 'package:servicetracker_app/services/FormProvider.dart';
import 'package:servicetracker_app/api_service/home_service.dart';

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
    "Plant Breeding and Biotechnology",
    "Agronomy, Soils and Plant Physiology",
    "Crop Protection",
    "Genetic Resources",
    "Rice Engineering and Mechanization",
    "Rice Chemistry and Food Science",
    "Socioeconomics",
    "Development Communication",
    "Technology Management and Services",
    "Administrative",
    "Finance",
    "Information Systems"
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

  Future<void> _submitServiceRequest(BuildContext context) async {
    final formProvider = Provider.of<FormProvider>(context, listen: false);
    final session = await SessionManager().getUser();
    final String? philriceId = session?['philrice_id'];

    // You may need to adjust these keys to match your backend
    final Map<String, dynamic> requestData = {
      'category': formProvider.selectedCategoryId ?? '', // int or string
      'subcategory': formProvider.selectedSubcategoryId ?? '', // int or string
      'subject': formProvider.subject ?? '',
      'description': formProvider.description ?? '',
      'location': formProvider.location ?? '',
      'requested_date': formProvider.requestedCompletionDate?.toIso8601String(),
      'telephone': formProvider.telephoneNo ?? '',
      'cellphone': formProvider.cellphoneNo ?? '',
      'client': formProvider.actualClient ?? '',
      'philrice_id': philriceId ?? '',
      'serial_number': serialNumberController.text, // Add serial number
      'accountable': accountableController.text, // Add accountable person
    };

    // Print request data for debugging
    print('Submitting service request with data:');
    print(requestData);

    try {
      final response = await DashboardService().storeNewRequest(requestData);
      if (response['status'] == true) {
        // Success modal
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => PopScope(
            canPop: false, // Prevent default back button behavior
            onPopInvoked: (didPop) {
              if (!didPop) {
                // Perform the same actions as the close button when back button is pressed
                serialNumberController.clear();
                accountableController.clear();
                setState(() => selectedDivision = null);
                formProvider.resetForm();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => route.settings.name == '/',
                );
                Navigator.pushNamed(context, '/PendingRequests');
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: CustomModalButtonRequest(
                        title: "Request Submitted",
                        message: "Your request has been submitted successfully.",
                        onConfirm: () async {
                          Navigator.pop(context);
                          serialNumberController.clear();
                          accountableController.clear();
                          setState(() => selectedDivision = null);
                          formProvider.resetForm();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => route.settings.name == '/',
                          );
                          Navigator.pushNamed(context, '/PendingRequests');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      serialNumberController.clear();
                      accountableController.clear();
                      setState(() => selectedDivision = null);
                      formProvider.resetForm();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => route.settings.name == '/',
                      );
                      Navigator.pushNamed(context, '/PendingRequests');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Error modal with PopScope instead of WillPopScope
        showDialog(
          context: context,
          builder: (context) => PopScope(
            canPop: false, // Prevent default back button behavior
            onPopInvoked: (didPop) {
              if (!didPop) {
                Navigator.pop(context); // Handle back button manually
              }
            },
            child: AlertDialog(
              title: const Text("Error"),
              content: Text(response['data']?['message'] ?? "Failed to submit request."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => PopScope(
          canPop: false, // Prevent default back button behavior
          onPopInvoked: (didPop) {
            if (!didPop) {
              Navigator.pop(context); // Handle back button manually
            }
          },
          child: AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to submit request: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);
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
                              Provider.of<FormProvider>(context, listen: false)
                                  .accountableDivision = value;
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? "Division is required"
                                : null,
                          ),

                          const SizedBox(height: 15),

                          /// **Description Box**
                          Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Acquired Section
                                const Text(
                                  "Date Acquired: January 5, 2019",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Item Description Section
                                const Text(
                                  "Item Description:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
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
                                onPressed: () async {
                                  // Validate form before proceeding
                                  if (!formProvider.requestFormKeyStep2.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please fill all required fields"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  await _submitServiceRequest(context);
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
                                  "SUBMIT",
                                  style: TextStyle(
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
