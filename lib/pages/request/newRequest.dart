import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildDropdownField.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';

class NewRequest extends StatefulWidget {
  final String currentPage;

  const NewRequest({Key? key, this.currentPage = 'newRequest'})
      : super(key: key);

  @override
  _NewRequestState createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  final ScrollController _scrollController = ScrollController();

  // Controllers for each field
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController requesterController = TextEditingController();

  String? selectedServiceCategory;
  String? selectedDivision;

  final List<String> serviceCategories = [
    "Computer & Peripheral Services",
    "Network Services",
    "Software Support",
    "Hardware Repair",
  ];

  final List<String> divisions = [
    "Information Systems Divwwwwwwwwwwwwwwwwwwision",
    "HR Division",
    "Finance Division",
    "Operations Division",
  ];

  @override
  void dispose() {
    subjectController.dispose();
    descriptionController.dispose();
    requesterController.dispose();
    super.dispose();
  }

  void _showModal(
      BuildContext context, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      barrierDismissible: true, // Dismiss when tapped outside
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Keep it compact
              children: [
                const Text(
                  "Select an Option",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                /// **Options List**
                Column(
                  children: options.map((String option) {
                    return InkWell(
                      onTap: () {
                        onSelect(option);
                        Navigator.pop(dialogContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          option,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                /// **Cancel Button**
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel",
                      style: TextStyle(fontSize: 16, color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007A33),
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text.replaceAll(" ", "\n"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
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
                        child: Align(
                          alignment: Alignment
                              .centerLeft, // Aligns only the text to the left
                          child: const Text(
                            'Request Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      buildDropdownField(context, "Service Category",
                          selectedServiceCategory, serviceCategories, (value) {
                        setState(() => selectedServiceCategory = value);
                      }),
                      buildTextField("Subject", subjectController),
                      buildTextField("Description", descriptionController),
                      buildTextField("Requester", requesterController),
                      buildDropdownField(
                          context, "Division", selectedDivision, divisions,
                          (value) {
                        setState(() => selectedDivision = value);
                      }),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.pushNamed(
                                    context,
                                    '/NewRequestQR',
                                    arguments: {
                                      'serviceCategory':
                                          selectedServiceCategory,
                                      'subject': subjectController.text,
                                      'description': descriptionController.text,
                                      'requester': requesterController.text,
                                      'division': selectedDivision,
                                    },
                                  );
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007A33),
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "NEXT",
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
                      const SizedBox(height: 20),
                    ],
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
