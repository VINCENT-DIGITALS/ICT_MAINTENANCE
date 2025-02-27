import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';

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
    "Information Systems Division",
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF018203), width: 2),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
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
                height: 55,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            Positioned(
              top: value != null ? -10 : 16,
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
        const SizedBox(height: 15),
      ],
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
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
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
                      _buildDropdownField("Service Category",
                          selectedServiceCategory, serviceCategories, (value) {
                        setState(() => selectedServiceCategory = value);
                      }),
                      _buildTextField("Subject", subjectController),
                      _buildTextField("Description", descriptionController),
                      _buildTextField("Requester", requesterController),
                      _buildDropdownField(
                          "Division", selectedDivision, divisions, (value) {
                        setState(() => selectedDivision = value);
                      }),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/NewRequestQR',
                                  arguments: {
                                    'serviceCategory': selectedServiceCategory,
                                    'subject': subjectController.text,
                                    'description': descriptionController.text,
                                    'requester': requesterController.text,
                                    'division': selectedDivision,
                                  },
                                );
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
