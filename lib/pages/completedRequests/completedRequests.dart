import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:servicetracker_app/api_service/completed_request.dart';
import 'package:servicetracker_app/api_service/ongoing_request.dart';
import 'package:servicetracker_app/api_service/pendingRequest.dart';
import 'package:servicetracker_app/api_service/picked_request.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/components/equipmentInfoModal.dart';
import 'package:servicetracker_app/components/qrScanner.dart';
import 'package:servicetracker_app/components/request/PickRequestModal.dart';

import '../../auth/sessionmanager.dart';

class CompletedRequests extends StatefulWidget {
  final String currentPage;

  const CompletedRequests({Key? key, this.currentPage = 'CompletedRequests'})
      : super(key: key);

  @override
  _CompletedRequestsState createState() => _CompletedRequestsState();
}

class _CompletedRequestsState extends State<CompletedRequests> {
  final ScrollController _scrollController = ScrollController();
  bool hasReports = true; // Change to false to test empty state

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

  // ─── new filter state ─────────────────────────
  String? selectedCategory;
  String? selectedSubCategory;
  DateTimeRange? selectedDateRange;
  bool isAscending = true; // default sort A→Z
// put this at the top of your State class
  final DateFormat _dateFormat = DateFormat('MMMM d, y, hh:mm a');
// Replace these getters with these updated versions
  List<String> get allDivisions {
    List<Map<String, dynamic>> sourceList =
        isPausedSelected ? pausedRequests : ongoingRequests;
    return sourceList.map((r) => r['division'] as String).toSet().toList();
  }

  List<String> get allRequesters {
    List<Map<String, dynamic>> sourceList =
        isPausedSelected ? pausedRequests : ongoingRequests;
    return sourceList.map((r) => r['requester'] as String).toSet().toList();
  }

  List<String> get allCategories {
    List<Map<String, dynamic>> sourceList =
        isPausedSelected ? pausedRequests : ongoingRequests;
    return sourceList
        .where((r) => r.containsKey('category'))
        .map((r) => r['category'] as String)
        .toSet()
        .toList();
  }

  List<String> get allSubCategories {
    List<Map<String, dynamic>> sourceList =
        isPausedSelected ? pausedRequests : ongoingRequests;
    return sourceList
        .where((r) => r.containsKey('subCategory'))
        .map((r) => r['subCategory'] as String)
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> pausedRequests = [];
  List<Map<String, dynamic>> ongoingRequests = [];
  bool isPausedSelected = false;
  // Add these new filtered lists to your state class
  List<String> filteredCategories = [];
  List<String> filteredDivisions = [];

  @override
  void initState() {
    super.initState();
    // fetchRepairsData();
    _fetchAndSetOngoingRequests().then((_) {
      // Initialize filteredRequests based on the default tab
      setState(() {
        filteredRequests = isPausedSelected
            ? List.from(pausedRequests)
            : List.from(ongoingRequests);

        // Initialize filtered lists
        filteredCategories = allCategories;
        filteredDivisions = allDivisions;
      });
    });
    searchController.addListener(_applyFilters);
  }

  Future<void> _fetchAndSetOngoingRequests() async {
    try {
      final session = SessionManager();
      final user = await session.getUser();
      final philriceId = user?['philrice_id'];

      if (philriceId == null) {
        print('No philrice_id found in session.');
        return;
      }

      final service = CompletedRequestService();
      final data = await service.fetchCompletedRequests();

      final ongoingRaw = data['ongoingRequests'];
      final pausedRaw = data['pausedRequests'];

      final ongoingFiltered =
          ongoingRaw.where((r) => r['technician_id'] == philriceId).toList();
      final pausedFiltered =
          pausedRaw.where((r) => r['technician_id'] == philriceId).toList();

      final ongoingTransformed = _transformRequests(ongoingFiltered);
      final pausedTransformed = _transformRequests(pausedFiltered);

      print("=== Ongoing Requests (${ongoingTransformed.length}) ===");
      for (var req in ongoingTransformed) {
        print(req);
      }

      print("=== Paused Requests (${pausedTransformed.length}) ===");
      for (var req in pausedTransformed) {
        print(req);
      }

      setState(() {
        ongoingRequests = ongoingTransformed;
        pausedRequests = pausedTransformed;

        // Initialize filteredRequests based on current tab selection
        filteredRequests = isPausedSelected
            ? List.from(pausedRequests)
            : List.from(ongoingRequests);

        // Apply any current filters
        _applyFilters();
      });
    } catch (e) {
      print("Error fetching or filtering picked requests: $e");
    }
  }

  List<Map<String, dynamic>> _transformRequests(List<dynamic> rawList) {
    return rawList.map((request) {
      return {
        "title": request['ticket']?["ticket_full"] ?? "Unknown Ticket",
        "requester": request["requester"]?["name"] ?? "Unknown Requester",
        "division": request["location"] ?? "Unknown Division",
        "requestedDate": _formatDate(request["created_at"]),
        "updatedDate": _formatDate(request["updated_at"]),
        "description": request["request_description"] ?? "",
        "category": request["category"]?["category_name"] ?? "Unknown Category",
        "subCategory": request["sub_category"]?["sub_category_name"] ??
            "Unknown Subcategory",
        "contact": request["local_no"] ?? "Unknown Contact",
        "pickedBy": request["technician_name"] ?? "Unknown Picker",
      };
    }).toList();
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
      dense: true, // This already reduces space around the Radio button
      contentPadding: EdgeInsets.symmetric(
          horizontal: 0, vertical: 0), // Remove padding completely
    );
  }

