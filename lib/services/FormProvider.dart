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

    requestFormKeyStep1.currentState?.reset();
    requestFormKeyStep2.currentState?.reset();
    requestFormKeyStep3.currentState?.reset();

    notifyListeners();
  }
}
