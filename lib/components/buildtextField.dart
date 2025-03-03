import 'package:flutter/material.dart';

Widget buildTextField(String label, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Inter',
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 18,
            letterSpacing: 0,
            fontWeight: FontWeight.normal,
          ),
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 18,
            letterSpacing: 0,
            fontWeight: FontWeight.normal,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF018203),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFFF5963),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFFF5963),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      const SizedBox(height: 15),
    ],
  );
}
