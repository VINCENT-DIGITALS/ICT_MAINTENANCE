import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:servicetracker_app/api_service/incident_report_service.dart';
import 'package:servicetracker_app/api_service/ongoing_request.dart';
import 'package:servicetracker_app/api_service/pendingRequest.dart';
import 'package:servicetracker_app/api_service/picked_request.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/components/equipmentInfoModal.dart';
import 'package:servicetracker_app/components/qrScanner.dart';
import 'package:servicetracker_app/components/request/PickRequestModal.dart';
import 'package:servicetracker_app/pages/ongoingRequests/serviceDetails.dart';
import 'package:servicetracker_app/pages/request/UpdateRequest.dart';

import '../../auth/sessionmanager.dart';
import 'IncidentReportResolvedPage.dart';

class IncidentReportPage extends StatefulWidget {
  final String currentPage;
  const IncidentReportPage({Key? key, this.currentPage = 'IncidentReportPage'})
      : super(key: key);

  @override
  _IncidentReportPageState createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  final ScrollController _scrollController = ScrollController();
  bool hasReports = true; // Change to false to test empty state
  bool isLoading = true;

  String? selectedReportCategory;
  String? selectedPriorityCategory;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allIncidents = [];
  List<Map<String, dynamic>> filteredIncidents = [];
  Map<String, String> categories = {};
  List<Map<String, dynamic>> technicians = [];
  List<String> uniqueLocations = []; // Add this line to store unique locations

  final List<String> priorityLevels = ["Normal", "High"];
  final List<String> statusTypes = ["Resolved", "Not Resolved"];
  bool isResolvedSelected = false; // Default to "Not Resolved" tab

  String? selectedCategory;
  String? selectedPriority;
  String? selectedStatus;
  String? selectedLocation;

  final DateTime _defaultFromDate = DateTime.now();
  final DateTime _defaultToDate = DateTime.now();
  DateTime? fromDate; // Nullable DateTime
  DateTime? toDate; // Nullable DateTime
  DateTime lastUpdated = DateTime.now();

  // ─── Filter state ─────────────────────────
  DateTimeRange? selectedDateRange;
  bool isAscending = true; // default sort A→Z

