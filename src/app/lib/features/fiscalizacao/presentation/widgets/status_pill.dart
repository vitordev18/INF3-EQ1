import 'package:flutter/material.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

/// Pill de status (Pendente / Em Andamento / Concluído / Excedente): fundo
/// sólido colorido, texto branco, totalmente arredondado — 1:1 com a classe
/// `.pill.pill-*` do mockup `fiscaliza-plano-historico`.
///
/// Usado no Hub de Início, na FiscalizacaoHubScreen e na
/// ConcluirFiscalizacaoScreen. Fica em `features/fiscalizacao/presentation`
/// (não em `core/widgets`) porque depende do enum [StatusFiscalizacao], que
/// é específico dessa feature — `core` não deve depender de `features/*`.
///
/// [colorFor] e [textFor] são expostos como estáticos porque outros lugares
/// da tela de fiscalização (ex.: o ícone e o texto da linha "Volume Total")
/// precisam da mesma cor do status sem necessariamente renderizar o pill.
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
