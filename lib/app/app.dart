import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'go_router.dart';
import 'theme.dart';
import 'theme_controller.dart';

class CrocCityFootballAcademy extends StatelessWidget {
  const CrocCityFootballAcademy({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return MaterialApp.router(
      title: 'Croc City Football Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.mode,
      routerConfig: AppRouter.router,
    );
  }
}