  void _sortFilteredRequests() {
    if (sortBy == 'serviceRequest') {
      filteredRequests.sort((a, b) =>
          a['title']?.toString().compareTo(b['title']?.toString() ?? '') ?? 0);
    } else if (sortBy == 'dateRequested') {
      filteredRequests.sort((a, b) =>
          a['requestedDate']
              ?.toString()
              .compareTo(b['requestedDate']?.toString() ?? '') ??
          0);
    } else if (sortBy == 'dateUpdated') {
      // If you have a 'dateUpdated' field, sort by it.
      // Otherwise, skip or handle gracefully
      filteredRequests.sort((a, b) =>
          a['updatedDate']
              ?.toString()
              .compareTo(b['updatedDate']?.toString() ?? '') ??
          0);
    }
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

// Create a method to filter dropdown options
  void _filterDropdownOptions(String? category, String? division) {
    List<Map<String, dynamic>> sourceList =
        isPausedSelected ? pausedRequests : ongoingRequests;

    // If both are null, show all options
    if (category == null && division == null) {
      filteredCategories = allCategories;
      filteredDivisions = allDivisions;
      return;
    }

    // Filter divisions based on selected category
    if (category != null) {
      filteredDivisions = sourceList
          .where((r) => r['category'] == category)
          .map((r) => r['division'] as String)
          .toSet()
          .toList();
    }

    // Filter categories based on selected division
    if (division != null) {
      filteredCategories = sourceList
          .where((r) => r['division'] == division)
          .map((r) => r['category'] as String)
          .toSet()
          .toList();
    }
  }

  // 3️⃣ Filtering logic
  void _applyFilters() {
    final q = searchController.text.toLowerCase();

    setState(() {
      // Select the correct source list based on current tab
      List<Map<String, dynamic>> sourceList =
          isPausedSelected ? pausedRequests : ongoingRequests;

      // Step 1: Filter
      filteredRequests = sourceList.where((r) {
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
          // If parsing fails, exclude it
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

      // Step 2: Sort
      filteredRequests.sort((a, b) {
        dynamic aVal;
        dynamic bVal;

        switch (sortBy) {
          case 'serviceRequest':
            aVal = a['title'];
            bVal = b['title'];
            break;
          case 'dateRequested':
            aVal = a['requestedDate'];
            bVal = b['requestedDate'];
            break;
          case 'dateUpdated':
            aVal = a['updatedDate'];
            bVal = b['updatedDate'];
            break;
          default:
            aVal = a['title'];
            bVal = b['title'];
        }

        // Null-safe comparison
        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return isAscending ? -1 : 1;
        if (bVal == null) return isAscending ? 1 : -1;

        if (aVal is DateTime && bVal is DateTime) {
          return isAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
        }

        // Fallback to string comparison
        return isAscending
            ? aVal.toString().compareTo(bVal.toString())
            : bVal.toString().compareTo(aVal.toString());
      });
    });
  } // stub for when you tap the filter button

  void _onFilterPressed() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        constraints: BoxConstraints(maxWidth: 500),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.filter_alt,
                                  color: Color(0xFF14213D),
                                  size: 24,
                                ),
                                const SizedBox(
                                    width:
                                        8), // Add space between icon and text
                                Text(
                                  'Filters',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF14213D),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            // Date range pickers
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
                                    date: fromDate,
                                    onTap: () => _pickDate(context, true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DatePickerCard(
                                    label: 'To',
                                    date: toDate,
                                    onTap: () => _pickDate(context, false),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Dropdowns
                            _buildDropdownField(
                              label: 'Service Category',
                              value: selectedCategory,
                              hint: 'Select Service Category',
                              items: filteredCategories.isEmpty
                                  ? allCategories
                                  : filteredCategories,
                              onChanged: (v) {
                                setModalState(() {
                                  selectedCategory = v;
                                  _filterDropdownOptions(v, selectedDivision);
                                });
                              },
                            ),
                            _buildDropdownField(
                              label: 'Location',
                              value: selectedDivision,
                              hint: 'Select Location',
                              items: filteredDivisions.isEmpty
                                  ? allDivisions
                                  : filteredDivisions,
                              onChanged: (v) {
                                setModalState(() {
                                  selectedDivision = v;
                                  _filterDropdownOptions(selectedCategory, v);
                                });
                              },
                            ),

                            const SizedBox(height: 5),

                            // Sort by radios (this is what needs to update visually)
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

                            Column(
                              children: [
                                _buildRadioTile(
                                  title: 'Service Request No.',
                                  value: 'serviceRequest',
                                  groupValue: sortBy,
                                  onChanged: (val) =>
                                      setModalState(() => sortBy = val),
                                ),
                                _buildRadioTile(
                                  title: 'Date Requested',
                                  value: 'dateRequested',
                                  groupValue: sortBy,
                                  onChanged: (val) =>
                                      setModalState(() => sortBy = val),
                                ),
                                _buildRadioTile(
                                  title: 'Date Updated',
                                  value: 'dateUpdated',
                                  groupValue: sortBy,
                                  onChanged: (val) =>
                                      setModalState(() => sortBy = val),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Apply button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  selectedDateRange = DateTimeRange(
                                    start: fromDate ?? DateTime.now(),
                                    end: toDate ?? DateTime.now(),
                                  );
                                  _applyFilters(); // You can use the updated sortBy
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

                      // Close button
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
      },
    );
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    // Determine date constraints
    DateTime initialDate =
        isFrom ? (fromDate ?? DateTime.now()) : (toDate ?? DateTime.now());

    // If we're picking the end date and a start date exists,
    // ensure the initial end date is after the start date
    if (!isFrom && fromDate != null && initialDate.isBefore(fromDate!)) {
      initialDate = fromDate!.add(const Duration(days: 1));
    }

    // Set first and last dates with proper constraints
    DateTime firstDate = isFrom ? DateTime(2000) : (fromDate ?? DateTime(2000));
    DateTime lastDate = isFrom ? (toDate ?? DateTime(2100)) : DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isFrom ? 'Select Start Date' : 'Select End Date',
      fieldHintText: 'dd/MM/yyyy',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF007A33),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // This updates the parent widget's state
      setState(() {
        if (isFrom) {
          fromDate = picked;

          // Auto-adjust end date if it's before start date
          if (toDate != null && picked.isAfter(toDate!)) {
            toDate = picked;
          }
        } else {
          toDate = picked;

          // Auto-adjust start date if it's after end date
          if (fromDate != null && picked.isBefore(fromDate!)) {
            fromDate = picked;
          }
        }
      });

      // Force the filter dialog to rebuild with updated dates
      Navigator.of(context).pop();
      _onFilterPressed();
    }
  }

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
                fillColor: Color(0xFFFFFFFF),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF707070)),
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
      _fetchAndSetOngoingRequests();
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
                    'Completed Requests',
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

