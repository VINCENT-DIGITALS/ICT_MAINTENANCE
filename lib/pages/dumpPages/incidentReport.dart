// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:servicetracker_app/components/appbar.dart';
// import 'package:servicetracker_app/components/customSelectionModal.dart';
// import 'package:servicetracker_app/components/qrScanner.dart';

// class IncidentReports extends StatefulWidget {
//   final String currentPage;

//   const IncidentReports({Key? key, this.currentPage = 'IncidentReports'})
//       : super(key: key);

//   @override
//   _IncidentReportsState createState() => _IncidentReportsState();
// }

// class _IncidentReportsState extends State<IncidentReports> {
//   final ScrollController _scrollController = ScrollController();
//   bool hasReports = true; // Change to false to test empty state
//   List<dynamic> pickedRequests = [];
//   List<dynamic> ongoingRepairs = [];
//   List<dynamic> completeRepairs = [];

//   String? selectedReportCategory;
//   String? selectedPriorityCategory;

//   final List<String> reportCategories = [
//     "Computer & Peripheral Services",
//     "Network Services",
//     "Software Support",
//     "Hardware Repair",
//   ];

//   final List<String> priorityCategories = [
//     "Information Systems Divwwwwwwwwwwwwwwwwwwision",
//     "HR Division",
//     "Finance Division",
//     "Operations Division",
//   ];

//   get http => null;

//   @override
//   void initState() {
//     super.initState();
//     // fetchRepairsData();
//     pickedRequests = [
//       {
//         "title": "TN25-0143 Cosssssssssssssssssssssssssssssssssssmputer Repair",
//         "requester": "Mighty Jemuel Sotto",
//         "division": "Information Systems Division",
//         "requestedDate": "February 14, 2025, 10:00 AM",
//         "description":
//             "Issue with the system booting up. Needs hardware diagnostics.",
//       },
//       {
//         "title": "TN25-0144 Printer Issue",
//         "requester": "John Doe",
//         "division": "IT Support",
//         "requestedDate": "February 15, 2025, 09:30 AM",
//         "description": "Printer is not connecting to the network.",
//       },
//     ];

//     // ongoingRepairs = [
//     //   {
//     //     "title": "TN25-0145 Server Maintenance",
//     //     "requester": "Jane Smith",
//     //     "division": "Network Administration",
//     //     "requestedDate": "February 13, 2025, 2:00 PM",
//     //     "location": "Data Center",
//     //     "status": "Ongoing - Awaiting Parts",
//     //     "lastUpdated": "February 19, 2025 | 3:00 PM",
//     //   },
//     //   {
//     //     "title": "TN25-0146 Laptop Repair",
//     //     "requester": "Alice Johnson",
//     //     "division": "Development Team",
//     //     "requestedDate": "February 12, 2025, 11:45 AM",
//     //     "location": "IT Lab",
//     //     "status": "Being Diagnosed",
//     //     "lastUpdated": "February 18, 2025 | 10:15 AM",
//     //   },
//     // ];
//     // completeRepairs = [
//     //   {
//     //     "title": "TN25-0145 Server Maintenance",
//     //     "requester": "Jane Smith",
//     //     "division": "Network Administration",
//     //     "requestedDate": "February 13, 2025, 2:00 PM",
//     //     "location": "Data Center",
//     //     "status": "Ongoing - Awaiting Parts",
//     //     "lastUpdated": "February 19, 2025 | 3:00 PM",
//     //   },
//     //   {
//     //     "title": "TN25-0146 Laptop Repair",
//     //     "requester": "Alice Johnson",
//     //     "division": "Development Team",
//     //     "requestedDate": "February 12, 2025, 11:45 AM",
//     //     "location": "IT Lab",
//     //     "status": "Being Diagnosed",
//     //     "lastUpdated": "February 18, 2025 | 10:15 AM",
//     //   },
//     // ];
 
//   }

//   Future<void> fetchRepairsData() async {
//     final response =
//         await http.get(Uri.parse('https://your-api-url.com/repairs'));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         pickedRequests =
//             data['pickedRequests']; // Replace with actual API response key
//         ongoingRepairs =
//             data['ongoingRepairs']; // Replace with actual API response key
//         completeRepairs =
//             data['completeRepairs']; // Replace with actual API response key
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//       appBar: CurvedEdgesAppBar(
//         height: MediaQuery.of(context).size.height * 0.13,
//         showFooter: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
//           child: Stack(
//             alignment: Alignment.center, // Centers the text
//             children: [
//               // 🔹 Back Icon (Left)
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/home');
//                     // Navigator.pop(context);
//                   },
//                   icon: const Icon(
//                     Icons.arrow_back,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ),
//               ),

//               // 🔹 Title (Centered)
//               const Text(
//                 'Inciden Reports',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//       backgroundColor: Color.fromRGBO(20, 33, 61, 1),

//       /// 🔥 Main Layout with Fixed Bottom Buttons
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.85, // Set width
//                 child: Column(
//                   children: [
//                     /// **Division Field**

//                     Row(
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
//                           child: const Text(
//                             "Filter ",
//                             style: TextStyle(
//                               color: Colors.white, // Adjust color as needed
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),

