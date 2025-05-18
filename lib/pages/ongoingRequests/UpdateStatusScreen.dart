import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:servicetracker_app/auth/sessionmanager.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/components/qrScanner.dart';
import 'package:servicetracker_app/components/request/ButtonRequestModal.dart';
import 'package:servicetracker_app/components/request/PickRequestModal.dart';
import 'package:servicetracker_app/pages/ongoingRequests/EditTechniciansScreen.dart';
import 'package:servicetracker_app/api_service/ongoing_request.dart';
import 'package:image_picker/image_picker.dart';

class UpdateStatusScreen extends StatefulWidget {
  final Map<String, dynamic>? requestData;

  const UpdateStatusScreen({
    Key? key,
    this.requestData,
  }) : super(key: key);

  @override
  _UpdateStatusScreenState createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  String selectedStatus = "ONGOING"; // Default selected status
  String currentStatus =
      "ONGOING"; // Added to store the current status from the request
  final TextEditingController _remarksController = TextEditingController();
  bool isSendingUpdate = false;
  final OngoingRequestService _apiService = OngoingRequestService();

  // For Technician findings
  int? selectedProblemId;
  int? selectedActionId;
  String? selectedProblemText;
  String? selectedActionText;

  // For documentation
  File? documentationImage;

  // Lists for problems and actions
  List<Map<String, dynamic>> problems = [];
  List<Map<String, dynamic>> actions = [];
  // For QR scanning
  String? scannedLocation;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    _fetchProblemsAndActions();
    // Get the current status from the request data
    if (widget.requestData != null &&
        widget.requestData!['latest_status'] != null) {
      // Check if status is in the nested structure (new format)
      if (widget.requestData!['latest_status']['status'] != null &&
          widget.requestData!['latest_status']['status']['status_name'] !=
              null) {
        // Set the current status based on nested status object
        currentStatus = widget.requestData!['latest_status']['status']
                ['status_name']
            .toString()
            .toUpperCase();
      }
      // Fallback to older format if needed
      else if (widget.requestData!['latest_status']['status'] != null) {
        currentStatus = widget.requestData!['latest_status']['status']
            .toString()
            .toUpperCase();
      }
      // Set the selected status to a different status than the current one
      selectDefaultStatus();
    }
  }

  // Helper method to select a default status that isn't the current one
  void selectDefaultStatus() {
    final List<String> statusOptions = [
      "ONGOING",
      "PAUSED",
      "DENIED",
      "CANCELLED",
      "COMPLETED"
    ];

    // Remove the current status from options to find a valid default
    statusOptions.remove(currentStatus);
    if (statusOptions.isNotEmpty) {
      setState(() {
        selectedStatus =
            statusOptions.first; // Select the first available status
      });
    }
  }

