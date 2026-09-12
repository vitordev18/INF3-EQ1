import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

/// Confronta o volume cubado em campo com o saldo declarado no DOF:
/// abaixo ou igual ao saldo o item é [StatusFiscalizacao.concluido]; acima,
/// [StatusFiscalizacao.excedente] — madeira além do autorizado. Enquanto
/// houver peça contada sem medição, permanece [StatusFiscalizacao.emAndamento].
StatusFiscalizacao calcularStatus({
  required double volumeMedidoM3,
  required double saldoDeclaradoM3,
  required int pecasContadas,
  required int pecasMedidas,
}) {
  final todasMedidas = pecasContadas > 0 && pecasMedidas >= pecasContadas;

  if (!todasMedidas || volumeMedidoM3 == 0.0) {
    return StatusFiscalizacao.emAndamento;
  }
  if (volumeMedidoM3 <= saldoDeclaradoM3) {
    return StatusFiscalizacao.concluido;
  }
  return StatusFiscalizacao.excedente;
}
