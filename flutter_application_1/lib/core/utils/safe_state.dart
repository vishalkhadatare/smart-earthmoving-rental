import 'package:flutter/material.dart';

/// A [State] mixin that guards [setState] calls —
/// only applies the callback when the widget is still mounted.
abstract class SafeState<T extends StatefulWidget> extends State<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }
}
