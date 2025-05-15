import 'package:flutter/material.dart';

void showServiceHistoryModal(
    BuildContext context, List<Map<String, dynamic>> serviceHistory) {
  showDialog(
    context: context,
    barrierDismissible: true, // Allows dismissing by tapping outside
    builder: (context) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The modal dialog
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                    maxHeight: MediaQuery.of(context).size.height * 0.7, // Increased height for more content
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Service History",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),

                              // Scrollable content with dynamic height
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: serviceHistory.map((history) {
                                      // Format the date for display
                                      String formattedDate = "";
                                      if (history['created_at'] != null) {
                                        final DateTime createdDate = DateTime.parse(history['created_at']);
                                        formattedDate = 
                                            "${createdDate.month}/${createdDate.day}/${createdDate.year}, "
                                            "${createdDate.hour % 12 == 0 ? 12 : createdDate.hour % 12}:${createdDate.minute.toString().padLeft(2, '0')} ${createdDate.hour >= 12 ? 'PM' : 'AM'}";
                                      }
                                      
                                      // Capitalize status for display
                                      final String status = history['status'] != null
                                          ? history['status'].toString().substring(0, 1).toUpperCase() + 
                                            history['status'].toString().substring(1)
                                          : 'Unknown';
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Status and date header
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  status,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getStatusColor(history['status']),
                                                  ),
                                                ),
                                                Text(
                                                  formattedDate,
                                                  style: const TextStyle(
                                                    fontSize: 14, 
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            
                                            // Remarks
                                            if (history['remarks'] != null)
                                              Text(
                                                history['remarks'],
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                              
                                            // Technician info
                                            if (history['technician_name'] != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  "Technician: ${history['technician_name']}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            
                                            // Action taken
                                            if (history['action_name'] != null && history['action_name'].toString().isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Action Taken:",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      history['action_name'],
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                            // Problem encountered
                                            if (history['encountered_problem_name'] != null && history['encountered_problem_name'].toString().isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Problem Encountered:",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      history['encountered_problem_name'],
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            
                                            const Divider(height: 24), // Divider with spacing
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Fade Effect (Shows Scrollable Area with Rounded Corners)
                        if (serviceHistory.length > 2)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // The floating close button
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
                    child: const Icon(Icons.close,
                        color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Helper function to get color based on status
Color _getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'in-progress':
      return Colors.blue;
    case 'ongoing':
      return Colors.green;
    case 'paused':
      return Colors.red;
    case 'completed':
      return Colors.teal;
    default:
      return Colors.grey;
  }
}