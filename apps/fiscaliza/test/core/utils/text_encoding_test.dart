import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/core/utils/text_encoding.dart';

void main() {
  group('repararEncoding — repara UTF-8 lido como Latin-1', () {
    test('nome popular com acento', () {
      expect(repararEncoding('CupiÃºba'), 'Cupiúba');
    });

    test('espécie com acento', () {
      expect(repararEncoding('EspÃ©cie'), 'Espécie');
    });

    test('cedilha', () {
      expect(repararEncoding('ConservaÃ§Ã£o'), 'Conservação');
    });

    test('ordinal do cabeçalho', () {
      expect(repararEncoding('NÂº'), 'Nº');
    });

    test('unidade de volume', () {
      expect(repararEncoding('mÂ³'), 'm³');
    });

    test('frase inteira', () {
      expect(
        repararEncoding('Madeira serrada de cupiÃºba e jatobÃ¡'),
        'Madeira serrada de cupiúba e jatobá',
      );
    });
  });

  group('repararEncoding — preserva texto já correto', () {
    test('texto acentuado íntegro não é alterado', () {
      for (final texto in [
        'Cupiúba',
        'Espécie (Científico)',
        'Conservação',
        'm³',
        'Jatobá',
        'Nº',
      ]) {
        expect(repararEncoding(texto), texto, reason: texto);
      }
    });

    test('texto sem acento não é alterado', () {
      expect(repararEncoding('Madeira serrada'), 'Madeira serrada');
      expect(repararEncoding('Goupia glabra'), 'Goupia glabra');
    });

    test('vazio não quebra', () {
      expect(repararEncoding(''), '');
    });

    test('números e símbolos comuns passam intactos', () {
      expect(repararEncoding('12.345.678/0001-90'), '12.345.678/0001-90');
      expect(repararEncoding('32.13'), '32.13');
    });
  });
}
