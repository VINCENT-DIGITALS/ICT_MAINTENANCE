import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildDropdownField.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:servicetracker_app/components/customSelectionModal.dart';
import 'package:servicetracker_app/services/FormProvider.dart';
import 'package:servicetracker_app/api_service/category_service.dart';
import 'package:servicetracker_app/components/qrScanner.dart';
import 'package:intl/intl.dart';

class NewRequest extends StatefulWidget {
  final String currentPage;

  const NewRequest({Key? key, this.currentPage = 'newRequest'})
      : super(key: key);

  @override
  _NewRequestState createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  final ScrollController _scrollController = ScrollController();
  int _currentStep = 0;
  // Controllers for each field
  late TextEditingController subjectController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController requesterController = TextEditingController();
  // New controller for telephone and cellphone fields
  late TextEditingController telephoneController = TextEditingController();
  late TextEditingController cellphoneController = TextEditingController();

  // Variable for requested completion date
  DateTime? requestedCompletionDate;
  String? selectedActualClient;

  String? selectedServiceCategory;
  String? selectedDivision;
  String? selectedLocation; // Add this for location field
  String? scannedLocation; // Add this for scanned location

  bool isLoading = false;

  // Add this list for actual client options
  final List<String> actualClients = [
    "John Doe",
    "Jane Smith",
    "Alex Johnson",
    "Sam Wilson",
  ];

  // Add this list for location options
  final List<String> Locations = [
    "Computer & Peripheral Services",
    "Network Services",
    "Software Support",
    "Hardware Repair",
  ];

  final List<String> divisions = [
    "Plant Breeding and Biotechnology",
    "Agronomy, Soils and Plant Physiology",
    "Crop Protection",
    "Genetic Resources",
    "Rice Engineering and Mechanization",
    "Rice Chemistry and Food Science",
    "Socioeconomics",
    "Development Communication",
    "Technology Management and Services",
    "Administrative",
    "Finance",
    "Information Systems"
  ];

  @override
  void initState() {
    super.initState();
    final subjectFromProvider =
        Provider.of<FormProvider>(context, listen: false).subject;
    subjectController = TextEditingController(text: subjectFromProvider ?? '');

    final descriptionFromProvider =
        Provider.of<FormProvider>(context, listen: false).description;
    descriptionController =
        TextEditingController(text: descriptionFromProvider ?? '');

    final requesterFromProvider =
        Provider.of<FormProvider>(context, listen: false).requester;
    requesterController =
        TextEditingController(text: requesterFromProvider ?? '');

    telephoneController = TextEditingController(
      text: Provider.of<FormProvider>(context, listen: false).telephoneNo ?? '',
    );

    cellphoneController = TextEditingController(
      text: Provider.of<FormProvider>(context, listen: false).cellphoneNo ?? '',
    );

    selectedServiceCategory =
        Provider.of<FormProvider>(context, listen: false).serviceCategory;
    selectedDivision =
        Provider.of<FormProvider>(context, listen: false).division;
    selectedLocation = // Add this to initialize the location
        Provider.of<FormProvider>(context, listen: false).location;

    requestedCompletionDate = Provider.of<FormProvider>(context, listen: false)
        .requestedCompletionDate;

    selectedActualClient =
        Provider.of<FormProvider>(context, listen: false).actualClient;

    _loadCategories();
  }

