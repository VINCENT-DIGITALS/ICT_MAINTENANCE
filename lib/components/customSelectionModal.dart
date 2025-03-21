import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

void showCustomSelectionModal({
  required BuildContext context,
  required String title,
  required List<String> options,
  required List<String> selectedOptions,
  required Function(List<String>) onConfirm,
  bool isSingleSelect = false,
  String fixedTechnician = '',
}) {
  List<String> tempSelected = List.from(selectedOptions);
  

  // Ensure fixed technician is always in the tempSelected list
  if (!tempSelected.contains(fixedTechnician)) {
    tempSelected.add(fixedTechnician);
  }

  showDialog(
    context: context,
    barrierDismissible: true, // ✅ Dismiss when tapping outside
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 400, // MediaQuery.of(context).size.width * 0.85,
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

                        // Disable interaction for fixed technician
                        bool isDisabled = option == fixedTechnician;

                        return isSingleSelect
                            ? RadioListTile<String>(
                                title: AutoSizeText(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDisabled
                                        ? Colors.grey
                                        : Colors.black, // Gray if fixed
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 5,
                                  minFontSize: 7,
                                ),
                                value: option,
                                groupValue: tempSelected.isNotEmpty
                                    ? tempSelected.first
                                    : null,
                                onChanged: isDisabled
                                    ? null // Disable tap
                                    : (String? value) {
                                        setModalState(() {
                                          tempSelected = [value!];
                                          // Ensure fixed technician stays selected
                                          if (!tempSelected
                                              .contains(fixedTechnician)) {
                                            tempSelected.add(fixedTechnician);
                                          }
                                        });
                                      },
                                activeColor: const Color(0xFF007A33),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              )
                            : CheckboxListTile(
                                title: AutoSizeText(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDisabled
                                        ? Colors.grey
                                        : Colors.black, // Gray if fixed
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 5,
                                  minFontSize: 7,
                                ),
                                value: isSelected,
                                onChanged: isDisabled
                                    ? null // Disable tap
                                    : (bool? value) {
                                        setModalState(() {
                                          if (value == true) {
                                            tempSelected.add(option);
                                          } else {
                                            tempSelected.remove(option);
                                          }
                                          // Ensure fixed technician stays selected
                                          if (!tempSelected
                                              .contains(fixedTechnician)) {
                                            tempSelected.add(fixedTechnician);
                                          }
                                        });
                                      },
                                activeColor: const Color(0xFF007A33),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                      },
                    ),
                  ),

                  /// **Confirm Button**
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ElevatedButton(
                      onPressed: () {
                        // Ensure fixed technician is in the final list
                        if (!tempSelected.contains(fixedTechnician)) {
                          tempSelected.add(fixedTechnician);
                        }
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
                      child: const AutoSizeText(
                        "CONFIRM SELECTION",
                        style: TextStyle(
                          fontSize: 18, // Max font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center, // ✅ Keep text centered
                        maxLines: 1, // ✅ Ensures it stays in one line
                        minFontSize: 10, // ✅ Auto shrinks when needed
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
