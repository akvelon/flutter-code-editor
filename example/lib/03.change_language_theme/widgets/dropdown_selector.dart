import 'package:flutter/material.dart';

class DropdownSelector<T> extends StatelessWidget {
  final IconData icon;
  final ValueChanged<T> onChanged;
  final T value;
  final Iterable<T> values;

  const DropdownSelector({
    required this.icon,
    required this.onChanged,
    required this.value,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      items: values.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(
            value is String ? value : value.runtimeType.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(growable: false),
      icon: Icon(icon, color: Colors.white),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      dropdownColor: Colors.black87,
    );
  }
}
