import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:servicetracker_app/api_service/home_service.dart';
import 'package:servicetracker_app/auth/sessionmanager.dart';
import 'package:servicetracker_app/components/AddRequestModal.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/messageSentModal.dart';
import 'package:servicetracker_app/components/qrScanner.dart';
import 'package:servicetracker_app/services/FormProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicetracker_app/components/request/ButtonRequestModal.dart';

class HomePage extends StatefulWidget {
  final String currentPage;

  const HomePage({Key? key, this.currentPage = 'home'}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool hasOngoingRepairs = true; // Change to false to test empty state
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late Future<Map<String, dynamic>> _dashboardFuture;
  final DashboardService _dashboardService = DashboardService();

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Call your refresh method here when the page is rebuilt\
  //    _dashboardFuture = fetchFilteredDashboardData(); // Use filtered data here
  //   _refreshPage();
  // }

  // void _refreshPage() {
  //   setState(() {
  //     // Your refresh logic here (fetching data, resetting states, etc.)
  //   });
  // }

  @override
  void initState() {
    super.initState();
    toDate = DateTime.now();
    fromDate = DateTime.now().subtract(const Duration(days: 30));
    _dashboardFuture = fetchFilteredDashboardData(); // Use filtered data here
    _checkCameraPermission(); // 🔥 Check permissions on start
  }

  Future<void> _refreshDashboardData() async {
    setState(() {
      _dashboardFuture =
          fetchFilteredDashboardData(); // Use filtered data when refreshing
    });
  }

  /// 🔥 **Check and Request Camera Permission**
  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;

    if (!status.isGranted) {
      var result = await Permission.camera.request();
      if (!result.isGranted) {
        _showPermissionDialog();
      }
    }
  }

