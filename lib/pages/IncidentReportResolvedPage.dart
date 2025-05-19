import 'package:flutter/material.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/api_service/incident_report_service.dart';
import 'package:servicetracker_app/components/request/ButtonRequestModal.dart';
import 'package:servicetracker_app/components/request/PickRequestModal.dart';

class IncidentReportResolvedPage extends StatefulWidget {
  final String incidentNumber;
  final bool isResolved;
  final String incidentName;

  const IncidentReportResolvedPage({
    Key? key,
    required this.incidentNumber,
    this.isResolved = false,
    required this.incidentName,
  }) : super(key: key);

  @override
  State<IncidentReportResolvedPage> createState() =>
      _IncidentReportResolvedPageState();
}

class _IncidentReportResolvedPageState
    extends State<IncidentReportResolvedPage> {
  late TextEditingController findingsController;
  late TextEditingController recommendationController;

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    findingsController = TextEditingController(text: '');
    recommendationController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    findingsController.dispose();
    recommendationController.dispose();
    super.dispose();
  }

  void _showResolveConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CustomModalPickRequest(
        title: "MARK AS RESOLVED",
        message:
            "Are you sure you want to mark this incident as resolved? This action cannot be undone.",
        onConfirm: () async {
          Navigator.pop(dialogContext); // Close confirmation
          _submit();
        },
      ),
    );
  }

  Future<void> _showSuccessModal(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: CustomModalButtonRequest(
                  title: "Incident Resolved Successfully",
                  message: message,
                  onConfirm: () {
                    Navigator.pop(context); // Close the dialog first
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => route.settings.name == '/',
                    );
                    Navigator.pushNamed(context, '/IncidentReports');
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the dialog first
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => route.settings.name == '/',
                );
                Navigator.pushNamed(context, '/IncidentReports');
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
                child: const Icon(Icons.close, color: Colors.black, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    setState(() {
      _autoValidate = true;
    });
    if (_formKey.currentState?.validate() ?? false) {
      final service = IncidentReportService();
      try {
        final result = await service.resolveIncident(
          id: int.tryParse(widget.incidentNumber) ?? 0,
          findings: findingsController.text.trim(),
          recommendations: recommendationController.text.trim(),
        );
        await _showSuccessModal(
            result['data']?['message'] ?? 'Incident marked as resolved!');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.incidentName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Findings and Recommendation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                // Findings Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: buildTextField(
                    'Findings',
                    findingsController,
                    maxLines: 6,
                    readOnly: widget.isResolved,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Findings is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Recommendation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: buildTextField(
                    'Recommendation',
                    recommendationController,
                    maxLines: 6,
                    readOnly: widget.isResolved,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Recommendation is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.isResolved ? Colors.grey : Colors.green[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed:
                        widget.isResolved ? null : _showResolveConfirmation,
                    child: Text(
                      widget.isResolved
                          ? 'ALREADY RESOLVED'
                          : 'MARK AS RESOLVED',
                      style: const TextStyle(
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
      ),
    );
  }
}
