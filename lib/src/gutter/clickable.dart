import 'package:flutter/widgets.dart';

/// MouseRegion + GestureDetector.
class ClickableWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ClickableWidget({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
