import 'dart:io';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/dof/data/services/dof_conversion_service.dart';
import 'package:app/features/dof/data/services/dof_validator_service.dart';
import 'package:uuid/uuid.dart';

/// Exemplos de uso dos serviços DOF

void exemploConversao() async {
  // Exemplo 1: Converter arquivo Excel/CSV
  print('=== EXEMPLO 1: Conversão de Arquivo ===');

  final file = File('caminho/para/arquivo.xlsx');

  final resultado = await DofConversionService.convertFile(
    file: file,
    customFileName: 'DOF_Madeireira_ABC.xlsx',
  );

  if (resultado.success) {
    print('✅ Conversão realizada com sucesso');
    print('Total de itens: ${resultado.items.length}');
    print('Itens válidos: ${resultado.validationResult?.validItems}');
    print('Tempo: ${resultado.duration.inMilliseconds}ms');

    // Usar o XML gerado
    final xml = resultado.xmlContent;

    // Salvar em arquivo
    await File('saida.xml').writeAsString(xml);
  } else {
    print('❌ Erro: ${resultado.errorMessage}');
  }
}

void exemploValidacao() {
  // Exemplo 2: Validar um item individual
  print('\n=== EXEMPLO 2: Validação de Item ===');

  final item = DofItemModel(
    id: const Uuid().v4(),
    numero: '001',
    produto: 'Tora de Madeira',
    especieCientifico: 'Swietenia macrophylla',
    nomePopular: 'Mogno',
    saldoLivre: 45.80,
    saldoTotal: 100.00,
    unidade: 'm³',
  );

  final validacao = DofValidatorService.validateItem(item);

  if (validacao.isValid) {
    print('✅ Item válido');
  } else {
    print('❌ Erros encontrados:');
    for (var erro in validacao.errors) {
      print('  - $erro');
    }
  }
}

void exemploValidacaoLote() {
  // Exemplo 3: Validar múltiplos itens
  print('\n=== EXEMPLO 3: Validação em Lote ===');

  final items = [
    DofItemModel(
      id: const Uuid().v4(),
      numero: '001',
      produto: 'Tora de Madeira',
      especieCientifico: 'Swietenia macrophylla',
      nomePopular: 'Mogno',
      saldoLivre: 45.80,
      saldoTotal: 100.00,
      unidade: 'm³',
    ),
    DofItemModel(
      id: const Uuid().v4(),
      numero: '002',
      produto: 'Prancha',
      especieCientifico: 'Cedrela odorata',
      nomePopular: 'Cedro',
      saldoLivre: 120.50,
      saldoTotal: 200.00,
      unidade: 'm³',
    ),
    // Item inválido: saldo livre > saldo total
    DofItemModel(
      id: const Uuid().v4(),
      numero: '003',
      produto: '',  // Produto vazio - inválido
      especieCientifico: 'Handroanthus serratifolius',
      nomePopular: 'Ipê Amarelo',
      saldoLivre: 250.00,
      saldoTotal: 150.00,  // Saldo livre > total - inválido
      unidade: 'm³',
    ),
  ];

  final resultado = DofValidatorService.validateBatch(items);

  print('Total de itens: ${resultado.totalItems}');
  print('Itens válidos: ${resultado.validItems}');
  print('Taxa de sucesso: ${resultado.successRate.toStringAsFixed(2)}%');

  if (resultado.invalidItems.isNotEmpty) {
    print('\nItens inválidos:');
    resultado.invalidItems.forEach((index, validacao) {
      print('  Item ${index + 1}:');
      for (var erro in validacao.errors) {
        print('    - $erro');
      }
    });
  }
}

void exemploXmlGeneration() {
  // Exemplo 4: Gerar XML manualmente
  print('\n=== EXEMPLO 4: Geração de XML ===');

  final items = [
    DofItemModel(
      id: '550e8400-e29b-41d4-a716-446655440001',
      numero: '001',
      produto: 'Tora & Prancha',  // Caractere especial & será escapado
      especieCientifico: 'Swietenia macrophylla',
      nomePopular: 'Mogno < Premium >',  // <, > serão escapados
      saldoLivre: 45.80,
      saldoTotal: 100.00,
      unidade: 'm³',
    ),
  ];

  final xml = XmlGeneratorService.generateDofXml(
    items: items,
    originalFileName: 'DOF_Teste.xlsx',
    importDate: DateTime.now(),
  );

  print('XML Gerado:');
  print(xml);
}

void exemploFormatoDados() {
  // Exemplo 5: Demonstrar formato de dados
  print('\n=== EXEMPLO 5: Formato de Dados ===');

  final item = DofItemModel(
    id: const Uuid().v4(),
    numero: '001',
    produto: 'Tora de Madeira',
    especieCientifico: 'Swietenia macrophylla',
    nomePopular: 'Mogno',
    saldoLivre: 45.80,
    saldoTotal: 100.00,
    unidade: 'm³',
  );

  // Converter para JSON
  final json = item.toJson();
  print('JSON: $json');

  // Criar a partir de JSON
  final itemFromJson = DofItemModel.fromJson(json);
  print('Item recuperado: ${itemFromJson.nomePopular}');

  // Copiar com modificações
  final itemModificado = item.copyWith(
    saldoLivre: 50.00,
    nomePopular: 'Mogno Premium',
  );
  print('Item modificado: ${itemModificado.nomePopular} (${itemModificado.saldoLivre} m³)');
}

// Execute os exemplos
void main() {
  print('╔════════════════════════════════════════╗');
  print('║  Exemplos de Uso - Sistema DOF         ║');
  print('╚════════════════════════════════════════╝');

  exemploValidacao();
  exemploValidacaoLote();
  exemploXmlGeneration();
}
