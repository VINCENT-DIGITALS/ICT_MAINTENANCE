import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildDropdownField.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/services/FormProvider.dart';

class NewRequest extends StatefulWidget {
  final String currentPage;

  const NewRequest({Key? key, this.currentPage = 'newRequest'})
      : super(key: key);

  @override
  _NewRequestState createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  final ScrollController _scrollController = ScrollController();
  int _currentStep = 0;
  // Controllers for each field
  late TextEditingController subjectController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController requesterController = TextEditingController();

  String? selectedServiceCategory;
  String? selectedDivision;

  @override
  void initState() {
    super.initState();
    final subjectFromProvider =
        Provider.of<FormProvider>(context, listen: false).subject;
    subjectController = TextEditingController(text: subjectFromProvider ?? '');

    final descriptionFromProvider =
        Provider.of<FormProvider>(context, listen: false).description;
    descriptionController =
        TextEditingController(text: descriptionFromProvider ?? '');

    final requesterFromProvider =
        Provider.of<FormProvider>(context, listen: false).requester;
    requesterController =
        TextEditingController(text: requesterFromProvider ?? '');
        
    selectedServiceCategory =
        Provider.of<FormProvider>(context, listen: false).serviceCategory;
    selectedDivision =
        Provider.of<FormProvider>(context, listen: false).division;
  }

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
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Form(
              key: formProvider.requestFormKeyStep1, // Assign GlobalKey here

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

                          /// **Dropdown for Service Category**

                          buildDropdownField(
                            context,
                            "Service Category",
                            selectedServiceCategory,
                            serviceCategories,
                            (value) {
                              setState(() => selectedServiceCategory = value);
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? "Service is required"
                                : null,
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            "Subject",
                            subjectController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Subject is required"
                                : null,
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            "Description",
                            descriptionController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Desription is required"
                                : null,
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            "Requester",
                            requesterController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Requester is required"
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
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formProvider
                                        .requestFormKeyStep1.currentState!
                                        .validate()) {
                                      // ✅ Proceed to next page
                                      Navigator.pushNamed(
                                          context, '/NewRequestQR');
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 15, 15, 15),
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
            )),
      ),
    );
  }
}
