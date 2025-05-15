import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:servicetracker_app/api_service/client_message_service.dart';
import 'package:servicetracker_app/auth/sessionmanager.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/components/messageSentModal.dart';
import 'package:servicetracker_app/components/request/ButtonRequestModal.dart';

class MessageClient extends StatefulWidget {
  final Map<String, dynamic>? serviceData;

  const MessageClient({
    Key? key,
    this.serviceData,
  }) : super(key: key);

  @override
  _MessageClientState createState() => _MessageClientState();
}

class _MessageClientState extends State<MessageClient> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ClientMessageService _messageService = ClientMessageService();

  @override
  void initState() {
    super.initState();

    // Set requesterName as the label but requesterId as the actual value
    if (widget.serviceData != null) {
      String requesterName =
          widget.serviceData!['requester_name']?.toString() ?? 'Client';
      _recipientController.text = requesterName;
    }

    // Pre-fill the subject with request title if available
    if (widget.serviceData != null) {
      String requestTitle =
          widget.serviceData!['request_title']?.toString() ?? '';

      if (requestTitle.isNotEmpty) {
        _subjectController.text = requestTitle;
      } else {
        // Fall back to ticket number if no title is available
        final ticketData = widget.serviceData!['ticket'];
        String ticket = '';

        if (ticketData is Map<String, dynamic> &&
            ticketData.containsKey('ticket_full')) {
          ticket = ticketData['ticket_full'] ?? '';
        } else if (ticketData is String) {
          ticket = ticketData;
        }

        if (ticket.isNotEmpty) {
          _subjectController.text = ticket;
        }
      }
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
  if (_formKey.currentState!.validate()) {
    // Extract service request ID from the service data
    String serviceRequestId = '';
    String ticketNumber = '';
    String requesterId = '';
    String requesterName = '';
    final SessionManager session = SessionManager();
    final user = await session.getUser();
    final int technicianId = user?['id'];
    
    if (widget.serviceData != null) {
      // Get service request ID
      serviceRequestId = widget.serviceData!['id']?.toString() ?? '';

      // Get requester ID and name
      requesterId = widget.serviceData!['requesterId']?.toString() ?? '';
      requesterName = widget.serviceData!['requester_name']?.toString() ?? '';

      // Get ticket number
      final ticketData = widget.serviceData!['ticket'];
      if (ticketData is Map<String, dynamic> &&
          ticketData.containsKey('ticket_full')) {
        ticketNumber = ticketData['ticket_full'] ?? '';
      } else if (ticketData is String) {
        ticketNumber = ticketData;
      }
    }

    // If no service request ID found, show error
    if (serviceRequestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Missing service request ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Print the data that will be sent to the API
    print('===== MESSAGE CLIENT REQUEST DATA =====');
    print('Recipient ID: ${_recipientController.text.trim()}');
    print('Service Request ID: $serviceRequestId');
    print('Subject: ${_subjectController.text.trim()}');
    print('Message: ${_descriptionController.text.trim()}');
    print('Ticket Number: $ticketNumber');
    print('Requester ID: $requesterId');
    print('Requester Name: $requesterName');
    print('Technician ID: $technicianId');
    print('======================================');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF45CF7F)),
          ),
        );
      },
    );

    try {
      // Send message using the API service
      final result = await _messageService.sendMessageToClient(
        recipientId: requesterId, // Use requesterId directly instead of text field value
        serviceRequestId: serviceRequestId,
        subject: _subjectController.text.trim(),
        message: _descriptionController.text.trim(),
        ticketNumber: ticketNumber,
        technicianId: technicianId,
      );

      // Print the response from the API
      print('===== MESSAGE CLIENT API RESPONSE =====');
      print('Success: ${result['success']}');
      print('Message: ${result['message']}');
      print('========================================');

      // Close loading dialog
      Navigator.pop(context);

      if (result['success']) {
        // Show success message and wait for user to dismiss it
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main dialog content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    child: CustomMessageSentModal(
                      title: "Message Sent",
                      message: "Your message has been sent to the client",
                      onConfirm: () {
                        Navigator.pop(context); // Close dialog only
                      },
                    ),
                  ),
                ),

                // The floating close button
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close dialog only
                  },
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
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        
        // After dialog is closed, navigate back to previous screen
        Navigator.pop(context); // Return to the previous screen
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Print any errors
      print('===== MESSAGE CLIENT ERROR =====');
      print('Error: $e');
      print('==============================');

      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.height * 0.22
              : MediaQuery.of(context).size.height * 0.13,
          showFooter: false,
          backgroundColor: const Color(0xFF14213D),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),

                // Title with responsive sizing
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Message Client",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipient input field
                        // Recipient input field - shows requesterName but uses requesterId
                        buildTextField(
                          "Recipient",
                          _recipientController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Recipient cannot be empty';
                            }
                            return null;
                          },
                          readOnly: true, // Make this field non-editable
                        ),

                        const SizedBox(height: 16),

                        buildTextField(
                          "Subject",
                          _subjectController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a subject';
                            }
                            return null;
                          },
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),

                        // Description input field
                        buildTextField(
                          "Description",
                          _descriptionController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a message';
                            }
                            return null;
                          },
                          maxLines: 10,
                          autofocus: true,
                        ),

                        const SizedBox(height: 16),

                        // Info box
                        // Container(
                        //   width: double.infinity,
                        //   padding: const EdgeInsets.all(12),
                        //   decoration: BoxDecoration(
                        //     color: Colors.blue.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(8),
                        //     border:
                        //         Border.all(color: Colors.blue.withOpacity(0.3)),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           Icon(Icons.info_outline,
                        //               color: Colors.blue, size: 20),
                        //           SizedBox(width: 8),
                        //           Expanded(
                        //             child: Text(
                        //               "Message information",
                        //               style: TextStyle(
                        //                 fontSize: 14,
                        //                 color: Colors.blue[800],
                        //                 fontWeight: FontWeight.bold,
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       SizedBox(height: 8),
                        //       Text(
                        //         "• This message will be sent directly to the client via email.",
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           color: Colors.blue[800],
                        //         ),
                        //       ),
                        //       SizedBox(height: 4),
                        //       Text(
                        //         "• Please ensure the recipient information is correct.",
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           color: Colors.blue[800],
                        //         ),
                        //       ),
                        //       SizedBox(height: 4),
                        //       Text(
                        //         "• The service request ID and ticket number will be attached automatically.",
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           color: Colors.blue[800],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        const SizedBox(height: 16),

                        // Send Message Button
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: ElevatedButton(
                            onPressed: _sendMessage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF45CF7F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 2, // Add shadow
                            ),
                            child: const Text(
                              "MESSAGE CLIENT",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
