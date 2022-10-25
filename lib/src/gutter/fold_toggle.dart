import 'package:flutter/material.dart';

import 'clickable.dart';

class FoldToggle extends StatelessWidget {
  final Color? color;
  final bool isFolded;
  final VoidCallback onTap;

  const FoldToggle({
    required this.color,
    required this.isFolded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClickableWidget(
      onTap: onTap,
      child: RotatedBox(
        quarterTurns: isFolded ? 0 : 1,
        child: Icon(
          Icons.chevron_right,
          color: color,
          size: 16,
        ),
      ),
    );
  }
}
