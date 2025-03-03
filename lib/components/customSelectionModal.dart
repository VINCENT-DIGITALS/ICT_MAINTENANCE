import 'package:flutter/material.dart';

void showCustomSelectionModal({
  required BuildContext context,
  required String title,
  required List<String> options,
  required List<String> selectedOptions,
  required Function(List<String>) onConfirm,
  bool isSingleSelect = false,
}) {
  List<String> tempSelected = List.from(selectedOptions);

  showDialog(
    context: context,
    barrierDismissible: true, // Dismiss when tapping outside
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 400,// MediaQuery.of(context).size.width * 0.85,
              height: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        String option = options[index];
                        bool isSelected = tempSelected.contains(option);

                        return CheckboxListTile(
                          title: Text(option),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (isSingleSelect) {
                                tempSelected = [
                                  option
                                ]; // Only one selection allowed
                              } else {
                                if (value == true) {
                                  tempSelected.add(option);
                                } else {
                                  tempSelected.remove(option);
                                }
                              }
                            });
                          },
                          activeColor: const Color(0xFF007A33),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                      /// **Confirm Button**
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ElevatedButton(
                      onPressed: () {
                        onConfirm(tempSelected);
                        Navigator.pop(context); // Close modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007A33),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "CONFIRM SELECTION",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
