import 'package:flutter/material.dart';

void showRequestDetailsModal(BuildContext context, Map<String, dynamic> requestData) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF14213D),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'i',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                requestData["ticket"]?['ticket_full'] ?? "Request Details",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _buildDetailItem("Subject of request", requestData["request_title"] ?? "Not specified"),
                          _buildDetailItem("Description", requestData["request_description"] ?? "Not specified"),
                          _buildDetailItem("Date Requested", _formatDate(requestData["created_at"] ?? "")),
                          _buildDetailItem("Requested Date of Completion", _formatDate(requestData["request_completion"] ?? "")),
                          _buildDetailItem("Actual Date of Completion", _formatDate(requestData["completion_date"] ?? "")),
                          _buildDetailItem("Location", requestData["location"] ?? "Not specified"),
                          _buildDetailItem("Contact Details", requestData["local_no"] ?? "Not specified"),
                          _buildDetailItem("Service Category", requestData["category"]?["category_name"] ?? "Not specified"),
                          _buildDetailItem("Subcategory", requestData["subCategory"]?["sub_category_name"] ?? "Not specified"),
                          _buildDetailItem("Requester", requestData["requester"]?["name"] ?? "Not specified"),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildDetailItem(String label, dynamic value) {
  String displayValue = value?.toString() ?? "Not specified";

  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: RichText(
      text: TextSpan(
        text: "$label: ",
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        children: [
          TextSpan(
            text: displayValue,
            style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}
  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return "${_monthName(date.month)} ${date.day}, ${date.year}, ${_formatTime(date)}";
    } catch (_) {
      return "Invalid Date";
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final suffix = date.hour >= 12 ? "PM" : "AM";
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $suffix";
  }