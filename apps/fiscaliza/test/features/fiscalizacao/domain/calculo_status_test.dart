import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/fiscalizacao/domain/calculo_status.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

void main() {
  group('calcularStatus — medição incompleta', () {
    test('nenhuma peça contada mantém em andamento', () {
      expect(
        calcularStatus(
          volumeMedidoM3: 0,
          saldoDeclaradoM3: 10,
          pecasContadas: 0,
          pecasMedidas: 0,
        ),
        StatusFiscalizacao.emAndamento,
      );
    });

    test('peças medidas abaixo das contadas mantém em andamento', () {
      expect(
        calcularStatus(
          volumeMedidoM3: 2.5,
          saldoDeclaradoM3: 10,
          pecasContadas: 10,
          pecasMedidas: 4,
        ),
        StatusFiscalizacao.emAndamento,
      );
    });

    test('tudo contado mas volume zero mantém em andamento', () {
      expect(
        calcularStatus(
          volumeMedidoM3: 0,
          saldoDeclaradoM3: 10,
          pecasContadas: 5,
          pecasMedidas: 5,
        ),
        StatusFiscalizacao.emAndamento,
      );
    });
  });

  group('calcularStatus — medição completa', () {
    test('volume abaixo do saldo declarado conclui', () {
      expect(
        calcularStatus(
          volumeMedidoM3: 7.4,
          saldoDeclaradoM3: 10,
          pecasContadas: 5,
          pecasMedidas: 5,
        ),
        StatusFiscalizacao.concluido,
      );
    });

    test('volume exatamente igual ao saldo conclui (fronteira)', () {
      expect(
        calcularStatus(
          volumeMedidoM3: 10,
          saldoDeclaradoM3: 10,
          pecasContadas: 5,
          pecasMedidas: 5,
        ),
        StatusFiscalizacao.concluido,
      );
    });

    test('volume acima do saldo declarado marca excedente', () {
      expect(
        calcularStatus(
          volumeMedidoM3: 10.01,
          saldoDeclaradoM3: 10,
          pecasContadas: 5,
          pecasMedidas: 5,
        ),
        StatusFiscalizacao.excedente,
      );
    });

    test('mais peças medidas que contadas ainda avalia o volume', () {
      expect(
        calcularStatus(
          volumeMedidoM3: 12,
          saldoDeclaradoM3: 10,
          pecasContadas: 5,
          pecasMedidas: 7,
        ),
        StatusFiscalizacao.excedente,
      );
    });

    test('saldo declarado zero com volume medido é excedente', () {
      expect(
        calcularStatus(
          volumeMedidoM3: 0.5,
          saldoDeclaradoM3: 0,
          pecasContadas: 1,
          pecasMedidas: 1,
        ),
        StatusFiscalizacao.excedente,
      );
    });
  });
}
