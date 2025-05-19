import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildDatePickerField.dart';
import 'package:servicetracker_app/components/buildDropdownField.dart';
import 'package:servicetracker_app/components/buildTimePickerField.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/components/customRadio.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/components/request/saveProgressModal.dart';
import 'package:servicetracker_app/components/request/submitIncidentModal.dart';

class NewIncidentReport extends StatefulWidget {
  const NewIncidentReport({Key? key}) : super(key: key);

  @override
  _NewIncidentReportState createState() => _NewIncidentReportState();
}

class _NewIncidentReportState extends State<NewIncidentReport> {
  String? selectedLocation;
  bool isRepair = false;
  String selectedStatus = "none"; // Default selected value
  DateTime? selectedDate;
  bool isAdditional = false; // Checkbox state
  TimeOfDay? selectedTime;
  final List<String> Locations = [
    "Computer & Peripheral Services",
    "Network Services",
    "Software Support",
    "Hardware Repair",
  ];
  TextEditingController notesController = TextEditingController();
  List<String> technicians = ['Ranniel F. Lauriaga'];
  final AutoSizeGroup radioTextGroup = AutoSizeGroup(); // ✅ Shared Group
  final List<String> priorityLevels = ["Low", "Normal", "High"];

  /// 🔹 **Show Modal for Adding Technician**
  void _showAddTechnicianModal(BuildContext context) {
    List<String> availableTechnicians = [
      "Ranniel F. Lauriaga",
      "Dennis Cargamento",
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

    showCustomSelectionModal(
      context: context,
      title: "Add Technicians",
      options: availableTechnicians,
      selectedOptions: technicians, // Use your existing list
      onConfirm: (List<String> selectedTechs) {
        setState(() {
          technicians = selectedTechs; // Update state with selected items
        });
      },
    );
  }

  void _showRemoveTechnicianDialog(BuildContext context, String techName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Technician"),
          content: Text("Are you sure you want to remove $techName?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("CANCEL"),
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

  Widget _buildDropdownField(String label, String? value, List<String> options,
      Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => _showModal(context, options, onSelect),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value ?? '',
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            Positioned(
              top: value != null ? -10 : 13,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Colors.white,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.black,
                    fontSize: value != null ? 18 : 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
        // const SizedBox(height: 15),
      ],
    );
  }

  void _showModal(
      BuildContext context, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(options[index]),
                onTap: () {
                  onSelect(options[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
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
                      'New Incident',
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
                          "Incident Details",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Inside your StatefulWidget
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildDropdownField(
                        context,
                        "Priority Level",
                        selectedStatus == "none" ? null : selectedStatus,
                        priorityLevels,
                        (value) {
                          setState(() => selectedStatus = value);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Incident Name',
                        notesController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Subject',
                        notesController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Description',
                        notesController,
                      ),
                    ),
// Inside your build method
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: buildDatePickerField(
                        context,
                        "Date of Incident",
                        selectedDate,
                        (date) {
                          setState(() => selectedDate = date);
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: buildTimePickerField(
                        context,
                        "Time of Incident",
                        selectedTime,
                        (time) {
                          setState(() => selectedTime = time);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Nature of Incident',
                        notesController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: buildDropdownField(context, "Location of Incident",
                          selectedLocation, Locations, (value) {
                        setState(() => selectedLocation = value);
                      }),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Impact/s',
                        notesController,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Affected Area/s',
                        notesController,
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Align(
                        alignment: Alignment
                            .centerLeft, // Aligns only the text to the left
                        child: Text(
                          "Signatories",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildDropdownField(context, "Incident Verifier",
                          selectedLocation, Locations, (value) {
                        setState(() => selectedLocation = value);
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: buildDropdownField(context, "Verifier Position",
                          selectedLocation, Locations, (value) {
                        setState(() => selectedLocation = value);
                      }),
                    ),
                    isAdditional
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: buildDropdownField(context, "Approver",
                                      selectedLocation, Locations, (value) {
                                    setState(() => selectedLocation = value);
                                  }),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: buildDropdownField(
                                      context,
                                      "Approver Position",
                                      selectedLocation,
                                      Locations, (value) {
                                    setState(() => selectedLocation = value);
                                  }),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
                      child: _buildButton(context, "SUBMIT INCIDENT REPORT",
                          Color(0xFF007A33), () {}),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  /// 🔹 **Reusable Button**
  Widget _addTechBuildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
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
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
            builder: (context) => CustomModalIncidentModal(
              title: "Incident report added successfully",
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
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
