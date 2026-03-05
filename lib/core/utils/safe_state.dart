import 'package:flutter/widgets.dart';

/// A State base class that ignores setState calls after disposal.
///
/// Widgets can extend this instead of [State] to avoid "_dirty is not true"
/// assertions when asynchronous callbacks attempt to update state after the
/// widget has been unmounted.

abstract class SafeState<T extends StatefulWidget> extends State<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }
}