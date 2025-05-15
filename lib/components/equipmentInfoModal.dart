import 'package:flutter/material.dart';

void showEquipmentInfoModal(
    BuildContext context, Map<String, String> equipmentInfo) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
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
                        maxWidth: MediaQuery.of(context).size.width *
                            0.85, // Set button width
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            const Text(
                              "Equipment Info",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),

                            // Scrollable content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Serial Number: ${equipmentInfo['serialNumber'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Accountable: ${equipmentInfo['accountable'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Division: ${equipmentInfo['division'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Date Acquired: ${equipmentInfo['dateAcquired'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),

                                // Item Description
                                const Text(
                                  "Item Description:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  equipmentInfo['description'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // The floating close button with the new design
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
    },
  );
}
