import 'package:flutter/material.dart';

void showServiceHistoryModal(
    BuildContext context, List<Map<String, String>> serviceHistory) {
  showDialog(
    context: context,
    barrierDismissible: true, // Allows dismissing by tapping outside
    builder: (context) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded edges
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400, //MediaQuery.of(context).size.width * 0.85, // Max width
                maxHeight:
                    MediaQuery.of(context).size.height * 0.6, // Max height
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Shrinks if data is less
                      children: [
                        // Title
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
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        history['title'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Request Date: ${history['requestDate']}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        "Completion Date: ${history['completionDate']}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        "Technician: ${history['technician']}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const Divider(), // Divider for separation
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

                  /// 🔥 Overlay Fade Effect (Shows Scrollable Area with Rounded Corners)
                  if (serviceHistory.length > 2)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ), // Ensures rounded edges
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
}
