import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the selected date

Widget buildDatePickerField(
  BuildContext context,
  String label,
  DateTime? selectedDate,
  Function(DateTime) onSelect, {
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
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        onSelect(picked);
                        state.didChange(DateFormat('yyyy-MM-dd').format(picked)); // Notify validator
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
                              selectedDate != null
                                  ? DateFormat('yyyy-MM-dd').format(selectedDate)
                                  : label,
                              style: const TextStyle(fontSize: 18, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  if (selectedDate != null)
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
