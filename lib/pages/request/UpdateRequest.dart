import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/customRadio.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/components/request/UpdateProgressModal.dart';
import 'package:servicetracker_app/components/request/saveProgressModal.dart';

class UpdateRequest extends StatefulWidget {
  const UpdateRequest({Key? key}) : super(key: key);

  @override
  _UpdateRequestState createState() => _UpdateRequestState();
}

class _UpdateRequestState extends State<UpdateRequest> {
  String? selectedLocation;
  String selectedStatus = "repair"; // Default selected value

  bool isCompleted = false; // Checkbox state

  final List<String> Locations = [
    "Computer & Peripheral Services",
    "Network Services",
    "Software Support",
    "Hardware Repair",
  ];
  TextEditingController notesController = TextEditingController();
  List<String> technicians = ['Ranniel F. Lauriaga'];

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
              const Text(
                'Update Status',
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
                          "Technician Remarks",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              "Service Category",
                              selectedLocation,
                              Locations,
                              (value) {
                                setState(() => selectedLocation = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed:
                                () {}, // Add QR scanning functionality here
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF007A33), // Updated color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                            child: const Text(
                              "SCAN QR",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: notesController,
                      minLines: 1, // Start with one line
                      maxLines: null, // Allow expansion as user types
                      keyboardType:
                          TextInputType.multiline, // Enable multiline input
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        labelStyle: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF018203), width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                      child: Align(
                        alignment: Alignment
                            .centerLeft, // Aligns only the text to the left
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                              label: "Serviceable - For Repair",
                              value: "repair",
                              groupValue: selectedStatus,
                              onChanged: (value) =>
                                  setState(() => selectedStatus = value),
                            ),
                            CustomRadioButton(
                              label: "Unserviceable - For Disposal",
                              value: "disposal",
                              groupValue: selectedStatus,
                              onChanged: (value) =>
                                  setState(() => selectedStatus = value),
                            ),
                            CustomRadioButton(
                              label: "Serviceable - For Item Procurement",
                              value: "procurement",
                              groupValue: selectedStatus,
                              onChanged: (value) =>
                                  setState(() => selectedStatus = value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   width: MediaQuery.of(context).size.width * 0.7,
                    //   // height: 200, // Define an appropriate height
                    //   child: Column(
                    //     mainAxisSize: MainAxisSize.min,
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       CustomRadioButton(
                    //         label: "Serviceable - For Repair",
                    //         value: "repair",
                    //         groupValue: selectedStatus,
                    //         onChanged: (value) =>
                    //             setState(() => selectedStatus = value),
                    //       ),
                    //       CustomRadioButton(
                    //         label: "Unserviceable - For Disposal",
                    //         value: "disposal",
                    //         groupValue: selectedStatus,
                    //         onChanged: (value) =>
                    //             setState(() => selectedStatus = value),
                    //       ),
                    //       CustomRadioButton(
                    //         label: "Serviceable - For Item Procurement",
                    //         value: "procurement",
                    //         groupValue: selectedStatus,
                    //         onChanged: (value) =>
                    //             setState(() => selectedStatus = value),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(11, 0, 0, 0),
                        child: Align(
                          alignment: Alignment
                              .centerLeft, // Aligns only the text to the left
                          child: Row(
                            children: [
                              Checkbox(
                                value: isCompleted,
                                activeColor: Color(0xFF007A33),
                                onChanged: (bool? value) {
                                  setState(() {
                                    isCompleted = value!;
                                  });
                                },
                              ),
                              Text("Mark as completed",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        )),

                    const SizedBox(height: 20),

                    /// 📷 **Photo Documentation**
                    /// 📸 **Centered Documentation**
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          const Text("Add photo documentation."),
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
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5),

                    SizedBox(
                      child: ListView.builder(
                        itemCount: technicians.length,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                        itemBuilder: (context, index) {
                          String tech = technicians[index];
                          return GestureDetector(
                            onTap: () =>
                                _showRemoveTechnicianDialog(context, tech),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(tech, textAlign: TextAlign.center),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🔘 **Add Technician Button**
                    _addTechBuildButton(
                        context,
                        "ADD TECHNICIAN",
                        Color(0xFF45CF7F),
                        () => _showAddTechnicianModal(context)),

                    const SizedBox(height: 25),

                    /// 🔘 **Save Request Button**
                    _buildButton(
                        context, "UPDATE STATUS", Color(0xFF007A33), () {}),

                    const SizedBox(height: 10),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(
                    //       0, 20, 0, 15), // Adds padding
                    //   child: GestureDetector(
                    //       onTap: () {
                    //         // Handle click action here
                    //       },
                    //       child: Align(
                    //         alignment: Alignment.centerLeft,
                    //         child: const Text(
                    //           "If repair request",
                    //           style: TextStyle(
                    //             fontSize: 12,
                    //             fontStyle: FontStyle.italic,
                    //             color:
                    //                 Color(0xFF707070), // Corrected color format
                    //           ),
                    //         ),
                    //       )),
                    // )
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
            builder: (context) => CustomModalUpdateProgress(
              title: "Request Status Updated Successfully ",
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
