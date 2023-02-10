import 'package:flutter/material.dart';

class DropdownSelector<T> extends StatelessWidget {
  final IconData icon;
  final ValueChanged<T> onChanged;
  final T value;
  final Iterable<T> values;
  final String Function(T item)? itemToString;

  const DropdownSelector({
    required this.icon,
    required this.onChanged,
    required this.value,
    required this.values,
    this.itemToString,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      items: values.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(
            itemToString?.call(value) ?? value.toString(),
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
