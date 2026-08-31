import 'package:flutter/material.dart';

/// Scaffold padrão do app: insere a área segura de baixo (barra de gestos)
/// sempre, e a de cima só quando não há AppBar (que já se protege sozinha).
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? bottomBar;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        top: appBar == null,
        bottom: bottomBar == null,
        child: body,
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(top: false, child: bottomBar!),
    );
  }
}
