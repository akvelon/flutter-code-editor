import 'package:flutter/material.dart';

class DropdownSelector extends StatelessWidget {
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String value;
  final Iterable<String> values;

  const DropdownSelector({
    required this.icon,
    required this.onChanged,
    required this.value,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: values.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(growable: false),
      icon: Icon(icon, color: Colors.white),
      onChanged: (value) { if (value != null) onChanged(value); },
      dropdownColor: Colors.black87,
    );
  }
}