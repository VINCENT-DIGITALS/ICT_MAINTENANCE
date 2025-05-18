import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/api_service/ongoing_request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicetracker_app/components/messageSentModal.dart';
import 'package:servicetracker_app/components/request/ButtonRequestModal.dart';
import 'package:servicetracker_app/components/request/PickRequestModal.dart';
import 'package:servicetracker_app/pages/ongoingRequests/ongoingRequests.dart';
import 'package:servicetracker_app/pages/ongoingRequests/serviceDetails.dart';

import '../../auth/sessionmanager.dart';
import '../../api_service/api_constants.dart';

class EditTechniciansScreen extends StatefulWidget {
  final int? requestId; // Change to String? to match API expectations
  final String? leadTechnician;
  final List<String>? coWorkers;

  const EditTechniciansScreen({
    Key? key,
    this.requestId,
    this.leadTechnician,
    this.coWorkers,
  }) : super(key: key);

  @override
  _EditTechniciansScreenState createState() => _EditTechniciansScreenState();
}

class _EditTechniciansScreenState extends State<EditTechniciansScreen> {
  String? selectedLeadTechnician;
  List<String> selectedCoWorkers = [];
  bool isUpdating = false;
  bool isLoading = true;

  // Store technician data from API
  List<Map<String, dynamic>> techniciansData = [];

  // Map technician names to IDs
  Map<String, String> techNameToIdMap = {};

  @override
  void initState() {
    super.initState();
    // Initialize with provided values
    selectedLeadTechnician = widget.leadTechnician;
    if (widget.coWorkers != null) {
      selectedCoWorkers = List.from(widget.coWorkers!);
    }

    // Fetch technicians from API
    _fetchTechnicians();
  }

  // Method to fetch technicians data
  Future<void> _fetchTechnicians() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          "$kBaseUrl/technicians/available"));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data']['technicians'] != null) {
          setState(() {
            // Update technicians data with the response
            techniciansData = List<Map<String, dynamic>>.from(
                jsonResponse['data']['technicians']);

            // Build the name to ID mapping
            for (var tech in techniciansData) {
              techNameToIdMap[tech['technician_name']] = tech['philrice_id'];
            }

            isLoading = false;
          });
        } else {
          throw Exception("Invalid response format or no technicians data.");
        }
      } else {
        throw Exception("Failed to fetch technicians: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching technicians: $e");
      // Use fallback data if API fails
      setState(() {
        techniciansData = [
          {
            "technician_id": 1,
            "philrice_id": "23-0001",
            "technician_name": "John Doe"
          },
          {
            "technician_id": 2,
            "philrice_id": "23-0002",
            "technician_name": "John Deer"
          }
        ];

        // Build the name to ID mapping for fallback data
        for (var tech in techniciansData) {
          techNameToIdMap[tech['technician_name']] = tech['philrice_id'];
        }

        isLoading = false;
      });
    }
  }

// Update the _updateTechnicians method

