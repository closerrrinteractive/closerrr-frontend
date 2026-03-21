import 'package:flutter/widgets.dart';

extension WidgetStatePropertyUtils<T> on T {
  /// Converts any value to WidgetStateProperty.all
  WidgetStatePropertyAll<T> asWidgetStatePropertyAll() {
    return WidgetStatePropertyAll<T>(this);
  }
}
