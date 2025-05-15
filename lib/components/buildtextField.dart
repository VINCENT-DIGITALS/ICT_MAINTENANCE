import 'package:flutter/material.dart';

Widget buildTextField(
  String label,
  TextEditingController controller, {
  FormFieldValidator<String>? validator,
  int maxLines = 1, // Add this line
  bool readOnly = false, // Add readOnly parameter with default value of false
  Widget? prefixIcon, // Add support for prefix icon
  Widget? suffixIcon, // Add support for suffix icon
  bool autofocus = false,
}) {
  return FormField<String>(
    initialValue: controller.text,
    validator: validator,
    autovalidateMode: AutovalidateMode
        .onUserInteraction, // ✅ Automatically validate when typing
    builder: (FormFieldState<String> fieldState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            
            controller: controller,
            maxLines: maxLines, // Add this
            readOnly: readOnly,
            autofocus: autofocus,
            textAlignVertical:
                TextAlignVertical.top, // ✅ Top vertical alignment
            textAlign: TextAlign.start, // ✅ Left horizontal alignment
            // For read-only fields, don't trigger validation
            validator: readOnly ? null : (value) => null,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              hintStyle: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              prefixIcon: prefixIcon, // Add prefix icon if provided
              suffixIcon: suffixIcon, // Add suffix icon if provided
              filled: readOnly, // Add light fill color if readOnly
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: fieldState.hasError
                      ? const Color(0xFFFF5963)
                      : Color(0xFFB0B0B0), // ✅ RED if error, BLACK if okay
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: fieldState.hasError
                      ? const Color(0xFFFF5963)
                      : Color(0xFFB0B0B0), // RED if error, GREEN if focus
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
              fieldState.didChange(
                  value); // ✅ Update form state so error disappears when typing
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
