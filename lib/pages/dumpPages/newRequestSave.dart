import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildDropdownField.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/components/cameraScreen.dart';
import 'package:servicetracker_app/components/customRadio.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/components/request/saveProgressModal.dart';
import 'package:servicetracker_app/services/FormProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewRequestSave extends StatefulWidget {
  const NewRequestSave({Key? key}) : super(key: key);

  @override
  _NewRequestSaveState createState() => _NewRequestSaveState();
}

class _NewRequestSaveState extends State<NewRequestSave> {
  String? selectedLocation;
  bool isRepair = false;
  String selectedStatus = "none"; // Default selected value
  String? scannedLocation;
  bool isCompleted = false; // Checkbox state
  final AutoSizeGroup radioTextGroup = AutoSizeGroup(); // ✅ Shared Group
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final String mainTechnician = "Dennis Cargamento";

  final List<String> Locations = [
    "Computer & Peripheral Services",
    "Network Services",
    "Software Support",
    "Hardware Repair",
  ];
  late TextEditingController notesController = TextEditingController();
  List<String> technicians = [
    'Ranniel F. Lauriaga',
    "Christian 2",
    "Christian 3",
    "Christian 4",
  ];

  File? _capturedImage;

  void _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(initialImage: _capturedImage),
      ),
    );

    if (result != null && result is File) {
      setState(() {
        _capturedImage = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    scannedLocation =
        Provider.of<FormProvider>(context, listen: false).location;
    notesController.text =
        Provider.of<FormProvider>(context, listen: false).technicianNotes ?? '';

    technicians =
        Provider.of<FormProvider>(context, listen: false).assignedTechnicians;
  }

  /// 🔹 **Show Modal for Adding Technician**
  void _showAddTechnicianModal(BuildContext context) {
    List<String> availableTechnicians = [
      "Ranniel F. Lauriaga",
      "Dennis Cargamento",
      "Dennis Cargamensto",
      "Christian Sicat",
      "Christian 2",
      "Christian 3",
      "Christian 4",
      "Christian 5",
      "Christian 6",
      "Christian 7",
      "Christian 8",
      "Christian 9",
    ];
// ✅ Remove if exists to avoid duplicates, then insert at top
    availableTechnicians.remove(mainTechnician);
    availableTechnicians.insert(0, mainTechnician);

    showCustomSelectionModal(
      context: context,
      title: "Add Technicians",
      options: availableTechnicians,
      selectedOptions: technicians, // Use existing list
      onConfirm: (List<String> selectedTechs) {
        setState(() {
          // Ensure fixed technician is always included
          if (!selectedTechs.contains(mainTechnician)) {
            selectedTechs.add(mainTechnician);
          }
          technicians = selectedTechs;
        });
      },
      fixedTechnician: mainTechnician,
    );
  }

  void _showRemoveTechnicianDialog(BuildContext context, String techName) {
    // Prevent removal of the fixed technician
    if (techName == mainTechnician) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Action Not Allowed",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: Text("You cannot removed yourself for now.",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.normal)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Normal removal dialog for others
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Technician",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          content: Text("Are you sure you want to remove $techName?",
              style: TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child:
                  const Text("CANCEL", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  technicians.remove(techName); // Remove technician
                });
                Navigator.pop(context); // Close dialog
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("REMOVE"),
            ),
          ],
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    qrController.scannedDataStream.listen((scanData) {
      setState(() {
        scannedLocation = scanData.code ?? '';
      });
      Navigator.of(context).pop(); // ✅ Close the modal once scanned
      controller?.dispose(); // ✅ Stop scanner after scan
    });
  }

  void _showQRScannerModal() {
    showDialog(
      context: context,
      barrierDismissible: true, // ✅ Tap outside to close
      barrierColor: Colors.black.withOpacity(0.5), // ✅ Dim background
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.width * 0.85,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller?.dispose(); // ✅ Stop scanner if manually closed
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close",
                      style: TextStyle(color: Colors.red, fontSize: 18)),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
          child: Stack(
            alignment: Alignment.center, // Centers the text
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
      body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Form(
            key: formProvider.requestFormKeyStep3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.85, // Set width for all children
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 25, 0, 10),
                          child: Align(
                            alignment: Alignment
                                .centerLeft, // Aligns only the text to the left
                            child: Text(
                              "Technician Remarks",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildTextField(
                          "Notes",
                          notesController,
                          validator: (value) => value == null || value.isEmpty
                              ? "Notes is required"
                              : null,
                        ),
                        const SizedBox(height: 20),
                        isRepair
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                                child: Align(
                                  alignment: Alignment
                                      .centerLeft, // Aligns only the text to the left
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomRadioButton(
                                        label: "Serviceable - For Repair",
                                        value: "repair",
                                        groupValue: selectedStatus,
                                        onChanged: (value) => setState(
                                            () => selectedStatus = value),
                                        textGroup:
                                            radioTextGroup, // ✅ Pass AutoSizeGroup
                                      ),
                                      CustomRadioButton(
                                        label: "Unserviceable - For Disposal",
                                        value: "disposal",
                                        groupValue: selectedStatus,
                                        onChanged: (value) => setState(
                                            () => selectedStatus = value),
                                        textGroup:
                                            radioTextGroup, // ✅ Pass AutoSizeGroup
                                      ),
                                      CustomRadioButton(
                                        label:
                                            "Serviceable - For Item Procurement",
                                        value: "procurement",
                                        groupValue: selectedStatus,
                                        onChanged: (value) => setState(
                                            () => selectedStatus = value),
                                        textGroup:
                                            radioTextGroup, // ✅ Pass AutoSizeGroup
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                        const SizedBox(height: 10),

                        /// 📷 **Photo Documentation**
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _openCamera, // Open camera on tap
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    image: _capturedImage != null
                                        ? DecorationImage(
                                            image: FileImage(_capturedImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _capturedImage == null
                                      ? const Icon(Icons.camera_alt,
                                          size: 40, color: Colors.grey)
                                      : null, // Show icon if no image
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Add photo documentation.",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// 👷 **Assigned Technician/s**
                        ///
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Assigned Technician/s",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 5),

                        SizedBox(
                          child: ListView.builder(
                            // ✅ Create a display list with mainTechnician always on top
                            itemCount: ([
                              mainTechnician,
                              ...technicians.where((tech) =>
                                  tech != mainTechnician), // Remove duplicates
                            ]).length,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                            itemBuilder: (context, index) {
                              // ✅ Get the combined list
                              List<String> displayTechnicians = [
                                mainTechnician,
                                ...technicians.where((tech) =>
                                    tech != mainTechnician), // Avoid duplicates
                              ];

                              String tech = displayTechnicians[index];

                              return GestureDetector(
                                onTap: () =>
                                    _showRemoveTechnicianDialog(context, tech),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  padding: const EdgeInsets.all(15),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tech,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// 🔘 **Add Technician Button**
                        _addTechBuildButton(
                          context: context,
                          text: "ADD TECHNICIAN",
                          color: Color(0xFF45CF7F),
                          TxtColor: Color(0xFF007A33), // Optional
                          onPressed: () => _showAddTechnicianModal(context),
                        ),

                        const SizedBox(height: 25),

                        /// 🔘 **Save Request Button**
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.85, // Set width for all children
                            child: ElevatedButton(
                              onPressed: () {
                                if (formProvider
                                    .requestFormKeyStep3.currentState!
                                    .validate()) {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        CustomModalSaveProgress(
                                      title: "Request Added to Your Services",
                                      message: "25-0143 Computer Repair",
                                      onConfirm: () {
                                        formProvider.resetForm(); // ✅ Clear the form
                                        Navigator.pop(
                                            context); // Close modal first
                                        // onPressed(); // Then navigate
                                      },
                                    ),
                                  ).then((_) {
                                    formProvider.resetForm(); // ✅ Clear the form
                                    // If dialog is dismissed by tapping outside, navigate anyway
                                    Navigator.pushReplacementNamed(
                                        context, '/ServiceDetails');
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
                                "SAVE REQUEST",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        isRepair
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0, 20, 0, 15), // Adds padding
                                child: GestureDetector(
                                    onTap: () {
                                      // Handle click action here
                                      setState(() {
                                        isRepair = false;
                                        selectedStatus =
                                            "none"; // Default selected value

                                        isCompleted = false; // Checkbox state
                                      });
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        "If not repair request",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Color(
                                              0xFF707070), // Corrected color format
                                        ),
                                      ),
                                    )),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0, 20, 0, 15), // Adds padding
                                child: GestureDetector(
                                    onTap: () {
                                      // Handle click action here
                                      setState(() {
                                        isRepair = true;
                                      });
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        "If repair request",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Color(
                                              0xFF707070), // Corrected color format
                                        ),
                                      ),
                                    )),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    ));
  }


  /// 🔹 **Reusable Button**
  Widget _addTechBuildButton({
    required BuildContext context,
    required String text,
    required Color color,
    Color TxtColor = Colors.white, // Optional with a default value
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: TxtColor),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CustomModalSaveProgress(
              title: "Request Added to Your Services",
              message: "25-0143 Computer Repair",
              onConfirm: () {
                Navigator.pop(context); // Close modal first
                onPressed(); // Then navigate
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
