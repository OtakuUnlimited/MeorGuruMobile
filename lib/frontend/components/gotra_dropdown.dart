import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class GotraDropdown extends StatefulWidget {
  final String? initialValue;
  final bool enabled;
  final String label;
  final ValueChanged<String?> onChanged;

  const GotraDropdown({
    super.key,
    this.initialValue,
    this.enabled = true,
    this.label = "",
    required this.onChanged,
  });

  @override
  State<GotraDropdown> createState() => _GotraDropdownState();
}

class _GotraDropdownState extends State<GotraDropdown> {
  String? selectedGotra;

  final List<Map<String, String>> gotras = [
    {"value": "angira", "label": "Angira"},
    {"value": "atri", "label": "Atri"},
    {"value": "aatreya", "label": "Aatreya"},
    {"value": "bharadwaj", "label": "Bharadwaj"},
    {"value": "dhananjaya", "label": "Dhananjaya"},
    {"value": "garg", "label": "Garg"},
    {"value": "gautam", "label": "Gautam"},
    {"value": "ghrita-kaushik", "label": "Ghrita Kaushik"},
    {"value": "kapil", "label": "Kapil"},
    {"value": "kashyap", "label": "Kashyap"},
    {"value": "kaudinya", "label": "Kaudinya"},
    {"value": "kausalya", "label": "Kausalya"},
    {"value": "kaushik", "label": "Kaushik"},
    {"value": "kundin", "label": "Kundin"},
    {"value": "mandabya", "label": "Mandabya"},
    {"value": "maudgalya", "label": "Maudgalya"},
    {"value": "parashar", "label": "Parashar"},
    {"value": "ravi", "label": "Ravi"},
    {"value": "sankhyayan", "label": "Sankhyayan"},
    {"value": "shandilya", "label": "Shandilya"},
    {"value": "upamanyu", "label": "Upamanyu"},
    {"value": "bishwamitra", "label": "Bishwamitra"},
    {"value": "batsa", "label": "Batsa"},
    {"value": "basistha", "label": "Basistha"},
    {"value": "other", "label": "Other"},
  ];

  @override
  void initState() {
    super.initState();
    selectedGotra = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      enabled: widget.enabled,

      selectedItem: selectedGotra,

      items: (filter, infiniteScrollProps) {
        return gotras
            .where((g) => g["label"]!
                .toLowerCase()
                .contains(filter.toLowerCase()))
            .map((g) => g["value"]!)
            .toList();
      },

      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchDelay: Duration.zero,
        fit: FlexFit.loose,
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search Gotra",
          ),
        ),
      ),

      dropdownBuilder: (context, value) {
        final gotra = gotras.firstWhere(
          (g) => g["value"] == value,
          orElse: () => {"label": ""},
        );

        return Text(gotra["label"] ?? "");
      },

      itemAsString: (value) {
        return gotras.firstWhere(
          (g) => g["value"] == value,
        )["label"]!;
      },

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
                selectedGotra = value;
              });

              widget.onChanged(value);
            }
          : null,
    );
  }
}