  /// ❌ **Show Dialog if Camera is Denied**
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text("Please allow camera access to scan QR codes."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Open device settings
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: isFrom ? DateTime(2000) : fromDate,
      lastDate: isFrom ? toDate : DateTime(2100),
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
          if (fromDate.isAfter(toDate)) toDate = fromDate;
        } else {
          toDate = picked;
          if (toDate.isBefore(fromDate)) fromDate = toDate;
        }
        _dashboardFuture =
            fetchFilteredDashboardData(); // refetch with new date range
      });
    }
  }

  List<Map<String, dynamic>> _filterByDate(
    List<dynamic> dataList,
    DateTime from,
    DateTime to,
  ) {
    return dataList
        .where((item) {
          final createdAt = DateTime.tryParse(item['created_at'] ?? '');
          if (createdAt == null) return false;
          return createdAt.isAfter(from.subtract(const Duration(days: 1))) &&
              createdAt.isBefore(to.add(const Duration(days: 1)));
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Future<Map<String, dynamic>> fetchFilteredDashboardData() async {
    final data = await DashboardService().fetchDashboardData();
    final SessionManager session = SessionManager();
    final user = await session.getUser();
    final String? technicianId = user?['philrice_id'];

    // Filter lists that need to be filtered by technician ID
    List<String> technicianFilteredLists = [
      'pickedRequests',
      'ongoingRequests',
      'pausedRequests',
      'completedRequests',
      'evaluatedRequests',
      'cancelledRequests',
      'deniedRequests'
    ];

    Map<String, dynamic> result = {};

    // First filter by date for all lists
    result['pendingRequests'] =
        _filterByDate(data['pendingRequests'], fromDate, toDate);

    // For technician lists, filter by date AND technician ID
    for (var listName in technicianFilteredLists) {
      if (data[listName] != null) {
        List<dynamic> dateFiltered =
            _filterByDate(data[listName], fromDate, toDate);

        // If we have a technician ID, further filter by it
        if (technicianId != null) {
          result[listName] = dateFiltered
              .where((item) => item['technician_id'] == technicianId)
              .toList();
        } else {
          result[listName] = dateFiltered;
        }
      } else {
        result[listName] = [];
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Adjust column count for GridView based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    const spacing = 12.0;
    const maxCardWidth = 200.0;

// determine how many columns fit (1–4):
    int crossAxisCount;
    if (screenWidth < maxCardWidth + spacing) {
      crossAxisCount = 1;
    } else if (screenWidth < (maxCardWidth + spacing) * 2) {
      crossAxisCount = 2;
    } else if (screenWidth < (maxCardWidth + spacing) * 3) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

// compute the grid’s max width so cards don’t stretch:
    final gridWidth =
        (maxCardWidth * crossAxisCount) + (spacing * (crossAxisCount - 1));

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;

          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Application'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF008037),
                  ),
                  child: const Text('EXIT'),
                ),
              ],
            ),
          );

          if (result == true) {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0); // Import 'dart:io' for this
            }
          }
        },
        child: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Maintenance-Login-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CurvedEdgesAppBar(
                height: MediaQuery.of(context).size.height * 0.13,
                showFooter: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          'Mabuhay, Ranniel!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Maintenance-Login-bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _refreshDashboardData,
                    child: ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // 👈 Forces scroll
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Date pickers row (responsive)
                              // Date pickers row (responsive)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth >
                                      500; // adjust as needed

                                  Widget dateRow = Row(
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
                                          onTap: () =>
                                              _pickDate(context, false),
                                        ),
                                      ),
                                    ],
                                  );

                                  return isWide
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 280),
                                            child: dateRow,
                                          ),
                                        )
                                      : dateRow;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Responsive Grid
                              Center(
                                child: ConstrainedBox(
                                  constraints:
                                      BoxConstraints(maxWidth: gridWidth),
                                  child: FutureBuilder<Map<String, dynamic>>(
                                    future: _dashboardFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }

                                      final data = snapshot.data!;

                                      final pendingCount =
                                          (data['pendingRequests'] as List?)
                                                  ?.length ??
                                              0;
                                      final pickedCount =
                                          (data['pickedRequests'] as List?)
                                                  ?.length ??
                                              0;
                                      final ongoingCount =
                                          (data['ongoingRequests'] as List?)
                                                  ?.length ??
                                              0;
                                      final pausedCount =
                                          (data['pausedRequests'] as List?)
                                                  ?.length ??
                                              0;
                                      final completedCount =
                                          (data['completedRequests'] as List?)
                                                  ?.length ??
                                              0;
                                      final evaluatedCount =
                                          (data['evaluatedRequests'] as List?)
                                                  ?.length ??
                                              0;
                                      final cancelledCount =
                                          (data['cancelledRequests'] as List?)
                                                  ?.length ??
                                              0;
                                      final deniedCount =
                                          (data['deniedRequests'] as List?)
                                                  ?.length ??
                                              0;
                                      final others =
                                          deniedCount + cancelledCount;

                                      return ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxWidth: gridWidth),
                                        child: GridView.count(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: spacing,
                                          mainAxisSpacing: spacing,
                                          childAspectRatio: maxCardWidth /
                                              (maxCardWidth * .8),
                                          children: [
                                            _StatCard(
                                              title: 'PENDING\nREQUESTS',
                                              mainValue: '$pendingCount',
                                              route: '/PendingRequests',
                                            ),
                                            _StatCard(
                                              title: 'PICKED\nREQUESTS',
                                              mainValue: '$pickedCount',
                                              route: '/PickedRequests',
                                            ),
                                            _StatCard(
                                              title: 'ONGOING\nSERVICES',
                                              mainValue: '$ongoingCount',
                                              subValues: [
                                                '$pausedCount paused'
                                              ],
                                              route: '/OngoingRequests',
                                            ),
                                            _StatCard(
                                              title: 'COMPLETED\nSERVICES',
                                              mainValue: '$completedCount',
                                              subValues: [
                                                '$evaluatedCount evaluated',
                                                '$others others',
                                              ],
                                              route: '/CompletedRequests',
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),

                              _buildButtons(
                                "ADD NEW SERVICE REQUEST",
                                () async {
                                  final formProvider = Provider.of<FormProvider>(context, listen: false);
                                  formProvider.resetForm();
                                  
                                  // Print user details from session for testing
                                  final SessionManager session = SessionManager();
                                  final user = await session.getUser();
                                  print('==== USER DETAILS FROM SESSION ====');
                                  print('User: ${user.toString()}');
                                  if (user != null) {
                                    print('Philrice ID: ${user['philrice_id']}');
                                    print('Name: ${user['name']}');
                                    print('Email: ${user['email']}');
                                    print('Role: ${user['role']}');
                                  } else {
                                    print('No user data found in session');
                                  }
                                  print('==================================');
                                  
                                  final reachedLimit = await DashboardService().checkPendingRequestsLimitAndPrompt(context);
                                  print('Reached Limit: $reachedLimit');
                                  if (reachedLimit) {
                                    // The detailed message is now handled inside the checkPendingRequestsLimitAndPrompt method
                                    // No need to show another dialog here
                                    return;
                                  }
                                  Navigator.pushNamed(context, '/newRequest');
                                },
                                context,
                                textColor: const Color(0xFF004D1E),
                                buttonColor: const Color(0xFF45CF7F),
                              ),

                              _buildButtons(
                                "INCIDENT REPORTS",
                                () => Navigator.pushNamed(
                                    context, '/IncidentReports'),
                                context,
                                textColor: const Color(0xFFFFFFFF),
                                buttonColor: const Color(0xFF007A33),
                              ),

                              _buildButtons(
                                "ADD NEW INCIDENT",
                                () => Navigator.pushNamed(
                                    context, '/NewIncidentReport'),
                                context,
                                textColor: const Color(0xFF004D1E),
                                buttonColor: const Color(0xFF45CF7F),
                              ),

                              // Action buttons (you can add the buttons back here as needed)
                              // _ActionButton(
                              //     text: 'ADD NEW SERVICE REQUEST',
                              //     onTap: _onAddService),
                              // const SizedBox(height: 12),
                              // _ActionButton(
                              //     text: 'INCIDENT REPORTS', onTap: _onIncidentReports),
                              // const SizedBox(height: 12),
                              // _ActionButton(
                              //     text: 'ADD NEW INCIDENT', onTap: _onAddIncident),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  /// 🛠 Bottom Section with Buttons
  Widget _buildButtons(
    String text,
    VoidCallback onPressed,
    BuildContext context, {
    required Color textColor,
    required Color buttonColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 2222222),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final formProvider =
                  Provider.of<FormProvider>(context, listen: false);
              formProvider.resetForm(); // ✅ Clear form before starting
              onPressed(); // ✅ Continue navigation or action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18, // 12% of screen height
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      decoration: BoxDecoration(
        color: Color(0xFFFCA311), // Orange background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40), // Curved top-left
          topRight: Radius.circular(40), // Curved top-right
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton("INCIDENT REPORTS", () {
            Navigator.pushNamed(context, '/IncidentReports');
          }, context),
          const SizedBox(width: 10), // Space between buttons
          _buildActionButton("ADD NEW INCIDENT", () {
            Navigator.pushNamed(context, '/PendingRequests');
          }, context),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, VoidCallback onPressed, BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85, // Set button width
        child: ElevatedButton(
          onPressed: () {
            final formProvider =
                Provider.of<FormProvider>(context, listen: false);
            formProvider.resetForm(); // ✅ Clear form before starting
            onPressed(); // ✅ Continue navigation or action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14213D), // Dark blue
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8), // Slightly rounded button corners
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double iconSize =
                  constraints.maxWidth * 0.09; // Adaptive icon size
              return Row(
                mainAxisSize: MainAxisSize.min, // Keeps content centered
                children: [
                  Expanded(
                    child: AutoSizeText(
                      text,
                      style: const TextStyle(
                        fontSize: 16, // Max size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2, // Allows wrapping into two lines
                      minFontSize: 8, // Shrinks text when needed
                    ),
                  ),
                  const SizedBox(width: 10), // Space between text and icon
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: iconSize.clamp(20, 36), // Adaptive & clamped size
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Date‑picker card
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
            border: Border.all(color: Colors.white),
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
                        color: Colors.white70,
                        fontSize: 10, // smaller
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: 20, // smaller icon
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Statistic card

class _StatCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final List<String> subValues;
  final String route;

  const _StatCard({
    required this.title,
    required this.mainValue,
    this.subValues = const [],
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF007A33),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),

            // Body
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: AutoSizeText(
                        mainValue,
                        maxLines: 1,
                        minFontSize: 20,
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // 👈 Center vertically
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: subValues
                            .map((sub) => Expanded(
                                  // 👈 Each sub-value takes equal space
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: AutoSizeText(
                                      sub,
                                      maxLines: 1,
                                      minFontSize: 10,
                                      maxFontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    ));
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Large full‑width button
class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _ActionButton({required this.text, required this.onTap});
  @override
  Widget build(BuildContext c) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor:
              text.contains('INCIDENT') ? Color(0xFF007A33) : Color(0xFF27AE60),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
