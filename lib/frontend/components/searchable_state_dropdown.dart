import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchableStateDropdown extends StatefulWidget {
  final String? country;
  final String? initialState;
  final bool enabled;
  final String label;
  final ValueChanged<String?> onChanged;

  const SearchableStateDropdown({
    super.key,
    required this.country,
    this.initialState,
    this.enabled = true,
    this.label = "State",
    required this.onChanged,
  });

  @override
  State<SearchableStateDropdown> createState() =>
      _SearchableStateDropdownState();
}

class _SearchableStateDropdownState
    extends State<SearchableStateDropdown> {
  List<dynamic> countries = [];
  List<String> states = [];

  String? selectedState;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStates();
  }

  @override
  void didUpdateWidget(covariant SearchableStateDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.country != widget.country) {
      loadStates();
    }
  }

  Future<void> loadStates() async {
    final response = await rootBundle.loadString(
      'lib/assets/json/state.json',
    );

    countries = json.decode(response);

    states.clear();

    if (widget.country != null) {
      final country = countries.cast<Map<String, dynamic>?>().firstWhere(
            (e) => e?['name'] == widget.country,
            orElse: () => null,
          );

      if (country != null) {
        states = (country['states'] as List<dynamic>)
            .map<String>((e) => e['name'].toString())
            .toList();
      }
    }

    if (states.contains(widget.initialState)) {
      selectedState = widget.initialState;
    } else {
      selectedState = null;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
      enabled: widget.enabled,

      selectedItem: selectedState,

      items: (filter, infiniteScrollProps) {
        return states
            .where(
              (state) => state
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
            hintText: "Search state",
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
                selectedState = value;
              });

              widget.onChanged(value);
            }
          : null,
    );
  }
}