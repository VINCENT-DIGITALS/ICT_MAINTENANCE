import 'package:flutter/material.dart';

class CustomModalSaveProgress extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const CustomModalSaveProgress({
    Key? key,
    required this.title,
    required this.message,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Circular Icon with new color
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF14213D), // Updated color
              ),
              child: const Icon(
                Icons.check,
                size: 90,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Title

            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                softWrap: true, // Allows text wrapping
                overflow: TextOverflow.visible, // Ensures visibility
              ),
            ),
            const SizedBox(height: 8),

            // ✅ Message
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
                softWrap: true, // Allows text wrapping
                overflow: TextOverflow.visible, // Ensures visibility
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Button with new color
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                  // onConfirm(); // Execute the confirm action
                  Navigator.pushReplacementNamed(context, '/ServiceDetails');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14213D), // Updated color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "VIEW SERVICE DETAILS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
