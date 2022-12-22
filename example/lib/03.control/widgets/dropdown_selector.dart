import 'package:flutter/material.dart';

class DropdownSelector extends StatelessWidget {
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String value;
  final Iterable<String> values;

  const DropdownSelector({
    required this.onChanged,
    required this.icon,
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
      onChanged: onChanged as Function(String?),
      dropdownColor: Colors.black87,
    );
  }
}
