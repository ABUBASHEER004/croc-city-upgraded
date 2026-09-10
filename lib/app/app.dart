import 'package:flutter/material.dart';

import 'go_router.dart';
import 'theme.dart';

class CrocCityFootballAcademy extends StatelessWidget {
  const CrocCityFootballAcademy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Croc City Football Academy",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}