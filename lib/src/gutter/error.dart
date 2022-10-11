import 'package:flutter/material.dart';

class GutterErrorWidget extends StatelessWidget {
  const GutterErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.cancel,
      color: Colors.red,
      size: 16,
    );
  }
}
