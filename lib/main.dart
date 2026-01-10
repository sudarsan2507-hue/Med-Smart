import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: SmartMedApp()));
}

class SmartMedApp extends ConsumerWidget {
  const SmartMedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SmartMed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.vibrantTheme,
      routerConfig: goRouter,
    );
  }
}
