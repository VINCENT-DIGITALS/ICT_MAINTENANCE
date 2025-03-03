import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const CustomRadioButton({
    Key? key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value), // Handle selection
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 3), // Adjust spacing
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🟢 **Custom Circle for Radio**
            Container(
              width: 18, // Custom size
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? Color(0xFF007A33) : Colors.grey, // Active color
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF007A33) // Filled when selected
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8), // Adjust spacing between radio and text

            /// **Label Text**
            Text(
              label,
              style: TextStyle(
                fontSize: 16, // Adjust text size
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
