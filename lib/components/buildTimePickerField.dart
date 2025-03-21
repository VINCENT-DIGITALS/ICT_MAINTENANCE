import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildTimePickerField(
  BuildContext context,
  String label,
  TimeOfDay? selectedTime,
  Function(TimeOfDay) onSelect, {
  FormFieldValidator<String>? validator, // Optional validator
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FormField<String>(
        validator: validator,
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();

                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), // Use 12-hour format
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        onSelect(picked);
                        // Notify validator with formatted time string
                        state.didChange(picked.format(context));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedTime != null
                                  ? selectedTime.format(context) // Display formatted time
                                  : label,
                              style: const TextStyle(fontSize: 18, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Icon(Icons.access_time, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  if (selectedTime != null)
                    Positioned(
                      top: -10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        color: Colors.white,
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 12),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}
