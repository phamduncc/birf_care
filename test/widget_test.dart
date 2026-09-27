import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bird_care/core/theme/app_theme.dart';

void main() {
  testWidgets('App Theme Light and Dark configuration test', (WidgetTester tester) async {
    final lightTheme = AppTheme.lightTheme;
    final darkTheme = AppTheme.darkTheme;

    expect(lightTheme.brightness, Brightness.light);
    expect(darkTheme.brightness, Brightness.dark);
  });
}
