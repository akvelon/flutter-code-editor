import 'package:flutter/material.dart';

class DropdownSelector extends StatelessWidget {
  final Iterable<String?> choices;
  final String value;
  final IconData icon;
  final Function(String?)? onChanged;

  const DropdownSelector({
    super.key,
    required this.choices,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: choices.map((String? value) {
        return DropdownMenuItem<String>(
          value: value,
          child: value == null
              ? const Divider()
              : Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      icon: Icon(icon, color: Colors.white),
      onChanged: onChanged,
      dropdownColor: Colors.black87,
    );
  }
}
