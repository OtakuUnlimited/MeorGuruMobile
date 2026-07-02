import 'package:flutter/material.dart';

class PersonDetails {
  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController dobController =
      TextEditingController();

  final TextEditingController birthPlaceController =
      TextEditingController();

  final TextEditingController birthNameController =
      TextEditingController();

  String? gender;
  String? birthCountry;

  String? birthHour;
  String? birthMinute;

  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    birthPlaceController.dispose();
    birthNameController.dispose();
  }
}