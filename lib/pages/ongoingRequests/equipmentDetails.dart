import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/serviceStatus.dart';
import 'package:servicetracker_app/components/serviceHistoryModal.dart';

class EquipmentDetails extends StatefulWidget {
  final Map<String, dynamic>? equipmentData;
  final List<dynamic>? historyData;

  const EquipmentDetails({Key? key, this.equipmentData, this.historyData})
      : super(key: key);

  @override
  State<EquipmentDetails> createState() => _EquipmentDetailsState();
}

class _EquipmentDetailsState extends State<EquipmentDetails> {
  late List<dynamic> serviceHistory;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    serviceHistory = widget.historyData ?? [];
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    // Display loading indicator while data is being fetched
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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

                // Title expands but still constrained for overflow in landscape
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.equipmentData?['ticket'] ?? 'Ticket Number',
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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85, // Set width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Equipment Details Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Equipment Details
                            const Text(
                              "Equipment Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),

                            _buildInfoRow("Serial Number",
                                widget.equipmentData?['serialNumber'] ?? 'N/A'),
                            _buildInfoRow("Accountable",
                                widget.equipmentData?['accountable'] ?? 'N/A'),
                            _buildInfoRow("Division",
                                widget.equipmentData?['division'] ?? 'N/A'),
                            // Format the date for dateAcquired
                            _buildInfoRow(
                                "Date Acquired",
                                widget.equipmentData?['dateAcquired'] != null &&
                                        widget.equipmentData?['dateAcquired'] !=
                                            'No Date Acquired Available'
                                    ? (() {
                                        // Use the same date formatter as the history items
                                        final DateTime createdDate =
                                            DateTime.parse(
                                                widget.equipmentData![
                                                    'dateAcquired']);
                                        return "${createdDate.month.toString().padLeft(2, '0')}/${createdDate.day.toString().padLeft(2, '0')}/${createdDate.year} "
                                            "${createdDate.hour % 12 == 0 ? 12 : createdDate.hour % 12}:${createdDate.minute.toString().padLeft(2, '0')} ${createdDate.hour >= 12 ? 'PM' : 'AM'}";
                                      })()
                                    : 'N/A'),

                            const SizedBox(height: 15),

                            // Description section
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.equipmentData?['description'] ??
                                  'No description available.',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
// Changes to the Status Section
// Replace the Row and following code with this:

// Status Section
                      const Text(
                        "Service History",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

// Display all status history items without limit
                      if (serviceHistory.isEmpty)
                        const Center(
                          child: Text(
                            "No service history available",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        ...(() {
                          // Display in reverse chronological order (newest first)
                          return List.from(serviceHistory.reversed).map((item) {
                            // Format the date from created_at
                            final DateTime createdDate =
                                DateTime.parse(item['created_at']);
                            final String formattedDate =
                                "${createdDate.month.toString().padLeft(2, '0')}/${createdDate.day.toString().padLeft(2, '0')}/${createdDate.year}\n"
                                "${createdDate.hour % 12 == 0 ? 12 : createdDate.hour % 12}:${createdDate.minute.toString().padLeft(2, '0')}${createdDate.hour >= 12 ? 'PM' : 'AM'}";

                            // Capitalize status
                            final String statusCapitalized =
                                item['status'] != null
                                    ? item['status']
                                            .toString()
                                            .substring(0, 1)
                                            .toUpperCase() +
                                        item['status'].toString().substring(1)
                                    : '';

                            // Combine status and remarks
                            String statusText =
                                "$statusCapitalized: ${item['remarks'] ?? ''}";

                            // Action taken
                            if (item['action_name'] != null &&
                                item['action_name'].toString().isNotEmpty) {
                              statusText +=
                                  "\n\nAction Taken: ${item['action_name']}";
                            }

// Problem encountered
                            if (item['encountered_problem_name'] != null &&
                                item['encountered_problem_name']
                                    .toString()
                                    .isNotEmpty) {
                              statusText +=
                                  "\n\nProblem Encountered: ${item['encountered_problem_name']}";
                            }

                            // Call statusItem without the imagePath parameter
                            return statusItem(
                                context, formattedDate, statusText);
                          }).toList();
                        })(),

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

  // Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
