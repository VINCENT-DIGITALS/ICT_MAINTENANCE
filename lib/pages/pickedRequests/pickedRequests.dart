import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:servicetracker_app/api_service/pendingRequest.dart';
import 'package:servicetracker_app/api_service/picked_request.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/components/equipmentInfoModal.dart';
import 'package:servicetracker_app/components/qrScanner.dart';
import 'package:servicetracker_app/components/request/PickRequestModal.dart';

class PickedRequests extends StatefulWidget {
  final String currentPage;

  const PickedRequests({Key? key, this.currentPage = 'PickedRequests'})
      : super(key: key);

  @override
  _PickedRequestsState createState() => _PickedRequestsState();
}

class _PickedRequestsState extends State<PickedRequests> {
  final ScrollController _scrollController = ScrollController();
  bool hasReports = true; // Change to false to test empty state
  List<Map<String, dynamic>> PickedRequests = [];

  String? selectedReportCategory;
  String? selectedPriorityCategory;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredRequests = [];
  final List<String> reportCategories = [
    "Computer & Peripheral Services",
    "Network Services",
    "Software Support",
    "Hardware Repair",
  ];

  final List<String> priorityCategories = [
    "Information Systems Divwwwwwwwwwwwwwwwwwwision",
    "HR Division",
    "Finance Division",
    "Operations Division",
  ];
  String? selectedDivision;
  String? selectedRequester;
  final DateTime _defaultFromDate = DateTime.now();
  final DateTime _defaultToDate = DateTime.now();
  DateTime? fromDate; // Nullable DateTime
  DateTime? toDate; // Nullable DateTime
  DateTime lastUpdated = DateTime.now();

  List<String> get allDivisions =>
      PickedRequests.map((r) => r['division'] as String).toSet().toList();

  List<String> get allRequesters =>
      PickedRequests.map((r) => r['requester'] as String).toSet().toList();
  get http => null;

  // ─── new filter state ─────────────────────────
  String? selectedCategory;
  String? selectedSubCategory;
  DateTimeRange? selectedDateRange;
  bool isAscending = true; // default sort A→Z
// put this at the top of your State class
  final DateFormat _dateFormat = DateFormat('MMMM d, y, hh:mm a');
  List<String> get allCategories =>
      PickedRequests.where((r) => r.containsKey('category'))
          .map((r) => r['category'] as String)
          .toSet()
          .toList();

  List<String> get allSubCategories =>
      PickedRequests.where((r) => r.containsKey('subCategory'))
          .map((r) => r['subCategory'] as String)
          .toSet()
          .toList();

  @override
  void initState() {
    super.initState();
    // fetchRepairsData();
    _fetchAndSetPickedRequests();
    searchController.addListener(_applyFilters);
  }

