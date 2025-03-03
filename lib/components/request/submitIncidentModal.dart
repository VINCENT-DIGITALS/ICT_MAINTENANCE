import 'package:flutter/material.dart';

class CustomModalIncidentModal extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;

  const CustomModalIncidentModal({
    Key? key,
    required this.title,
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
                  color: Colors.black,
                  height: 1
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 20),

              // ✅ Button with new color
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                    Navigator.pushReplacementNamed(
                        context, '/IncidentReportDetails');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14213D), // Updated color
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "BACK TO INCIDENT REPORT",
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
      ),
    );
  }
}