  // Date formatting
  final DateFormat _dateFormat = DateFormat('MMMM d, y, hh:mm a');
  final DateFormat _shortDateFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    _fetchIncidentReports();
    searchController.addListener(_applyFilters);
  }

  Future<void> _fetchIncidentReports() async {
    setState(() {
      isLoading = true;
    });

    try {
      final service = IncidentReportService();
      final data = await service.fetchIncidentReports();

      setState(() {
        allIncidents = data['incidents'];
        filteredIncidents = List.from(allIncidents);

        // Convert categories from Map<String, dynamic> to Map<String, String>
        final Map<String, dynamic> rawCategories = data['categories'];
        categories =
            rawCategories.map((key, value) => MapEntry(key, value.toString()));

        // Extract unique locations from incidents
        uniqueLocations = allIncidents
            .map((incident) => incident['location']?.toString() ?? '')
            .where((location) => location.isNotEmpty)
            .toSet()
            .toList();
        uniqueLocations.sort(); // Sort alphabetically

        technicians = data['technicians'];
        isLoading = false;
        lastUpdated = DateTime.now();

        // Apply default sorting on load (high priority first, then alphabetical)
        _applyFilters();
      });
    } catch (e) {
      print("Error fetching incident reports: $e");
      setState(() {
        isLoading = false;
      });
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
  String? sortBy = 'incidentDate'; // default

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
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    );
  }

  // Count getters for tabs
  int get resolvedIncidentsCount =>
      allIncidents.where((incident) => incident['status'] == 'Resolved').length;

  int get notResolvedIncidentsCount => allIncidents
      .where((incident) => incident['status'] == 'Not Resolved')
      .length;

  // Count getters for filtered tabs
  int get filteredResolvedCount => filteredIncidents
      .where((incident) => incident['status'] == 'Resolved')
      .length;

  int get filteredNotResolvedCount => filteredIncidents
      .where((incident) => incident['status'] == 'Not Resolved')
      .length;

  // Apply filters to the incident list
  void _applyFilters() {
    final q = searchController.text.toLowerCase();

    setState(() {
      filteredIncidents = allIncidents.where((incident) {
        // Text search match
        final name = (incident['incident_name'] ?? '').toString().toLowerCase();
        final reporter =
            (incident['reporter_name'] ?? '').toString().toLowerCase();
        final subject = (incident['subject'] ?? '').toString().toLowerCase();
        final description =
            (incident['description'] ?? '').toString().toLowerCase();
        final location = (incident['location'] ?? '').toString().toLowerCase();

        final matchesSearch = name.contains(q) ||
            reporter.contains(q) ||
            subject.contains(q) ||
            description.contains(q) ||
            location.contains(q);

        // Status tab filter - main filter based on selected tab
        final matchesTabStatus = isResolvedSelected
            ? incident['status'] == 'Resolved'
            : incident['status'] == 'Not Resolved';

        // Category filter
        final matchesCategory = selectedCategory == null ||
            categories[selectedCategory] == incident['category'];

        // Priority level filter
        final matchesPriority = selectedPriority == null ||
            incident['priority_level'] == selectedPriority;

        // Additional status filter from dropdown (if needed)
        final matchesStatus =
            selectedStatus == null || incident['status'] == selectedStatus;

        // Location filter
        final matchesLocation = selectedLocation == null ||
            incident['location'] == selectedLocation;

        // Date range
        DateTime? incidentDate;
        try {
          incidentDate = DateTime.parse(incident['incident_date']);
        } catch (e) {
          incidentDate = null;
        }

        final inDateRange =
            (fromDate == null || toDate == null || incidentDate == null) ||
                (!incidentDate.isBefore(fromDate!) &&
                    !incidentDate.isAfter(toDate!.add(Duration(days: 1))));

        return matchesSearch &&
            matchesTabStatus &&
            matchesCategory &&
            matchesPriority &&
            matchesStatus &&
            matchesLocation &&
            inDateRange;
      }).toList();

      // Sort the filtered results
      _sortFilteredIncidents();
    });
  }

  void _sortFilteredIncidents() {
    filteredIncidents.sort((a, b) {
      // First sort by priority (High comes before Normal)
      String priorityA = (a['priority_level'] ?? 'Normal').toString();
      String priorityB = (b['priority_level'] ?? 'Normal').toString();

      // If sorting specifically by another field (user selected in filter)
      if (sortBy != null && sortBy != 'incidentDate') {
        dynamic aVal;
        dynamic bVal;

        switch (sortBy) {
          case 'incidentName':
            aVal = a['incident_name'];
            bVal = b['incident_name'];
            break;
          case 'dateReported':
            try {
              aVal = DateTime.parse(a['date_reported']);
              bVal = DateTime.parse(b['date_reported']);
            } catch (e) {
              aVal = DateTime.now();
              bVal = DateTime.now();
            }
            break;
          case 'priority':
            // Already handling priority as primary sort
            aVal = priorityA;
            bVal = priorityB;
            break;
          default:
            aVal = a['incident_name'];
            bVal = b['incident_name'];
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
      } else {
        // Default sort: first by priority, then by name
        if (priorityA != priorityB) {
          // "High" comes before "Normal"
          return priorityA == "High" ? -1 : 1;
        }

        // If same priority, sort by name
        String nameA = (a['incident_name'] ?? '').toString();
        String nameB = (b['incident_name'] ?? '').toString();

        // For incident date, use the default ascending order
        try {
          DateTime dateA = DateTime.parse(a['incident_date']);
          DateTime dateB = DateTime.parse(b['incident_date']);
          return dateA.compareTo(dateB);
        } catch (e) {
          // If date parsing fails, fall back to name comparison
          return nameA.compareTo(nameB);
        }
      }
    });
  }

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
                              const SizedBox(width: 8),
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

                          // Dropdowns for filtering
                          _buildDropdownField(
                            label: 'Category',
                            value: selectedCategory,
                            hint: 'Select Category',
                            items:
                                categories.entries.map((e) => e.value).toList(),
                            onChanged: (v) {
                              setModalState(() => selectedCategory = v);
                            },
                          ),

                          // Location dropdown
                          _buildDropdownField(
                            label: 'Location',
                            value: selectedLocation,
                            hint: 'Select Location',
                            items: uniqueLocations,
                            onChanged: (v) {
                              setModalState(() => selectedLocation = v);
                            },
                          ),

                          // Priority Level dropdown (restored)
                          _buildDropdownField(
                            label: 'Priority Level',
                            value: selectedPriority,
                            hint: 'Select Priority',
                            items: priorityLevels,
                            onChanged: (v) {
                              setModalState(() => selectedPriority = v);
                            },
                          ),

                          const SizedBox(height: 5),

                          // Sort by radios
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
                                title: 'Incident Name',
                                value: 'incidentName',
                                groupValue: sortBy,
                                onChanged: (val) =>
                                    setModalState(() => sortBy = val),
                              ),
                              // Removed 'Incident Date' radio
                              _buildRadioTile(
                                title: 'Date Reported',
                                value: 'dateReported',
                                groupValue: sortBy,
                                onChanged: (val) =>
                                    setModalState(() => sortBy = val),
                              ),
                              // Removed 'Priority Level' radio
                            ],
                          ),

                          // Removed sort order toggle buttons

                          const SizedBox(height: 20),

                          // Apply button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
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

                    // Close button
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
            ));
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

  Future<void> refreshData() async {
    // Reset all filters
    setState(() {
      // Clear search text
      searchController.text = '';

      // Reset all filter selections
      selectedCategory = null;
      selectedPriority = null;
      selectedStatus = null;
      selectedLocation = null;
      fromDate = null;
      toDate = null;

      // Reset sort options to default
      sortBy = 'incidentDate';
      isAscending = true;

      // If necessary, reset to default tab
      isResolvedSelected = false;

      // Fetch fresh data
      _fetchIncidentReports();
    });
  }

  // Helper to check if filters are applied
  bool get areFiltersApplied {
    return searchController.text.isNotEmpty ||
        selectedCategory != null ||
        selectedPriority != null ||
        selectedStatus != null ||
        selectedLocation != null ||
        fromDate != null ||
        toDate != null;
  }

  // Count filtered incidents for both tabs regardless of which tab is active
  int getFilteredCount(String status) {
    return allIncidents.where((incident) {
      // Text search match
      final q = searchController.text.toLowerCase();
      final name = (incident['incident_name'] ?? '').toString().toLowerCase();
      final reporter =
          (incident['reporter_name'] ?? '').toString().toLowerCase();
      final subject = (incident['subject'] ?? '').toString().toLowerCase();
      final description =
          (incident['description'] ?? '').toString().toLowerCase();
      final location = (incident['location'] ?? '').toString().toLowerCase();

      final matchesSearch = name.contains(q) ||
          reporter.contains(q) ||
          subject.contains(q) ||
          description.contains(q) ||
          location.contains(q);

      // The status we want to count
      final matchesStatus = incident['status'] == status;

      // Category filter
      final matchesCategory = selectedCategory == null ||
          categories[selectedCategory] == incident['category'];

      // Priority level filter
      final matchesPriority = selectedPriority == null ||
          incident['priority_level'] == selectedPriority;

      // Status dropdown filter (if needed)
      final matchesStatusFilter =
          selectedStatus == null || incident['status'] == selectedStatus;

      // Location filter
      final matchesLocation =
          selectedLocation == null || incident['location'] == selectedLocation;

      // Date range
      DateTime? incidentDate;
      try {
        incidentDate = DateTime.parse(incident['incident_date']);
      } catch (e) {
        incidentDate = null;
      }

      final inDateRange =
          (fromDate == null || toDate == null || incidentDate == null) ||
              (!incidentDate.isBefore(fromDate!) &&
                  !incidentDate.isAfter(toDate!.add(Duration(days: 1))));

      return matchesSearch &&
          matchesStatus &&
          matchesCategory &&
          matchesPriority &&
          matchesStatusFilter &&
          matchesLocation &&
          inDateRange;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate counts for tabs
    final int filteredResolvedTabCount = areFiltersApplied
        ? getFilteredCount('Resolved')
        : resolvedIncidentsCount;

    final int filteredNotResolvedTabCount = areFiltersApplied
        ? getFilteredCount('Not Resolved')
        : notResolvedIncidentsCount;

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
                    Navigator.pushNamed(context, '/home');
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Incident Reports',
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
        body: RefreshIndicator(
          onRefresh: refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.075,
            ),
            children: [
              const SizedBox(height: 15),

              // Search & Filter
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

              // Status Tabs - styled like OngoingRequests page
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
                      // Not Resolved Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isResolvedSelected = false;
                              _applyFilters();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: !isResolvedSelected
                                  ? const Color(0xFF14213D)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "NOT RESOLVED",
                                  style: TextStyle(
                                    color: !isResolvedSelected
                                        ? Colors.white
                                        : const Color(0xFF14213D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  // Show filtered count when filters are applied
                                  areFiltersApplied
                                      ? '${filteredNotResolvedTabCount}'
                                      : '$notResolvedIncidentsCount',
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

                      // Resolved Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isResolvedSelected = true;
                              _applyFilters();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isResolvedSelected
                                  ? const Color(0xFF14213D)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "RESOLVED",
                                  style: TextStyle(
                                    color: isResolvedSelected
                                        ? Colors.white
                                        : const Color(0xFF14213D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  // Show filtered count when filters are applied
                                  areFiltersApplied
                                      ? '${filteredResolvedTabCount}'
                                      : '$resolvedIncidentsCount',
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

              // Info section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      isResolvedSelected
                          ? "Showing ${filteredIncidents.length} of $resolvedIncidentsCount resolved incidents"
                          : "Showing ${filteredIncidents.length} of $notResolvedIncidentsCount not resolved incidents",
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

              // Content Area
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    children: [
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : filteredIncidents.isEmpty
                              ? _buildEmptyState(context)
                              : _buildIncidentList(context, filteredIncidents),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build list of incident reports
  Widget _buildIncidentList(BuildContext context, List<dynamic> incidents) {
    return Column(
      children: incidents.map((incident) {
        // Format dates for display
        String formattedIncidentDate = '';
        String formattedReportedDate = '';

        try {
          final incidentDate = DateTime.parse(incident['incident_date']);
          formattedIncidentDate = _shortDateFormat.format(incidentDate);

          final reportedDate = DateTime.parse(incident['date_reported']);
          formattedReportedDate = _shortDateFormat.format(reportedDate);
        } catch (e) {
          print("Date parsing error: $e");
        }

        // Determine status color
        final Color statusColor =
            incident['status'] == 'Resolved' ? Colors.green : Colors.orange;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/IncidentReportDetails',
                  arguments: incident);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Incident name and info button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          incident['incident_name'] ?? 'Unnamed Incident',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Show detailed information in a modal
                          _showIncidentDetails(context, incident);
                        },
                        child: Container(
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
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: incident['priority_level'] == 'High'
                              ? Colors.red
                              : Color(0xFF007A33), // Green for Normal priority
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${incident['priority_level'] ?? 'Normal'} PRIORITY",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Subject and description
                  Text(
                    "Subject: ${incident['subject'] ?? 'No subject'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),

                  Text(
                    "Description: ${incident['description'] ?? 'No description'}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Dates
                  Text(
                    "Incident Date: $formattedIncidentDate",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF707070),
                      height: 1.0,
                    ),
                  ),
                  Text(
                    "Reported Date: $formattedReportedDate",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF707070),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // View Details button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: incident['status'] == 'Resolved'
                          ? null
                          : () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentReportResolvedPage(
                                      incidentNumber:
                                          incident['id']?.toString() ?? 'N/A',
                                      isResolved:
                                          incident['status'] == 'Resolved',
                                    ),
                                  ));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: incident['status'] == 'Resolved'
                            ? Colors.grey
                            : Colors.green[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        incident['status'] == 'Resolved'
                            ? 'ALREADY RESOLVED'
                            : 'MARK AS RESOLVED',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Show detailed incident information in a modal
  void _showIncidentDetails(
      BuildContext context, Map<String, dynamic> incident) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        String formattedIncidentDate = '';
        String formattedReportedDate = '';

        try {
          final incidentDate = DateTime.parse(incident['incident_date']);
          formattedIncidentDate = _dateFormat.format(incidentDate);

          final reportedDate = DateTime.parse(incident['date_reported']);
          formattedReportedDate = _dateFormat.format(reportedDate);
        } catch (e) {
          print("Date parsing error: $e");
        }

        return Center(
            child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident['incident_name'] ?? 'Unnamed Incident',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow('Subject:', incident['subject'] ?? 'N/A'),
                      _buildDetailRow(
                          'Description:', incident['description'] ?? 'N/A'),
                      _buildDetailRow('Incident Date:', formattedIncidentDate),
                      _buildDetailRow('Reported Date:', formattedReportedDate),
                      _buildDetailRow(
                          'Location:', incident['location'] ?? 'N/A'),
                      _buildDetailRow('Impact:', incident['impact'] ?? 'N/A'),
                      _buildDetailRow('Affected Areas:',
                          incident['affected_areas'] ?? 'N/A'),
                      _buildDetailRow(
                          'Reported By:', incident['reporter_name'] ?? 'N/A'),
                      _buildDetailRow('Priority Level:',
                          incident['priority_level'] ?? 'Normal'),
                      _buildDetailRow(
                          'Status:', incident['status'] ?? 'Not Resolved'),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Close the modal and navigate to the details screen
                            Navigator.of(context).pop();
                            Navigator.pushNamed(
                                context, '/IncidentReportDetails',
                                arguments: incident);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007A33),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "VIEW FULL DETAILS",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Close button
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
                    child:
                        const Icon(Icons.close, color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ));
      },
    );
  }

  // Helper to build detail rows in the modal
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: Colors.black, height: 1.3),
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "No incident reports found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Try adjusting your filters or create a new incident report",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Date picker card widget
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
                          : 'Select date',
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