  Future<void> _fetchAndSetPickedRequests() async {
    try {
      final service = PickedRequestsService();
      final List<Map<String, dynamic>> response =
          await service.fetchPickedRequests();

      final List<Map<String, dynamic>> transformedRequests =
          response.map((request) {
        return {
          "title": "${request['ticket']?["ticket_full"] ?? "Unknown Ticket"}",
          "requester": request["requester_id"] ?? "Unknown Requester",
          "division": request["location"] ?? "Unknown Division",
          "requestedDate": _formatDate(request["created_at"]),
          "description": request["request_description"] ?? "",
          "category":
              request["category"]?["category_name"] ?? "Unknown Category",
          "subCategory": request["sub_category"]?["sub_category_name"] ??
              "Unknown Subcategory",
        };
      }).toList();

      setState(() {
        PickedRequests = transformedRequests;
        filteredRequests = List.from(PickedRequests);
      });
    } catch (e) {
      print("Error fetching pending requests: $e");
      // Optionally, show an error to the user
    }
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

  Future<void> fetchRepairsData() async {
    final response =
        await http.get(Uri.parse('https://your-api-url.com/repairs'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        PickedRequests =
            data['pickedRequests']; // Replace with actual API response key
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Global key for overlay entry
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// To track which radio button is selected
  String? sortBy = 'serviceRequest'; // default

// Radio Tile Helper
  Widget _buildRadioTile({
    required String title,
    required String value,
    required String? groupValue,
    required void Function(String?) onChanged,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      activeColor: Color(0xFF007A33),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Method to show a top pop-up notification
  void _showTopNotification(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 500),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // 3️⃣ Filtering logic
  void _applyFilters() {
    final q = searchController.text.toLowerCase();

    setState(() {
      // Step 1: filter
      filteredRequests = PickedRequests.where((r) {
        // 1️⃣ Search text match
        final title = (r['title'] as String).toLowerCase();
        final requester = (r['requester'] as String).toLowerCase();
        final division = (r['division'] as String).toLowerCase();
        final description = (r['description'] as String).toLowerCase();
        final dateString = (r['requestedDate'] as String);

        final matchesSearch = title.contains(q) ||
            requester.contains(q) ||
            division.contains(q) ||
            description.contains(q) ||
            dateString.toLowerCase().contains(q);

        // 2️⃣ Division
        final matchesDivision =
            selectedDivision == null || r['division'] == selectedDivision;

        // 3️⃣ Category & Sub‑Category
        final matchesCategory =
            selectedCategory == null || r['category'] == selectedCategory;
        final matchesSubCategory = selectedSubCategory == null ||
            r['subCategory'] == selectedSubCategory;

        // 4️⃣ Date range
        DateTime requestedDate;
        try {
          requestedDate = _dateFormat.parse(dateString);
        } catch (e) {
          // if parsing fails, exclude it
          return false;
        }

        // Only apply date filtering if fromDate and toDate are both set
        final inDateRange = (fromDate == null || toDate == null) ||
            (!requestedDate.isBefore(fromDate ?? DateTime(2000)) &&
                !requestedDate.isAfter(toDate ?? DateTime(2100)));

        return matchesSearch &&
            matchesDivision &&
            matchesCategory &&
            matchesSubCategory &&
            inDateRange;
      }).toList();

      // Step 2: sort
      filteredRequests.sort((a, b) {
        final aTitle = a['title'] as String;
        final bTitle = b['title'] as String;
        return isAscending
            ? aTitle.compareTo(bTitle)
            : bTitle.compareTo(aTitle);
      });
    });
  }

// stub for when you tap the filter button
  void _onFilterPressed() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              // 👈 SCROLL ENTIRE BODY
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modal
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    constraints: BoxConstraints(
                      maxWidth:
                          500, // Optional: limit max width for large screens
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14213D),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Date Range Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Date Range',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DatePickerCard(
                                label: 'From',
                                date: fromDate ?? DateTime.now(),
                                onTap: () => _pickDate(context, true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DatePickerCard(
                                label: 'To',
                                date: toDate ?? DateTime.now(),
                                onTap: () => _pickDate(context, false),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Service Category Dropdown
                        _buildDropdownField(
                          label: 'Service Category',
                          value: selectedCategory,
                          hint: 'Select Service Category',
                          items: allCategories,
                          onChanged: (v) =>
                              setState(() => selectedCategory = v),
                        ),

                        // Location Dropdown
                        _buildDropdownField(
                          label: 'Location',
                          value: selectedDivision,
                          hint: 'Select Location',
                          items: allDivisions,
                          onChanged: (v) =>
                              setState(() => selectedDivision = v),
                        ),

                        const SizedBox(height: 24),

                        // Sort by Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sort by',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            _buildRadioTile(
                              title: 'Service Request No.',
                              value: 'serviceRequest',
                              groupValue: sortBy,
                              onChanged: (val) => setState(() => sortBy = val),
                            ),
                            _buildRadioTile(
                              title: 'Date Requested',
                              value: 'dateRequested',
                              groupValue: sortBy,
                              onChanged: (val) => setState(() => sortBy = val),
                            ),
                            _buildRadioTile(
                              title: 'Date Updated',
                              value: 'dateUpdated',
                              groupValue: sortBy,
                              onChanged: (val) => setState(() => sortBy = val),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Apply Filter Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              selectedDateRange = DateTimeRange(
                                start: fromDate ?? DateTime.now(),
                                end: toDate ?? DateTime.now(),
                              );
                              _applyFilters();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF007A33),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'APPLY FILTER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Close Button (floating below)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isFrom ? fromDate ?? DateTime.now() : toDate ?? DateTime.now(),
      firstDate: isFrom ? DateTime(2000) : fromDate ?? DateTime(2000),
      lastDate: isFrom ? toDate ?? DateTime(2100) : DateTime(2100),
      helpText: isFrom ? 'Select Start Date' : 'Select End Date',
      fieldHintText: 'dd/MM/yyyy', // for manual typing
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF007A33), // ← your custom green
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          // If fromDate is set, ensure toDate is set too
          if (toDate == null) {
            // Optionally show an alert or do something else here to notify the user
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Date Required'),
                  content: Text('Please select the end date.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          toDate = picked;
          // If toDate is set, ensure fromDate is set too
          if (fromDate == null) {
            // Optionally show an alert or do something else here to notify the user
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Date Required'),
                  content: Text('Please select the start date.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }

        // Auto adjust the other date if one is earlier
        if (fromDate != null && toDate != null) {
          if (fromDate!.isAfter(toDate!)) {
            toDate = fromDate; // auto adjust
          } else if (toDate!.isBefore(fromDate!)) {
            fromDate = toDate; // auto adjust
          }
        }
      });
    }
  }

// Helper for dropdown UI
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Builder(
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: items.contains(value) ? value : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              hint: Text(hint),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All'),
                ),
                ...items.map((i) => DropdownMenuItem<String>(
                      value: i,
                      child: Text(i),
                    )),
              ],
              onChanged: onChanged,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> refreshDashboardData() async {
    setState(() {
      _fetchAndSetPickedRequests();
      searchController.addListener(_applyFilters);
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),

              /// ✅ Title expands but still constrained for overflow in landscape
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Picked Requests',
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

      /// 🔥 Main Layout with Fixed Bottom Buttons
      body: RefreshIndicator(
        onRefresh: refreshDashboardData, // Your refresh function
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Forces pull even when not scrollable
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          children: [
            const SizedBox(height: 15),

            /// 🔍 Search & Filter
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF707070)),
                            ),
                          ),
                          const Icon(Icons.search, color: Color(0xFF14213D)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14213D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_alt, color: Colors.white),
                      onPressed: _onFilterPressed,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ℹ️ Last Updated Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    "Showing all ${filteredRequests.length} entries.",
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "Last Updated: ${DateFormat('MMMM dd, yyyy, hh:mm a').format(lastUpdated.toLocal())}",
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// 📦 Content Area (list or empty state)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  children: [
                    filteredRequests.isEmpty
                        ? _buildEmptyPickedState(context)
                        : _buildPendingRequest(context, filteredRequests),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  /// 🛠 Builds a list of Ongoing Repairs (Replace with your real data)
  Widget _buildPendingRequest(BuildContext context, List<dynamic> requests) {
    return Column(
      children: requests.map((request) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding:
                const EdgeInsets.fromLTRB(16, 12, 16, 16), // Tight top space
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(10),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.05),
              //     blurRadius: 5,
              //     offset: const Offset(0, 2),
              //   ),
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top row: title + custom styled info circle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        request['title'] ?? 'ACR-XXXX-XX-XX',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // The modal dialog
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 500,
                                            ),
                                            child: RequestDetailsModal(
                                                request: request,
                                                buildButton: _buildButton),
                                          ),
                                          const SizedBox(height: 12),
                                          // The floating close button
                                          GestureDetector(
                                            onTap: () =>
                                                Navigator.of(context).pop(),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(Icons.close,
                                                  color: Colors.black,
                                                  size: 24),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14213D), // Dark blue circle
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
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "Subject of request",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),

                Text(
                  "Description: ${request['description'] ?? 'No description'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Date Requested:  ${request['requestedDate'] ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF707070),
                    height: 1.0,
                  ),
                ),
                Text(
                  "Requested Date of Completion: ${request['requestedDate'] ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF707070),
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 20),

                _buildButton(
                  context,
                  "PICK THIS REQUEST",
                  const Color(0xFF007A33),
                  () {
                    // Add action here
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CustomModalPickRequest(
              title: "Request Added to Your Services",
              message:
                  "Complete the details to add this to your ongoing services",
              onConfirm: () {
                Navigator.pop(context);
                onPressed();
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          "PICK THIS REQUEST",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  /// 🛠 Shows Empty State when there are no Ongoing Repairs
  Widget _buildEmptyPickedState(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85, // 90% of screen width

      padding: const EdgeInsets.fromLTRB(
          20, 5, 20, 5), // Adds spacing inside the container
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light gray background
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers content vertically
        children: const [
          // SizedBox(height: 5),
          Text(
            "Select Incident Report to get started.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RequestDetailsModal extends StatelessWidget {
  final Map<String, dynamic> request;
  final Widget Function(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) buildButton;

  const RequestDetailsModal({
    super.key,
    required this.request,
    required this.buildButton,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500, // ✅ Max width of the modal
          ),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFF14213D)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request['title'] ?? 'ACR-XXXX-XX-XX',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Subject of request",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                      fontSize: 14,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    "Description: ${request['description'] ?? 'No description available'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Date Requested: ${request['requestedDate'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  Text(
                    "Requested Date of Completion: ${request['completionDate'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Location: ${request['location'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  Text(
                    "Contact Details: ${request['contact'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Service Category: ${request['category'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  Text(
                    "Subcategory: ${request['subcategory'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Requester: ${request['requester'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  Text(
                    "Actual Client: ${request['client'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black, height: 1.3),
                  ),
                  const SizedBox(height: 20),
                  buildButton(
                    context,
                    "PICK THIS REQUEST",
                    const Color(0xFF007A33),
                    () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext c) {
    return SizedBox(
      height: 48, // reduce overall height here
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4), // less padding
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // center vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10, // smaller
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(date),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: Colors.black,
                size: 20, // smaller icon
              ),
            ],
          ),
        ),
      ),
    );
  }
}
