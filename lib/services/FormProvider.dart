import 'dart:io';

import 'package:flutter/material.dart';

class FormProvider extends ChangeNotifier {
  final GlobalKey<FormState> requestFormKeyStep1 =
      GlobalKey<FormState>(); // Global key for validation
  final GlobalKey<FormState> requestFormKeyStep2 =
      GlobalKey<FormState>(); // Global key for validation
  final GlobalKey<FormState> requestFormKeyStep3 =
      GlobalKey<FormState>(); // Global key for validation

  String? serviceCategory;
  String? subject;
  String? description;
  String? requester;
  String? division;

  // Equipment info
  String? scannedEquipment; // for  QR data
  String? accountableperson;
  String? accountableDivision;

  //Technician Remarks
  String? location;
  String? technicianNotes;
  List<String> assignedTechnicians = [];
  File? photoDocumentationBefore; // for single image

  // Categories and subcategories data
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  String? _selectedCategoryName;
  String? _selectedSubcategoryName;

  // Add new variables for the new fields
  String? _telephoneNo;
  String? _cellphoneNo;
  DateTime? _requestedCompletionDate;
  String? _actualClient;

  // Getters
  List<Map<String, dynamic>> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedSubcategoryId => _selectedSubcategoryId;
  String? get selectedCategoryName => _selectedCategoryName;
  String? get selectedSubcategoryName => _selectedSubcategoryName;
  String? get telephoneNo => _telephoneNo;
  String? get cellphoneNo => _cellphoneNo;
  DateTime? get requestedCompletionDate => _requestedCompletionDate;
  String? get actualClient => _actualClient;

  // Get subcategories for the selected category
  List<Map<String, dynamic>> get subcategories {
    if (_selectedCategoryId == null) return [];

    // Find the selected category
    final selectedCategory = _categories.firstWhere(
      (category) => category['id'] == _selectedCategoryId,
      orElse: () => {'subcategories': []},
    );

    return List<Map<String, dynamic>>.from(selectedCategory['subcategories'] ?? []);
  }

  void updateForm({
    String? serviceCategory,
    String? subject,
    String? description,
    String? requester,
    String? division,

    // Equipment info
    String? scannedEquipment,
    String? accountableperson,
    String? accountableDivision,

    //Technician Remarks
    String? location,
    String? technicianNotes,
    List<String>? assignedTechnicians,
    File? photoDocumentationBefore,

    // New fields
    String? telephoneNo,
    String? cellphoneNo,
    DateTime? requestedCompletionDate,
    String? actualClient,
  }) {
    this.serviceCategory = serviceCategory ?? this.serviceCategory;
    this.subject = subject ?? this.subject;
    this.description = description ?? this.description;
    this.requester = requester ?? this.requester;
    this.division = division ?? this.division;

    // Equipment info
    this.scannedEquipment = scannedEquipment ?? this.scannedEquipment;
    this.accountableperson = accountableperson ?? this.accountableperson;
    this.accountableDivision = accountableDivision ?? this.accountableDivision;

    this.location = location ?? this.location;
    this.technicianNotes = technicianNotes ?? this.technicianNotes;
    this.assignedTechnicians = assignedTechnicians ?? this.assignedTechnicians;
    this.photoDocumentationBefore = photoDocumentationBefore ?? this.photoDocumentationBefore;

    // New fields
    this._telephoneNo = telephoneNo ?? this._telephoneNo;
    this._cellphoneNo = cellphoneNo ?? this._cellphoneNo;
    this._requestedCompletionDate = requestedCompletionDate ?? this._requestedCompletionDate;
    this._actualClient = actualClient ?? this._actualClient;

    notifyListeners();
  }

  /// Function to update QR data
  void updateQRData(String? qr) {
    scannedEquipment = qr;
    notifyListeners();
  }

  /// validate the entire form
  // bool validateForm() {
  //   return requestFormKey.currentState?.validate() ?? false;
  // }

  bool validateStep1() {
    return serviceCategory != null &&
        serviceCategory!.isNotEmpty &&
        subject != null &&
        subject!.isNotEmpty &&
        description != null &&
        description!.isNotEmpty &&
        requester != null &&
        requester!.isNotEmpty &&
        division != null &&
        division!.isNotEmpty;
  }

  bool validateStep2() {
    return scannedEquipment != null &&
        scannedEquipment!.isNotEmpty &&
        accountableperson != null &&
        accountableperson!.isNotEmpty &&
        accountableDivision != null &&
        accountableDivision!.isNotEmpty;
  }

  bool validateStep3() {
    return location != null &&
        location!.isNotEmpty &&
        technicianNotes != null &&
        technicianNotes!.isNotEmpty &&
        assignedTechnicians.isNotEmpty &&
        photoDocumentationBefore != null; // Make sure image is provided
  }

  // ✅ Reset form after submission
  void resetForm() {
    serviceCategory = null;
    subject = null;
    description = null;
    requester = null;
    division = null;

    scannedEquipment = null;
    accountableperson = null;
    accountableDivision = null;

    location = null;
    technicianNotes = null;
    assignedTechnicians = [];
    photoDocumentationBefore = null;
    _selectedCategoryId = null;
    _selectedCategoryName = null;
    _selectedSubcategoryId = null;
    _selectedSubcategoryName = null;
    requestFormKeyStep1.currentState?.reset();
    requestFormKeyStep2.currentState?.reset();
    requestFormKeyStep3.currentState?.reset();

    // Reset new fields
    _telephoneNo = null;
    _cellphoneNo = null;
    _requestedCompletionDate = null;
    _actualClient = null;

    notifyListeners();
  }

  // Setters
  void setCategories(List<Map<String, dynamic>> categories) {
    _categories = categories;
    notifyListeners();
  }

  void setSelectedCategory(int categoryId, String categoryName) {
    _selectedCategoryId = categoryId;
    _selectedCategoryName = categoryName;
    // Reset subcategory when category changes
    _selectedSubcategoryId = null;
    _selectedSubcategoryName = null;
    notifyListeners();
  }

  void setSelectedSubcategory(int subcategoryId, String subcategoryName) {
    _selectedSubcategoryId = subcategoryId;
    _selectedSubcategoryName = subcategoryName;
    notifyListeners();
  }

  // Add subject setter
  void setSubject(String value) {
    subject = value;
    notifyListeners();
  }

  // Add description setter
  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  // Add requester setter
  void setRequester(String value) {
    requester = value;
    notifyListeners();
  }

  // Add division setter
  void setDivision(String value) {
    division = value;
    notifyListeners();
  }

  // Add location setter
  void setLocation(String value) {
    location = value;
    notifyListeners();
  }

  // Add telephone number setter
  void setTelephoneNo(String? value) {
    _telephoneNo = value;
    notifyListeners();
  }

  // Add cellphone number setter
  void setCellphoneNo(String? value) {
    _cellphoneNo = value;
    notifyListeners();
  }

  // Add requested completion date setter
  void setRequestedCompletionDate(DateTime? value) {
    _requestedCompletionDate = value;
    notifyListeners();
  }

  // Add actual client setter
  void setActualClient(String? value) {
    _actualClient = value;
    notifyListeners();
  }
}
