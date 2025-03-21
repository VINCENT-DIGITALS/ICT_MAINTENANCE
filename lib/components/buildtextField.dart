import 'package:flutter/material.dart';

Widget buildTextField(
  String label,
  TextEditingController controller, {
  FormFieldValidator<String>? validator,
}) {
  return FormField<String>(
    validator: validator,
    autovalidateMode: AutovalidateMode.onUserInteraction, // ✅ Automatically validate when typing
    builder: (FormFieldState<String> fieldState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.black,
                fontSize: 18,
              ),
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.black,
                fontSize: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: fieldState.hasError ? const Color(0xFFFF5963) : Colors.black, // ✅ RED if error, BLACK if okay
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: fieldState.hasError ? const Color(0xFFFF5963) : const Color(0xFF018203), // RED if error, GREEN if focus
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFFF5963),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFFF5963),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              fieldState.didChange(value); // ✅ Update form state so error disappears when typing
            },
          ),
          if (fieldState.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 5),
              child: Text(
                fieldState.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
        ],
      );
    },
  );
}
