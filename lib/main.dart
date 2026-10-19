import 'package:cdcare_address_demo/core/theme/app_theme.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: CdcareAddressDemoApp()));
}

class CdcareAddressDemoApp extends StatelessWidget {
  const CdcareAddressDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CDcare Address Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ProductScreen(),
    );
  }
}
