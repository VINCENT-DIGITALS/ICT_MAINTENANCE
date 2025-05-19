import 'package:flutter/material.dart';

class CustomAddRequestModal extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const CustomAddRequestModal({
    Key? key,
    required this.title,
    required this.message,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400, // Set max width (adjust as needed)
        ),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ✅ Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

           ],
          ),
        ),
      ),
    );
  }
}
