import 'package:flutter/material.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

class StatusPill extends StatelessWidget {
  final StatusFiscalizacao status;

  const StatusPill(this.status, {super.key});

  static Color colorFor(StatusFiscalizacao status) {
    switch (status) {
      case StatusFiscalizacao.pendente:
        return Colors.grey.shade600;
      case StatusFiscalizacao.emAndamento:
        return Colors.orange.shade700;
      case StatusFiscalizacao.concluido:
        return AppColors.green;
      case StatusFiscalizacao.excedente:
        return Colors.red.shade700;
    }
  }

  static String textFor(StatusFiscalizacao status) {
    switch (status) {
      case StatusFiscalizacao.pendente:
        return 'Pendente';
      case StatusFiscalizacao.emAndamento:
        return 'Em Andamento';
      case StatusFiscalizacao.concluido:
        return 'Concluído';
      case StatusFiscalizacao.excedente:
        return 'Excedente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: colorFor(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        textFor(status),
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}
