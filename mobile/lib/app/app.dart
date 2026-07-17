import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class CityBusApp extends StatelessWidget {
  const CityBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CityBus',
      theme: buildTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