  // Add QR scanner method
  void _showQRScannerModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    ).then((scannedCode) {
      if (scannedCode != null) {
        setState(() {
          scannedLocation = scannedCode;
          selectedLocation =
              scannedCode; // Set the selected location to the scanned value
        });
      }
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final categoryService = CategoryService();
      final categories =
          await categoryService.fetchCategoriesWithSubcategories();

      // Update the form provider
      final formProvider = Provider.of<FormProvider>(context, listen: false);
      formProvider.setCategories(categories);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error loading categories: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper method to build category dropdown items
  List<String> _getCategoryNames(List<Map<String, dynamic>> categories) {
    return categories
        .map((category) => category['category_name'] as String)
        .toList();
  }

  // Helper method to find category ID by name
  int? _getCategoryIdByName(
      List<Map<String, dynamic>> categories, String? categoryName) {
    if (categoryName == null) return null;

    final category = categories.firstWhere(
      (category) => category['category_name'] == categoryName,
      orElse: () => {'id': null},
    );

    return category['id'];
  }

  // Helper method to build subcategory dropdown items
  List<String> _getSubcategoryNames(List<Map<String, dynamic>> subcategories) {
    return subcategories
        .map((subcategory) => subcategory['sub_category_name'] as String)
        .toList();
  }

  // Helper method to find subcategory ID by name
  int? _getSubcategoryIdByName(
      List<Map<String, dynamic>> subcategories, String? subcategoryName) {
    if (subcategoryName == null) return null;

    final subcategory = subcategories.firstWhere(
      (subcategory) => subcategory['sub_category_name'] == subcategoryName,
      orElse: () => {'id': null},
    );

    return subcategory['id'];
  }

  @override
  void dispose() {
    subjectController.dispose();
    descriptionController.dispose();
    requesterController.dispose();
    telephoneController.dispose();
    cellphoneController.dispose();
    super.dispose();
  }

  // Add this method to clear the form fields
  void _clearFormFields() {
    subjectController.clear();
    descriptionController.clear();
    requesterController.clear();
    telephoneController.clear();
    cellphoneController.clear();
    setState(() {
      selectedServiceCategory = null;
      selectedDivision = null;
      selectedLocation = null;
      scannedLocation = null;
      requestedCompletionDate = null;
      selectedActualClient = null;
    });
  }

  // Helper method to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: requestedCompletionDate ??
          DateTime.now().add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
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

    if (picked != null && picked != requestedCompletionDate) {
      setState(() {
        requestedCompletionDate = picked;
      });

      // Update the form provider
      final formProvider = Provider.of<FormProvider>(context, listen: false);
      formProvider.setRequestedCompletionDate(picked);
    }
  }

  void _showModal(
      BuildContext context, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      barrierDismissible: true, // Dismiss when tapped outside
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Keep it compact
              children: [
                const Text(
                  "Select an Option",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                /// **Options List**
                Column(
                  children: options.map((String option) {
                    return InkWell(
                      onTap: () {
                        onSelect(option);
                        Navigator.pop(dialogContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          option,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                /// **Cancel Button**
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel",
                      style: TextStyle(fontSize: 16, color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007A33),
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text.replaceAll(" ", "\n"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: CurvedEdgesAppBar(
          height: MediaQuery.of(context).size.height * 0.13,
          showFooter: false,
          backgroundColor: const Color(0xFF14213D),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            child: Stack(
              alignment: Alignment.center, // Keeps everything centered
              children: [
                // 🔹 Back Icon (Left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                // 🔹 Title with Icon (Centered & Resizable)
                Row(
                  mainAxisSize:
                      MainAxisSize.min, // Prevents unnecessary stretching
                  children: [
                    const SizedBox(width: 8), // Space between icon and text
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.5, // Responsive width
                      child: AutoSizeText(
                        'New Request',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30, // Max size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 12, // Shrinks if needed
                        overflow: TextOverflow.ellipsis, // Prevents overflow
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Form(
              key: formProvider.requestFormKeyStep1, // Assign GlobalKey here

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Wrap all form fields inside a SizedBox
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.85, // Set width for all children
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 25, 0, 15),
                            child: Align(
                              alignment: Alignment
                                  .centerLeft, // Aligns only the text to the left
                              child: const Text(
                                'Request Details',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Category Dropdown
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: buildDropdownField(
                              context,
                              "Service Category",
                              formProvider.selectedCategoryName,
                              _getCategoryNames(formProvider.categories),
                              (value) {
                                final categoryId = _getCategoryIdByName(
                                    formProvider.categories, value);
                                if (categoryId != null) {
                                  formProvider.setSelectedCategory(
                                      categoryId, value);
                                }
                              },
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Service Category is required"
                                      : null,
                            ),
                          ),

                          // Subcategory Dropdown (only show if a category is selected)
                          if (formProvider.selectedCategoryId != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: buildDropdownField(
                                context,
                                "Service Subcategory",
                                formProvider.selectedSubcategoryName,
                                _getSubcategoryNames(
                                    formProvider.subcategories),
                                (value) {
                                  final subcategoryId = _getSubcategoryIdByName(
                                      formProvider.subcategories, value);
                                  if (subcategoryId != null) {
                                    formProvider.setSelectedSubcategory(
                                        subcategoryId, value);
                                  }
                                },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? "Service Subcategory is required"
                                        : null,
                              ),
                            ),

                          const SizedBox(height: 15),
                          buildTextField(
                            "Subject",
                            subjectController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Subject is required"
                                : null,
                          ),

                          const SizedBox(height: 15),
                          buildTextField(
                            "Description",
                            descriptionController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Description is required"
                                : null,
                          ),
                          const SizedBox(height: 15),
                          // Add the Location field with QR scanner button here
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: buildDropdownField(
                                    context,
                                    "Location",
                                    selectedLocation,
                                    Locations,
                                    (value) {
                                      setState(() => selectedLocation = value);
                                      formProvider.setLocation(value);
                                    },
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? "Location is required"
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _showQRScannerModal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007A33),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size(0, 60),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  child: const Text(
                                    "SCAN QR",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),
                          // Date picker with floating label (like other fields)
                          FormField<DateTime>(
                            initialValue: requestedCompletionDate,
                            validator: (value) => value == null
                                ? "Date of completion is required"
                                : null,
                            builder: (FormFieldState<DateTime> state) {
                              final bool hasError = state.hasError;
                              final bool hasValue =
                                  requestedCompletionDate != null;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Container with border
                                      GestureDetector(
                                        onTap: () async {
                                          await _selectDate(context);
                                          state.didChange(
                                              requestedCompletionDate);
                                        },
                                        child: Container(
                                          height: 60,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: hasError
                                                  ? const Color(0xFFFF5963)
                                                  : Color(0xFFB0B0B0),
                                              width: 2,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Value or empty placeholder
                                              hasValue
                                                  ? Text(
                                                      DateFormat('MMM dd, yyyy')
                                                          .format(
                                                              requestedCompletionDate!),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                    )
                                                  : !hasValue
                                                      ? Text(
                                                          "Requested Date of Completion",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        )
                                                      : SizedBox(),

                                              // Calendar icon
                                              Icon(
                                                Icons.calendar_today,
                                                color: Colors.grey[600],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Floating label on the border line when value exists
                                      if (hasValue)
                                        Positioned(
                                          left: 10,
                                          top:
                                              -8, // Position to overlap with border
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4),
                                            color: Colors
                                                .white, // Background to hide the border line
                                            child: Text(
                                              "Requested Date of Completion",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, top: 5),
                                      child: Text(
                                        state.errorText!,
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 14),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 15),
                          buildTextField(
                            "Telephone No.",
                            telephoneController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Telephone is required"
                                : null,
                          ),

                          const SizedBox(height: 15),
                          buildTextField(
                            "Cellphone No.",
                            cellphoneController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Telephone is required"
                                : null,
                          ),

                          const SizedBox(height: 15),
                          buildDropdownField(
                            context,
                            "Actual Client",
                            selectedActualClient,
                            actualClients,
                            (value) {
                              setState(() => selectedActualClient = value);
                              formProvider.setActualClient(value);
                            },
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formProvider
                                        .requestFormKeyStep1.currentState!
                                        .validate()) {
                                      // Save new field values
                                      formProvider.setTelephoneNo(
                                          telephoneController.text);
                                      formProvider.setSubject(
                                          subjectController.text);
                                      formProvider.setDescription(
                                          descriptionController.text);
                                      formProvider.setCellphoneNo(
                                          cellphoneController.text);
                                      formProvider.setRequestedCompletionDate(
                                          requestedCompletionDate);
                                      formProvider.setActualClient(
                                          selectedActualClient);

                                      // ✅ Proceed to next page
                                      Navigator.pushNamed(
                                          context, '/NewRequestQR');
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Please fill all required fields"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007A33),
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 15, 15, 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "NEXT",
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
