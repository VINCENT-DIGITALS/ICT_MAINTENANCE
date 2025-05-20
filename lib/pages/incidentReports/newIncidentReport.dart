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
import 'package:servicetracker_app/components/request/ButtonRequestModal.dart';
import 'package:servicetracker_app/api_service/incident_report_service.dart';

class NewIncidentReport extends StatefulWidget {
  const NewIncidentReport({Key? key}) : super(key: key);

  @override
  _NewIncidentReportState createState() => _NewIncidentReportState();
}

class _NewIncidentReportState extends State<NewIncidentReport> {
  final IncidentReportService _apiService = IncidentReportService();
  bool isSubmitting = false;
  
  String? selectedLocation;
  String? selectedVerifier;  // New variable for "Verified by"
  String? selectedApprover;  // New variable for "Approved by"
  bool isRepair = false;
  String selectedStatus = "none"; // Default selected value
  DateTime? selectedDate;
  bool isAdditional = false; // Checkbox state
  TimeOfDay? selectedTime;
  final List<String> Locations = [
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
  
  // Updated controllers for each form field
  TextEditingController incidentNameController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController natureController = TextEditingController();
  TextEditingController impactsController = TextEditingController();
  TextEditingController affectedAreasController = TextEditingController();
  
  // Replace hardcoded lists with dynamic lists that will be populated from API
  List<Map<String, dynamic>> technicians = [];
  List<String> verifierNames = []; // List of verifier names for dropdown
  List<String> approverNames = []; // List of approver names for dropdown
  
  // Map to store technicians by their name for easy lookup
  Map<String, int> technicianIdMap = {};
  
  final AutoSizeGroup radioTextGroup = AutoSizeGroup(); // ✅ Shared Group
  final List<String> priorityLevels = ["Low", "Normal", "High"];

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

  // Reset all form fields
  void _resetForm() {
    setState(() {
      incidentNameController.clear();
      subjectController.clear();
      descriptionController.clear();
      natureController.clear();
      impactsController.clear();
      affectedAreasController.clear();
      selectedStatus = "none";
      selectedLocation = null;
      selectedDate = null;
      selectedTime = null;
      isAdditional = false;
    });
  }

  // Helper method to validate form fields
  bool _validateForm() {
    if (selectedStatus == "none") {
      _showErrorSnackBar("Please select a priority level");
      return false;
    }
    if (incidentNameController.text.isEmpty) {
      _showErrorSnackBar("Incident name is required");
      return false;
    }
    if (natureController.text.isEmpty) {
      _showErrorSnackBar("Nature of incident is required");
      return false;
    }
    if (selectedDate == null) {
      _showErrorSnackBar("Date of incident is required");
      return false;
    }
    if (selectedTime == null) {
      _showErrorSnackBar("Time of incident is required");
      return false;
    }
    if (selectedLocation == null) {
      _showErrorSnackBar("Location of incident is required");
      return false;
    }
    
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Submit incident report to the API
  Future<void> _submitIncidentReport() async {
    if (!_validateForm()) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      // Get verifier ID from the map instead of hardcoding
      String? verifierId;
      if (selectedVerifier != null) {
        verifierId = technicianIdMap[selectedVerifier]?.toString();
      }

      // Get approver ID from the map instead of hardcoding
      String? approverId;
      if (selectedApprover != null) {
        approverId = technicianIdMap[selectedApprover]?.toString();
      }

      // Call the API with the real IDs
      final response = await _apiService.submitIncidentReport(
        priorityLevel: selectedStatus,
        incidentName: incidentNameController.text,
        incidentNature: natureController.text,
        incidentDate: selectedDate!,
        incidentTime: selectedTime!,
        location: selectedLocation!,
        subject: subjectController.text,
        description: descriptionController.text,
        impact: impactsController.text,
        affectedAreas: affectedAreasController.text,
        verifierId: verifierId,
        approverId: approverId,
      );

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PopScope(
          // Handle system back button with PopScope instead of WillPopScope
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              // Perform the same actions as the close button
              _resetForm();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => route.settings.name == '/',
              );
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
                      title: "Incident report submitted successfully",
                      message: "Your incident report has been submitted successfully.",
                      onConfirm: () async {
                        Navigator.pop(context);
                        _resetForm();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => route.settings.name == '/',
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    _resetForm();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => route.settings.name == '/',
                    );
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
    } catch (e) {
      _showErrorSnackBar("Error submitting incident report: $e");
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch technicians from API
    _fetchTechnicians();
  }
  
  // Fetch technicians from API
  Future<void> _fetchTechnicians() async {
    try {
      final response = await _apiService.fetchIncidentReports();
      setState(() {
        // Store all technicians
        technicians = List<Map<String, dynamic>>.from(response['technicians'] ?? []);
        
        // Create map of technician names to IDs for easy lookup
        for (var tech in technicians) {
          if (tech['name'] != null) {
            technicianIdMap[tech['name']] = tech['id'];
          }
        }
        
        // For this example, let's assume the first few technicians are verifiers
        // and the rest are approvers - in a real app, you might have roles defined
        List<Map<String, dynamic>> verifierMaps = technicians.take(4).toList();
        List<Map<String, dynamic>> approverMaps = technicians.skip(4).take(4).toList();
        
        // Extract just the names for dropdown display
        verifierNames = verifierMaps.map((v) => v['name'] as String).toList();
        approverNames = approverMaps.map((a) => a['name'] as String).toList();
        
        // If the lists are empty, provide default values for testing
        if (verifierNames.isEmpty) {
          verifierNames = ['Mark Johnson', 'Michael Brown', 'Sarah Wilson', 'Laura Garcia'];
        }
        if (approverNames.isEmpty) {
          approverNames = ['John Doe', 'John Deer', 'Jane Smith', 'Emily Davis'];
        }
      });
    } catch (e) {
      print("Error fetching technicians: $e");
      // Set default values if API fails
      setState(() {
        verifierNames = ['Mark Johnson', 'Michael Brown', 'Sarah Wilson', 'Laura Garcia'];
        approverNames = ['John Doe', 'John Deer', 'Jane Smith', 'Emily Davis'];
      });
    }
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
                        incidentNameController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Subject',
                        subjectController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Description',
                        descriptionController,
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
                        natureController,
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
                        impactsController,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Affected Area/s',
                        affectedAreasController,
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
                      child: buildDropdownField(context, "Verified by",
                          selectedVerifier, verifierNames, (value) {
                        setState(() => selectedVerifier = value);
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: buildDropdownField(context, "Approved by",
                          selectedApprover, approverNames, (value) {
                        setState(() => selectedApprover = value);
                      }),
                    ),
                  
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
        onPressed: isSubmitting 
          ? null 
          : () => _submitIncidentReport(),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isSubmitting
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              text,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
      ),
    );
  }
}
