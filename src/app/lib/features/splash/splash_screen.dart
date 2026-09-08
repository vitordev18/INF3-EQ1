import 'dart:async';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tela de carregamento inicial: só a logo da Fiscaliza centralizada em
/// fundo branco. Não tem nenhuma interação — depois de um breve intervalo,
/// navega sozinha para o Hub de Início (`/home`). Busca de madeireira e
/// upload de DOF já vivem lá / em `/upload-dof`.
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
      if (mounted) context.go('/home');
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
