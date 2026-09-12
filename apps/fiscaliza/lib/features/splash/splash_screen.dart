import 'package:fiscaliza/app/router/app_routes.dart';
import 'dart:async';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _duration = Duration(milliseconds: 1200);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_duration, () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Image.asset(
          'assets/icons/Logomarca.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