// Update the _updateTechnicians method

  void _updateTechnicians() async {
    // Validate lead technician is selected
    if (selectedLeadTechnician == null || selectedLeadTechnician!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a lead technician'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog first
    showDialog(
      context: context,
      builder: (dialogBuilderContext) => CustomModalPickRequest(
        title: "TECHNICIANS UPDATED",
        message:
            "Are you sure you want to update the technicians for this request?",
        onConfirm: () async {
          // Close the dialog first
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
            // Get the ID of the selected lead technician
            final leadTechId = techNameToIdMap[selectedLeadTechnician] ?? "";

            // Get IDs of selected co-workers
            List<String> coWorkerIds = [];
            for (String name in selectedCoWorkers) {
              final id = techNameToIdMap[name];
              if (id != null) coWorkerIds.add(id);
            }

            // Get current user ID from session
            final SessionManager session = SessionManager();
            final user = await session.getUser();
            final String technicianId = user?['philrice_id'] ?? "";

            if (technicianId.isEmpty) {
              // Close loading dialog
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User ID not found. Please log in again.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Create API service instance
            final apiService = OngoingRequestService();

            // Call API to update technicians
            final result = await apiService.updateTechnicians(
              requestId: widget.requestId ?? 0,
              primaryTechnicianId: leadTechId,
              secondaryTechnicianIds: coWorkerIds,
              remarks: "Updated from mobile app",
              actingUserId: technicianId,
            );

            // Always close loading dialog first
            Navigator.of(context).pop();

            if (result['success'] == true) {
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
                          child: CustomMessageSentModal(
                            title: "Technicians Updated",
                            message:
                                "The technicians for this request have been updated",
                            // Inside the onConfirm method, modify the navigation as follows:

                            onConfirm: () {
                              Navigator.pop(context);
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

                              // Navigate back to ServiceDetails with the correct parameter
                              // Replace current screen with ServiceDetails but preserve history
                            },
                          ),
                        ),
                      ),

                      // Floating close button - also triggers navigation
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close dialog
                          // Navigate to OngoingRequests and remove all screens between
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
                          

                          // Navigate back to OngoingRequests
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
                  content: Text(result['message'] ?? 'Unknown error'),
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
                content: Text('Error updating technicians: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _addCoWorker(String name) {
    // Don't add duplicates or the lead technician
    if (!selectedCoWorkers.contains(name) && name != selectedLeadTechnician) {
      setState(() {
        selectedCoWorkers.add(name);
      });
    }
  }

  void _removeCoWorker(String name) {
    setState(() {
      selectedCoWorkers.remove(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get technician names from API data
    final availableTechnicians = techniciansData
        .map<String>((tech) => tech['technician_name'] as String)
        .toList();

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
                    Navigator.pop(context);
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
                    child: const Text(
                      'Edit Technician/s',
                      style: TextStyle(
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lead Technician Section
                        const Text(
                          "Lead Technician",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Lead Technician Dropdown
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: availableTechnicians
                                      .contains(selectedLeadTechnician)
                                  ? selectedLeadTechnician
                                  : null,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: Colors.grey[600]),
                              isExpanded: true,
                              hint: Text(selectedLeadTechnician != null &&
                                      !availableTechnicians
                                          .contains(selectedLeadTechnician)
                                  ? selectedLeadTechnician! // Show as hint text if not in list
                                  : "Select"),
                              onChanged: (String? newValue) {
                                setState(() {
                                  // Store the previous lead technician
                                  final previousLeadTech =
                                      selectedLeadTechnician;

                                  // Set the new lead technician
                                  selectedLeadTechnician = newValue;

                                  // If the new lead was previously a co-worker, remove from co-workers
                                  if (selectedCoWorkers.contains(newValue)) {
                                    selectedCoWorkers.remove(newValue);
                                  }

                                  // Clear all co-workers and add previous lead as first co-worker
                                  if (previousLeadTech != null &&
                                      previousLeadTech.isNotEmpty &&
                                      previousLeadTech != newValue) {
                                    // Save the previous lead technician
                                    final prevLead = previousLeadTech;

                                    // Clear all co-workers
                                    selectedCoWorkers.clear();

                                    // Add the previous lead as the first co-worker
                                    selectedCoWorkers.add(prevLead);
                                  }
                                });
                              },
                              items: availableTechnicians
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey[400],
                                        radius: 15,
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          value,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Co-workers Section
                        const Text(
                          "Co-workers",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Co-worker Dropdown - only show if there are available technicians to add
                        if (availableTechnicians
                            .where((tech) =>
                                tech != selectedLeadTechnician &&
                                !selectedCoWorkers.contains(tech))
                            .isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                icon: Icon(Icons.add, color: Colors.grey[600]),
                                isExpanded: true,
                                hint: const Text("Select co-worker"),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    _addCoWorker(newValue);
                                  }
                                },
                                value: null, // Always show hint
                                items: availableTechnicians
                                    .where((tech) =>
                                        tech != selectedLeadTechnician &&
                                        !selectedCoWorkers.contains(tech))
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          radius: 15,
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            value,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Selected co-workers list
                        if (selectedCoWorkers.isNotEmpty)
                          ...selectedCoWorkers
                              .map((coWorker) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[400],
                                                  radius: 15,
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    coWorker,
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close,
                                                size: 20),
                                            onPressed: () =>
                                                _removeCoWorker(coWorker),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList()
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
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

                        const SizedBox(height: 40),

                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isUpdating ? null : _updateTechnicians,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008037),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isUpdating
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "UPDATE TECHNICIAN",
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
}
