import 'package:flutter/material.dart';

extension StringX on String {
  String get path => '/$this';
}

extension BuildContextX on BuildContext {
  /// Theme.of(context)
  ThemeData get theme => Theme.of(this);

  /// MediaQuery.of(context)
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// NavigationBarTheme.of(this)
  NavigationBarThemeData get navigationBarTheme => NavigationBarTheme.of(this);
}
