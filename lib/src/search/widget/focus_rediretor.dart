import 'package:flutter/material.dart';

/// This widget wraps the child with [InkWell] and
/// redirects the focus to [redirectTo] when receiving onTap events.
///
/// This is needed in order not to lose focus from [redirectTo],
/// when the user misclicks on other areas of the widget.
class FocusRedirector extends StatelessWidget {
  final Widget child;
  final FocusNode redirectTo;

  const FocusRedirector({
    super.key,
    required this.child,
    required this.redirectTo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: MouseCursor.defer,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: redirectTo.requestFocus,
      child: child,
    );
  }
}