// Add this method to handle QR scanning
  void _showQRScannerModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    ).then((scannedCode) {
      if (scannedCode != null) {
        setState(() {
          scannedLocation = scannedCode;
        });
      }
    });
  }

  // Fetch problems and actions from API
  Future<void> _fetchProblemsAndActions() async {
    try {
      final problemsList = await _apiService.fetchProblems();
      final actionsList = await _apiService.fetchActions();

      setState(() {
        problems = problemsList;
        actions = actionsList;
      });
    } catch (e) {
      print('Error fetching problems and actions: $e');
    }
  }

  // Pick image for documentation
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          documentationImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // This method will handle the status update
  void _updateStatus() async {
    // First perform validation checks
    if (_remarksController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter remarks for this status update'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if trying to update to the same status
    if (selectedStatus == currentStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cannot update to the same status. Please select a different status.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if technician findings are required but not provided
    if (selectedStatus != "ONGOING" &&
        (selectedProblemId == null || selectedActionId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select both Problems Encountered and Actions Taken'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // All validation passed, show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogBuilderContext) => CustomModalPickRequest(
        title: "UPDATE STATUS",
        message:
            "Are you sure you want to update this service request to ${selectedStatus.toUpperCase()}? This action cannot be undone.",
        onConfirm: () async {
          // Close the confirmation dialog
          Navigator.pop(dialogBuilderContext);

          // Show loading indicator
          final loadingDialog = showDialog(
            context: context,
            barrierDismissible: false,
            builder: (loadingContext) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            // Get the request ID from data
            final requestId = widget.requestData?['id']?.toString() ?? '';

            // Get current user ID from session
            final SessionManager session = SessionManager();
            final user = await session.getUser();
            final String philriceId = user?['philrice_id'] ?? "";

            // Call the appropriate API method based on selected status
            Map<String, dynamic> result;

            switch (selectedStatus) {
              case "COMPLETED":
                result = await _apiService.markAsCompleted(
                  requestId: requestId,
                  philriceId: philriceId,
                  remarks: _remarksController.text,
                  problemId: selectedProblemId,
                  actionId: selectedActionId,
                  documentationImage: documentationImage,
                  location: scannedLocation,
                );
                break;
              case "PAUSED":
                result = await _apiService.markAsPaused(
                  requestId: requestId,
                  philriceId: philriceId,
                  remarks: _remarksController.text,
                  problemId: selectedProblemId,
                  actionId: selectedActionId,
                  documentationImage: documentationImage,
                  location: scannedLocation,
                );
                break;
              case "DENIED":
                result = await _apiService.markAsDenied(
                  requestId: requestId,
                  philriceId: philriceId,
                  remarks: _remarksController.text,
                  problemId: selectedProblemId,
                  actionId: selectedActionId,
                  documentationImage: documentationImage,
                  location: scannedLocation,
                );
                break;
              case "CANCELLED":
                result = await _apiService.markAsCancelled(
                  requestId: requestId,
                  philriceId: philriceId,
                  remarks: _remarksController.text,
                  problemId: selectedProblemId,
                  actionId: selectedActionId,
                  documentationImage: documentationImage,
                  location: scannedLocation,
                );
                break;
              case "ONGOING":
              default:
                result = await _apiService.markAsOngoing(
                  requestId: requestId,
                  philriceId: philriceId,
                  remarks: _remarksController.text,
                  problemId: selectedProblemId,
                  actionId: selectedActionId,
                  documentationImage: documentationImage,
                  location: scannedLocation,
                );
                break;
            }

            // Always close loading dialog first
            Navigator.of(context).pop();

            if (result['success']) {
              // Show success dialog with floating close button
              showDialog(
                context: context,
                barrierDismissible: true,
                useRootNavigator: true,
                builder: (context) => Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main dialog content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: CustomModalButtonRequest(
                            title: "Status Updated Successfully",
                            message:
                                "The service request status has been updated to ${selectedStatus}",
                            onConfirm: () {
                              Navigator.pop(context); // Close the dialog first

                              // Navigate to OngoingRequests but keep the home screen in history
                              // First navigate to home, then to OngoingRequests to ensure proper back navigation
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home', // First go to home
                                (route) =>
                                    route.settings.name ==
                                    '/', // Keep only splash screen
                              );

                              // Then navigate to OngoingRequests - this makes Home the previous screen
                              Navigator.pushNamed(context, '/OngoingRequests');
                            },
                          ),
                        ),
                      ),

                      // Floating close button
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close the dialog first

                          // First navigate to home, then to OngoingRequests to ensure proper back navigation
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home', // First go to home
                            (route) =>
                                route.settings.name ==
                                '/', // Keep only splash screen
                          );

                          // Then navigate to OngoingRequests - this makes Home the previous screen
                          Navigator.pushNamed(context, '/OngoingRequests');
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
              );
            } else {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            // Always ensure loading dialog is closed on error
            Navigator.of(context).pop();

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating status: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adjust layout based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    const spacing = 10.0;
    const buttonWidth = 100.0; // Base width for calculation

    // Determine optimal layout
    int firstRowCount;
    int secondRowCount = 0;

    // Calculate how many buttons can fit in one row
    int maxButtonsPerRow = (screenWidth - 32) ~/ (buttonWidth + spacing);
    maxButtonsPerRow = maxButtonsPerRow.clamp(1, 5); // Limit between 1 and 5

    if (maxButtonsPerRow >= 5) {
      // All buttons fit in one row
      firstRowCount = 5;
    } else if (maxButtonsPerRow >= 3) {
      // 3 in first row, 2 in second
      firstRowCount = 3;
      secondRowCount = 2;
    } else if (maxButtonsPerRow == 2) {
      // 2 in first row, 2 in second row, 1 in third
      firstRowCount = 2;
      secondRowCount = 2;
      // Last button in third row
    } else {
      // One button per row (narrow screen)
      firstRowCount = 1;
      // Rest in separate rows
    }

    // List of status options
    final statusOptions = [
      "ONGOING",
      "PAUSED",
      "DENIED",
      "CANCELLED",
      "COMPLETED"
    ];

    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.height * 0.22
              : MediaQuery.of(context).size.height * 0.13,
          showFooter: false,
          backgroundColor: const Color(0xFF14213D),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(
                        context); // Changed to pop instead of pushing home
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Update Status',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ...existing code...
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Adaptive layout for status buttons
                  if (firstRowCount == 5)
                    // All buttons in one row
                    _buildButtonRow(statusOptions, 0, 5)
                  else if (firstRowCount == 3)
                    // 3-2 layout
                    Column(
                      children: [
                        _buildButtonRow(statusOptions, 0, 3),
                        const SizedBox(height: spacing),
                        _buildButtonRow(statusOptions, 3, 5),
                      ],
                    )
                  else if (firstRowCount == 2)
                    // 2-2-1 layout
                    Column(
                      children: [
                        _buildButtonRow(statusOptions, 0, 2),
                        const SizedBox(height: spacing),
                        _buildButtonRow(statusOptions, 2, 4),
                        const SizedBox(height: spacing),
                        _buildButtonRow(statusOptions, 4, 5),
                      ],
                    )
                  else
                    // One button per row (vertical layout)
                    Column(
                      children: [
                        for (int i = 0; i < statusOptions.length; i++) ...[
                          if (i > 0) const SizedBox(height: spacing),
                          _buildStatusButton(statusOptions[i], Colors.green),
                        ],
                      ],
                    ),

                  const SizedBox(height: 30),

                  // Add the Technician section
                  _buildTechnicianSection(),

                  const SizedBox(height: 30),

                  // Add the Documentation section
                  _buildDocumentationSection(),

                  const SizedBox(height: 30),

                  // Add the Location section
                  _buildLocationSection(),

                  const SizedBox(height: 30),
                  buildTextField(
                    "Remarks",
                    _remarksController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Remarks cannot be empty';
                      }
                      return null;
                    },
                    maxLines: 10,
                  ),
                  const SizedBox(height: 30),
                  // Update Status Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSendingUpdate ? null : _updateStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008037),
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSendingUpdate
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "UPDATE STATUS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// Update the Technician section
  Widget _buildTechnicianSection() {
    // Get primary technician from request data
    final primaryTechnicianData = widget.requestData?['primary_technician'];
    final primaryTechnicianId = primaryTechnicianData?['technician_emp_id'];
    final primaryTechnicianName =
        primaryTechnicianData?['technician_name'] ?? "";

    // Get service request ID for later use
    final serviceRequestId = widget.requestData?['id']?.toString() ?? "";

    // Get secondary technicians from request data
    final secondaryTechnicians =
        widget.requestData?['secondary_technicians'] ?? [];

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Technician/s",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () => _showAddTechnicianModal(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Edit Technicians",
                  style: TextStyle(
                    color: Color(0xFF008037),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lead Technician - Simplified UI
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lead Technician",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade400,
                      radius: 14,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      primaryTechnicianName.isNotEmpty
                          ? primaryTechnicianName
                          : "No Lead Technician",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Co-workers - Simplified UI
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Co-workers",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              if (secondaryTechnicians.isNotEmpty)
                ...secondaryTechnicians.map((technicianData) {
                  final technicianName =
                      technicianData['technician_name'] ?? "";
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade400,
                          radius: 14,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          technicianName.isNotEmpty
                              ? technicianName
                              : "No Name",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              else
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "No co-workers assigned",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

// Add this for the Documentation section
  Widget _buildDocumentationSection() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Documentation",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: documentationImage != null
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          documentationImage!,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              documentationImage = null;
                            });
                          },
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          onPressed: _pickImage,
                        ),
                        const Text(
                          "Take a photo",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

// Add this for the Location section
  Widget _buildLocationSection() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Location",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        scannedLocation != null
                            ? scannedLocation!
                            : "Scan Location",
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _showQRScannerModal, // Call QR scanner modal
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008037),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "SCAN QR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Technician Findings fields (now shown for all statuses)
          const SizedBox(height: 20),
          const Text(
            "Technician Findings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Problems Encountered field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Problems Encountered",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: problems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Loading problems...",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedProblemId,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey[600]),
                          isExpanded: true,
                          hint: const Text("Select Problem"),
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedProblemId = newValue;
                              // Find the problem text for the selected ID
                              if (newValue != null) {
                                final selectedProblem = problems.firstWhere(
                                  (problem) => problem['id'] == newValue,
                                  orElse: () =>
                                      {'description': 'Unknown Problem'},
                                );
                                selectedProblemText =
                                    selectedProblem['description'];
                              }
                            });
                          },
                          items: problems.map<DropdownMenuItem<int>>((problem) {
                            return DropdownMenuItem<int>(
                              value: problem['id'],
                              child: Text(
                                problem['description'] ?? '',
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),

          // Actions Taken field
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Actions Taken",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: actions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Loading actions...",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedActionId,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey[600]),
                          isExpanded: true,
                          hint: const Text("Select Action"),
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedActionId = newValue;
                              // Find the action text for the selected ID
                              if (newValue != null) {
                                final selectedAction = actions.firstWhere(
                                  (action) => action['id'] == newValue,
                                  orElse: () =>
                                      {'description': 'Unknown Action'},
                                );
                                selectedActionText =
                                    selectedAction['description'];
                              }
                            });
                          },
                          items: actions.map<DropdownMenuItem<int>>((action) {
                            return DropdownMenuItem<int>(
                              value: action['id'],
                              child: Text(
                                action['description'] ?? '',
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Method to add technicians
  void _showAddTechnicianModal(BuildContext context) async {
    // Get service request ID
    final serviceRequestId = widget.requestData?['id'];

    // Get current primary technician data
    final primaryTechnicianData = widget.requestData?['primary_technician'];
    final primaryTechnicianName =
        primaryTechnicianData?['technician_name'] ?? "";

    // Get current secondary technicians
    final secondaryTechnicians =
        widget.requestData?['secondary_technicians'] ?? [];
    List<String> coWorkers = [];

    // Extract secondary technician names to a list of strings
    for (var tech in secondaryTechnicians) {
      final technicianName = tech['technician_name'] ?? "";
      if (technicianName.isNotEmpty) {
        coWorkers.add(technicianName);
      }
    }

    // Navigate to EditTechniciansScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTechniciansScreen(
          requestId: serviceRequestId,
          leadTechnician: primaryTechnicianName,
          coWorkers: coWorkers,
        ),
      ),
    );

    // Handle the result when returning from EditTechniciansScreen
    if (result != null && result is Map<String, dynamic>) {
      // Show a loading indicator
      setState(() {
        isSendingUpdate = true;
      });

      try {
        // Fetch updated request data after technician changes
        final updatedData = await _apiService
            .fetchRequestWithHistoryAndWorkingTime(serviceRequestId.toString());

        // Update the UI with fresh data
        setState(() {
          // Update the widget data with the fresh data
          widget.requestData?.update('primary_technician',
              (_) => updatedData['serviceRequest']['primary_technician'],
              ifAbsent: () =>
                  updatedData['serviceRequest']['primary_technician']);

          widget.requestData?.update('secondary_technicians',
              (_) => updatedData['serviceRequest']['secondary_technicians'],
              ifAbsent: () =>
                  updatedData['serviceRequest']['secondary_technicians']);
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Technician information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating technician information: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Hide loading indicator
        setState(() {
          isSendingUpdate = false;
        });
      }
    }
  }

// Helper method to build a row of buttons
  Widget _buildButtonRow(List<String> options, int start, int end) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = start; i < end; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i > start ? 10 : 0,
                right: i < end - 1 ? 0 : 0,
              ),
              child: _buildStatusButton(options[i], Colors.green),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusButton(String status, Color color) {
    bool isSelected = selectedStatus == status;
    bool isDisabled =
        status == currentStatus; // Disable if it's the current status

    // Define colors based on selection and disabled state
    Color bgColor;
    if (isDisabled) {
      bgColor = Colors.grey; // Grey for disabled (current) status
    } else if (isSelected) {
      bgColor = const Color(0xFF008037); // Green for selected status
    } else {
      bgColor = const Color(0xFF14213D); // Navy blue for non-selected status
    }

    Color textColor = Colors.white;

    return InkWell(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                selectedStatus = status;
              });
            },
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0, // Reduce opacity if disabled
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForStatus(status),
                color: textColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              if (isDisabled)
                const Text(
                  "(current)",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case "ONGOING":
        return Icons.access_time; // Clock icon
      case "PAUSED":
        return Icons.pause_outlined; // Pause icon
      case "DENIED":
        return Icons.cancel_outlined; // X icon
      case "CANCELLED":
        return Icons.do_not_disturb_alt_outlined; // Circle with slash
      case "COMPLETED":
        return Icons.check_circle_outline_outlined; // Checkmark in circle
      default:
        return Icons.circle_outlined;
    }
  }
}
