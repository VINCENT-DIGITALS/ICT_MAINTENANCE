import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';

Widget buildDropdownField(BuildContext context, String label, String? value,
    List<String> options, Function(String) onSelect) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              showCustomSelectionModal(
                context: context,
                title: label, // Use label as the modal title
                options: options,
                selectedOptions: value != null ? [value] : [],
                onConfirm: (List<String> selected) {
                  if (selected.isNotEmpty) {
                    onSelect(selected.first); // Select the first chosen item
                  }
                },
                isSingleSelect: true, // Ensure only one selection is allowed
              );
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
                      value ?? label,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      overflow: TextOverflow.ellipsis, // Prevents text from overflowing
                      maxLines: 1, // Ensures single-line display
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          // ✅ Show label if value is null
          if (value != null)
            Positioned(
              top: -10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Colors.white,
                child: Text(
                  label, // ✅ Use actual label
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 15),
    ],
  );
}
