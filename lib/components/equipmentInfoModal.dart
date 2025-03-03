import 'package:flutter/material.dart';

void showEquipmentInfoModal(
    BuildContext context, Map<String, String> equipmentInfo) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Dialog Container
              Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 400,//MediaQuery.of(context).size.width * 0.85,
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Padding(
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
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating close button slightly below the modal
              Positioned(
                bottom: 30, // Pushes the button a bit below the modal
                child: SizedBox(
                  width: 40, // Adjust width
                  height: 40, // Adjust height
                  child: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: const Icon(Icons.close,
                        color: Colors.black, size: 24), // Adjust icon size
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
