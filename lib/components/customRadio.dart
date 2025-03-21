import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final AutoSizeGroup textGroup; // ✅ Added AutoSizeGroup

  const CustomRadioButton({
    Key? key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.textGroup, // ✅ Receive AutoSizeGroup
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🟢 **Custom Circle for Radio**
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF007A33) : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF007A33),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),

            /// **Label Text (AutoSize with Group)**
            Expanded(
              child: AutoSizeText(
                label,
                style: const TextStyle(
                  fontSize: 16, // Max font size
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                group: textGroup, // ✅ Ensures uniform shrinking
                textAlign: TextAlign.left,
                maxLines: 2,
                minFontSize: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