//                         Expanded(
//                           // Ensures dropdown takes up available space
//                           child: _buildDropdownField(
//                             context,
//                             "All Reports",
//                             selectedReportCategory,
//                             reportCategories,
//                             (value) {
//                               setState(() => selectedReportCategory = value);
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
//                           child: const Text(
//                             "Sort ",
//                             style: TextStyle(
//                               color: Colors.white, // Adjust color as needed
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10), // Space between dropdowns
//                         Expanded(
//                           child: _buildDropdownField(
//                             context,
//                             "Priority",
//                             selectedPriorityCategory,
//                             priorityCategories,
//                             (value) {
//                               setState(() => selectedPriorityCategory = value);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20), // Extra space at the bottom
//                     hasReports
//                         ? _buildIncidentReports(context, pickedRequests)
//                         : _buildEmptyPickedState(context),

//                     const SizedBox(height: 80), // Extra space at the bottom
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//       /// 🔹 Fixed Bottom Bar
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         color: const Color.fromRGBO(20, 33, 61, 1), // Match background color
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildAddRequestButtons(),
//             // const Text(
//             //   "Last Updated: February 19, 2025, 10:30 AM",
//             //   style: TextStyle(
//             //     color: Colors.white,
//             //     fontSize: 12,
//             //     fontWeight: FontWeight.w500,
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     ));
//   }

//   Widget _buildDropdownField(BuildContext context, String label, String? value,
//       List<String> options, Function(String) onSelect) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           clipBehavior: Clip.none,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 showCustomSelectionModal(
//                   context: context,
//                   title: label,
//                   options: options,
//                   selectedOptions: value != null ? [value] : [],
//                   onConfirm: (List<String> selected) {
//                     if (selected.isNotEmpty) {
//                       onSelect(selected.first);
//                     }
//                   },
//                   isSingleSelect: true,
//                 );
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 5), // ✅ Reduced height
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(
//                       8), // ✅ Slightly smaller border radius
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         value ?? label,
//                         style:
//                             const TextStyle(fontSize: 14, color: Colors.black),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                     ),
//                     const Icon(Icons.keyboard_arrow_down,
//                         size: 16, color: Colors.grey), // ✅ Smaller icon
//                   ],
//                 ),
//               ),
//             ),
//             if (value != null)
//               Positioned(
//                 top: -8,
//                 left: 10,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   color: Colors.white,
//                   child: Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 10, // ✅ Smaller font for label
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8), // ✅ Reduced spacing below dropdown
//       ],
//     );
//   }

//   /// 🛠 Bottom Section with Buttons
//   Widget _buildAddRequestButtons() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
//       // color: Colors.white,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//               padding: const EdgeInsets.symmetric(
//                   vertical: 10), // Simplified padding
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 2222222),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width *
//                       0.85, // 90% of screen width
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/NewIncidentReport');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF007A33),
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       "NEW INCIDENT REPORT",
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ))

//           /// 🔥 Add New Request Button (Always Visible)
//         ],
//       ),
//     );
//   }

//   /// 🛠 Builds a list of Ongoing Repairs (Replace with your real data)
//   Widget _buildIncidentReports(BuildContext context, List<dynamic> requests) {
//     return Column(
//       children: requests.map((request) {
//         return Padding(
//             padding:
//                 const EdgeInsets.only(bottom: 10), // Adds spacing between items

//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.85, // 90% width
//               padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     request['title'] ?? "No Title",
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w900, fontSize: 18),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                   const SizedBox(height: 5),
//                   Text("Requested by ${request['requester'] ?? "Unknown"}",
//                       style: const TextStyle(
//                           fontSize: 14, height: 1.0, color: Color(0xFF707070))),
//                   Text(
//                     "${request['requestedDate'] ?? "N/A"}",
//                     style: TextStyle(
//                         height: 1.0, fontSize: 14, color: Color(0xFF707070)),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     request['description'] ?? "No details available",
//                     style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.normal,
//                         height: 1.0),
//                     softWrap: true,
//                     overflow: TextOverflow.visible,
//                     maxLines: 3,
//                   ),
//                   const SizedBox(height: 15),
//                   Text("Priority level: ${selectedPriorityCategory ?? "N/A"}",
//                       style: TextStyle(
//                           fontWeight: FontWeight.normal, fontSize: 14)),
//                   const SizedBox(height: 15),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/IncidentReportDetails');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF45CF7F),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     child: const Text(
//                       "VIEW DETAILS",
//                       style: TextStyle(
//                           color: Color(0xFF007A33),
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ));
//       }).toList(),
//     );
//   }

//   /// 🛠 Shows Empty State when there are no Ongoing Repairs
//   Widget _buildEmptyPickedState(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.85, // 90% of screen width

//       padding: const EdgeInsets.fromLTRB(
//           20, 5, 20, 5), // Adds spacing inside the container
//       decoration: BoxDecoration(
//         color: Colors.grey[200], // Light gray background
//         borderRadius: BorderRadius.circular(12), // Rounded corners
//       ),
//       child: Column(
//         mainAxisAlignment:
//             MainAxisAlignment.center, // Centers content vertically
//         children: const [
//           // SizedBox(height: 5),
//           Text(
//             "Select Incident Report to get started.",
//             style: TextStyle(fontSize: 14, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