            /// 🟦 Ongoing / Paused Tabs with Counts
            /// 🟦 Ongoing / Paused Tabs with Counts
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    // Ongoing Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPausedSelected =
                                false; // or true for the paused tab
                            // Initialize filteredRequests with the correct list
                            filteredRequests = List.from(isPausedSelected
                                ? pausedRequests
                                : ongoingRequests);
                            // Apply any current filters
                            _applyFilters();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isPausedSelected
                                ? const Color(0xFF14213D)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "ONGOING SERVICES",
                                style: TextStyle(
                                  color: !isPausedSelected
                                      ? Colors.white
                                      : const Color(0xFF14213D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${!isPausedSelected ? filteredRequests.length : ongoingRequests.length}',
                                style: TextStyle(
                                  color: const Color(0xFF50C878),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Paused Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPausedSelected =
                                true; // or true for the paused tab
                            // Initialize filteredRequests with the correct list
                            filteredRequests = List.from(isPausedSelected
                                ? pausedRequests
                                : ongoingRequests);
                            // Apply any current filters
                            _applyFilters();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isPausedSelected
                                ? const Color(0xFF14213D)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "PAUSED SERVICES",
                                style: TextStyle(
                                  color: isPausedSelected
                                      ? Colors.white
                                      : const Color(0xFF14213D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${isPausedSelected ? filteredRequests.length : pausedRequests.length}',
                                style: const TextStyle(
                                  color: Color(0xFF50C878),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Text part
                    RichText(
                      text: TextSpan(
                        text: 'Status: ',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'ONGOING SERVICE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: ' by',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Avatar part
                    CircleAvatar(
                      radius: 10, // small circle
                      backgroundColor: Colors.grey[400], // gray color
                      child:
                          Container(), // empty or put initials/text if needed
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildButton(
                  context,
                  "UPDATE STATUS",
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
          "UPDATE STATUS",
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
                    "Location: ${request['division'] ?? 'N/A'}",
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
                    "Subcategory: ${request['subCategory'] ?? 'N/A'}",
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Text part
                      RichText(
                        text: TextSpan(
                          text: 'Status: ',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'ONGOING SERVICE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' by',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Avatar part
                      CircleAvatar(
                        radius: 10, // small circle
                        backgroundColor: Colors.grey[400], // gray color
                        child:
                            Container(), // empty or put initials/text if needed
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildButton(
                    context,
                    "UPDATE STATUS",
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
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext c) {
    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      date != null
                          ? DateFormat('dd MMM yyyy').format(date!)
                          : 'Select date', // Show placeholder text
                      style: TextStyle(
                        color: date != null ? Colors.black : Colors.grey,
                        fontSize: 12,
                        fontWeight:
                            date != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
