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

class EditIncidentReport extends StatefulWidget {
  final Map<String, dynamic> incident;
  const EditIncidentReport({Key? key, required this.incident}) : super(key: key);

  @override
  _EditIncidentReportState createState() => _EditIncidentReportState();
}

class _EditIncidentReportState extends State<EditIncidentReport> {
  final IncidentReportService _apiService = IncidentReportService();
  bool isSubmitting = false;

  String? selectedLocation;
  String? selectedVerifier;
  String? selectedApprover;
  bool isRepair = false;
  String selectedStatus = "none";
  DateTime? selectedDate;
  bool isAdditional = false;
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

  TextEditingController incidentNameController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController natureController = TextEditingController();
  TextEditingController impactsController = TextEditingController();
  TextEditingController affectedAreasController = TextEditingController();

  // Replace hardcoded lists with dynamic lists that will be populated from API
  List<Map<String, dynamic>> technicians = [];
  List<Map<String, dynamic>> verifiers = [];
  List<Map<String, dynamic>> approvers = [];
  
  // Map to store technicians by their name for easy lookup
  Map<String, int> technicianIdMap = {};

  final AutoSizeGroup radioTextGroup = AutoSizeGroup();
  final List<String> priorityLevels = ["Low", "Normal", "High"];

  // Placeholder for current user id, replace with your session logic
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and fields with widget.incident values
    incidentNameController.text = widget.incident['incident_name'] ?? '';
    subjectController.text = widget.incident['subject'] ?? '';
    descriptionController.text = widget.incident['description'] ?? '';
    natureController.text = widget.incident['incident_nature'] ?? '';
    impactsController.text = widget.incident['impact'] ?? '';
    affectedAreasController.text = widget.incident['affected_areas'] ?? '';
    selectedStatus = widget.incident['priority_level'] ?? "none";
    selectedLocation = widget.incident['location'];
    selectedVerifier = widget.incident['verifier_name'];
    selectedApprover = widget.incident['approver_name'];
    // Parse date and time
    if (widget.incident['incident_date'] != null) {
      selectedDate = DateTime.tryParse(widget.incident['incident_date']);
    }
    if (widget.incident['incident_time'] != null) {
      final timeParts = widget.incident['incident_time'].split(':');
      if (timeParts.length >= 2) {
        selectedTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }

    // TODO: Replace this with your actual session/user id retrieval logic
    // For example, from a provider or secure storage
    currentUserId = "123"; // Example user id

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
        
        // Make all technicians available as both verifiers and approvers
        verifiers = technicians;
        approvers = technicians;
        
        // Create map of technician names to IDs for easy lookup
        for (var tech in technicians) {
          if (tech['name'] != null && tech['id'] != null) {
            technicianIdMap[tech['name']] = tech['id'];
          }
        }
        
        print("Raw technicians data: $technicians");
        print("Name to ID map: $technicianIdMap");
        
        // Re-initialize selected values to match new data structure
        if (widget.incident['verifier_name'] != null) {
          selectedVerifier = widget.incident['verifier_name'];
          print("Selected verifier: $selectedVerifier (ID in map: ${technicianIdMap[selectedVerifier]})");
        }
        
        if (widget.incident['approver_name'] != null) {
          selectedApprover = widget.incident['approver_name'];
          print("Selected approver: $selectedApprover (ID in map: ${technicianIdMap[selectedApprover]})");
        }
      });
    } catch (e) {
      print("Error fetching technicians: $e");
    }
  }

  // Reset form fields to initial values
  void _resetForm() {
    incidentNameController.clear();
    subjectController.clear();
    descriptionController.clear();
    natureController.clear();
    impactsController.clear();
    affectedAreasController.clear();
    selectedStatus = "none";
    selectedLocation = null;
    selectedVerifier = null;
    selectedApprover = null;
    isRepair = false;
    isAdditional = false;
    selectedDate = null;
    selectedTime = null;
  }

  // Validate form fields
  bool _validateForm() {
    if (incidentNameController.text.isEmpty) {
      _showErrorSnackBar("Incident name is required.");
      return false;
    }
    if (subjectController.text.isEmpty) {
      _showErrorSnackBar("Subject is required.");
      return false;
    }
    if (descriptionController.text.isEmpty) {
      _showErrorSnackBar("Description is required.");
      return false;
    }
    if (natureController.text.isEmpty) {
      _showErrorSnackBar("Nature of incident is required.");
      return false;
    }
    if (impactsController.text.isEmpty) {
      _showErrorSnackBar("Impacts are required.");
      return false;
    }
    if (affectedAreasController.text.isEmpty) {
      _showErrorSnackBar("Affected areas are required.");
      return false;
    }
    if (selectedStatus == "none") {
      _showErrorSnackBar("Priority level is required.");
      return false;
    }
    if (selectedLocation == null) {
      _showErrorSnackBar("Location is required.");
      return false;
    }
    if (selectedVerifier == null) {
      _showErrorSnackBar("Verifier is required.");
      return false;
    }
    if (selectedApprover == null) {
      _showErrorSnackBar("Approver is required.");
      return false;
    }
    if (selectedDate == null) {
      _showErrorSnackBar("Incident date is required.");
      return false;
    }
    if (selectedTime == null) {
      _showErrorSnackBar("Incident time is required.");
      return false;
    }
    return true;
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Submit edited incident report to the API
  Future<void> _submitIncidentReport() async {
    if (!_validateForm()) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      // Get verifier ID from the map instead of hardcoding
      String? verifierId;
      if (selectedVerifier != null && selectedVerifier!.isNotEmpty) {
        verifierId = technicianIdMap[selectedVerifier]?.toString();
        if (verifierId == null) {
          _showErrorSnackBar("Selected verifier not found in system. Please choose another.");
          setState(() => isSubmitting = false);
          return;
        }
      }

      // Get approver ID from the map instead of hardcoding
      String? approverId;
      if (selectedApprover != null && selectedApprover!.isNotEmpty) {
        approverId = technicianIdMap[selectedApprover]?.toString();
        if (approverId == null) {
          _showErrorSnackBar("Selected approver not found in system. Please choose another.");
          setState(() => isSubmitting = false);
          return;
        }
      }

      // Print debug info before making the API call
      print('Submitting with verifier: $selectedVerifier (ID: $verifierId)');
      print('Submitting with approver: $selectedApprover (ID: $approverId)');

      // Call the update API
      final response = await _apiService.updateIncidentReport(
        id: widget.incident['id'],
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
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
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
                      title: "Incident report updated successfully",
                      message: "Your incident report has been updated successfully.",
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
      // Enhanced error logging and handling
      print('========= INCIDENT UPDATE ERROR =========');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      print('Incident ID: ${widget.incident['id']}');
      
      // Fix type errors in debug logs - use proper lookup for Map objects
      String verifierId = "null";
      if (selectedVerifier != null) {
        // Find the index of the map with name matching selectedVerifier
        int index = verifiers.indexWhere((v) => v['name'] == selectedVerifier);
        verifierId = index >= 0 ? verifiers[index]['id'].toString() : "not found";
      }
      
      String approverId = "null";
      if (selectedApprover != null) {
        // Find the index of the map with name matching selectedApprover
        int index = approvers.indexWhere((a) => a['name'] == selectedApprover);
        approverId = index >= 0 ? approvers[index]['id'].toString() : "not found";
      }
      
      print('Verifier: $selectedVerifier (ID: $verifierId)');
      print('Approver: $selectedApprover (ID: $approverId)');
      print('============ END ERROR LOG =============');
      
      // Show more specific error message based on the error
      if (e.toString().contains("foreign key constraint fails")) {
        _showErrorSnackBar("Database error: Invalid user selection. Please select different verifier/approver.");
      } else {
        _showErrorSnackBar("Unable to update incident report. Please try again later.");
      }
    } finally {
      setState(() {
        isSubmitting = false;
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
            alignment: Alignment.center,
            children: [
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: AutoSizeText(
                      'Edit Incident',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 12,
                      overflow: TextOverflow.ellipsis,
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
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 25, 0, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Incident Details",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Priority Level dropdown
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
                    
                    // Incident Name field
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Incident Name',
                        incidentNameController,
                      ),
                    ),
                    
                    // Subject field
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Subject',
                        subjectController,
                      ),
                    ),
                    
                    // Description field
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Description',
                        descriptionController,
                        maxLines: 3,
                      ),
                    ),
                    
                    // Date picker
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

                    // Time picker
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
                    
                    // Nature of incident field
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Nature of Incident',
                        natureController,
                      ),
                    ),
                    
                    // Location dropdown
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: buildDropdownField(
                        context, 
                        "Location of Incident",
                        selectedLocation, 
                        Locations, 
                        (value) {
                          setState(() => selectedLocation = value);
                        }
                      ),
                    ),

                    // Impacts field
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Impact/s',
                        impactsController,
                      ),
                    ),

                    // Affected areas field
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildTextField(
                        'Affected Area/s',
                        affectedAreasController,
                      ),
                    ),

                    // Signatories section
                    const SizedBox(height: 15),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Signatories",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Verifier dropdown
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: buildDropdownField(
                        context, 
                        "Verified by",
                        selectedVerifier, 
                        verifiers.map((v) => v['name'] as String).toList(), 
                        (value) {
                          setState(() => selectedVerifier = value);
                        }
                      ),
                    ),
                    
                    // Approver dropdown
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: buildDropdownField(
                        context, 
                        "Approved by",
                        selectedApprover, 
                        approvers.map((a) => a['name'] as String).toList(), 
                        (value) {
                          setState(() => selectedApprover = value);
                        }
                      ),
                    ),
                    
                    // Update button
                    _buildButton(
                      context, 
                      isSubmitting ? "UPDATING..." : "UPDATE INCIDENT REPORT",
                      Color(0xFF007A33), 
                      _submitIncidentReport
                    ),
                    
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // Build button widget
  Widget _buildButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isSubmitting
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }
}
