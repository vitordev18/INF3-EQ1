import 'dart:async';

import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/upload-dof');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner_rounded, size: 100, color: AppColors.white),
            const SizedBox(height: 40),
            Text(
              'FISCALIZA',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
            const SizedBox(height: 20),
            Text(
              'Carregando módulos...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
