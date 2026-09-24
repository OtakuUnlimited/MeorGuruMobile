import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SearchableCountryDropdown extends StatefulWidget {
  final String? initialCountry;
  final bool enabled;
  final String label;
  final ValueChanged<String?> onChanged;

  const SearchableCountryDropdown({
    super.key,
    this.initialCountry,
    this.enabled = true,
    required this.label,
    required this.onChanged,
  });

  @override
  State<SearchableCountryDropdown> createState() =>
      _SearchableCountryDropdownState();
}

class _SearchableCountryDropdownState
    extends State<SearchableCountryDropdown> {
  List<dynamic> countries = [];

  String? selectedCountry;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    final response = await rootBundle.loadString(
      'lib/assets/json/state.json',
    );

    countries = json.decode(response);

    selectedCountry = widget.initialCountry;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 45,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DropdownSearch<String>(
      selectedItem: selectedCountry,

      items: (filter, infiniteScrollProps) {
        return countries
            .map<String>((e) => e['name'].toString())
            .where(
              (country) => country
                  .toLowerCase()
                  .contains(filter.toLowerCase()),
            )
            .toList();
      },

      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchDelay: Duration.zero,
        fit: FlexFit.loose,
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search country",
          ),
        ),
      ),

      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: widget.label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Color(0xFFFA6400),
              width: 1,
            ),
          ),
        ),
      ),

      onChanged: widget.enabled
          ? (value) {
              setState(() {
                selectedCountry = value;
              });

              widget.onChanged(value);
            }
          : null,
    );
  }
}