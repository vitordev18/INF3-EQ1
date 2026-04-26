import 'package:app/features/dof/data/models/dof_item_model.dart';

class DofValidatorService {
  static const List<String> _requiredFields = [
    'numero',
    'produto',
    'especieCientifico',
    'nomePopular',
    'saldoLivre',
    'saldoTotal',
  ];

  /// Valida um item DOF completo
  static ValidationResult validateItem(DofItemModel item) {
    final errors = <String>[];

    // Validar campos de texto não vazios
    if (item.numero.trim().isEmpty) {
      errors.add('Campo "Número" não pode estar vazio');
    }
    if (item.produto.trim().isEmpty) {
      errors.add('Campo "Produto" não pode estar vazio');
    }
    if (item.especieCientifico.trim().isEmpty) {
      errors.add('Campo "Espécie (Científico)" não pode estar vazio');
    }
    if (item.nomePopular.trim().isEmpty) {
      errors.add('Campo "Nome Popular" não pode estar vazio');
    }

    // Validar valores numéricos
    if (item.saldoLivre < 0) {
      errors.add('Saldo Livre deve ser >= 0');
    }
    if (item.saldoTotal < 0) {
      errors.add('Saldo Total deve ser >= 0');
    }

    // Validar regra de negócio: Saldo Livre <= Saldo Total
    if (item.saldoLivre > item.saldoTotal) {
      errors.add('Saldo Livre não pode ser maior que Saldo Total');
    }

    // Validar unidade
    if (item.unidade.trim().isEmpty) {
      errors.add('Campo "Unidade" não pode estar vazio');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida uma lista de itens
  static ValidationBatchResult validateBatch(List<DofItemModel> items) {
    int validCount = 0;
    final invalidItems = <int, ValidationResult>{};

    for (int i = 0; i < items.length; i++) {
      final result = validateItem(items[i]);
      if (result.isValid) {
        validCount++;
      } else {
        invalidItems[i] = result;
      }
    }

    return ValidationBatchResult(
      totalItems: items.length,
      validItems: validCount,
      invalidItems: invalidItems,
      successRate: items.isEmpty ? 0 : (validCount / items.length * 100),
    );
  }

  /// Obtém campos obrigatórios
  static List<String> getRequiredFields() => _requiredFields;

  /// Valida se todas as colunas obrigatórias estão presentes
  static bool hasAllRequiredColumns(List<String> headers) {
    final lowerHeaders = headers.map((h) => h.toLowerCase()).toList();

    return _requiredFields.every((field) {
      return lowerHeaders.any((header) {
        final normalizedHeader = header.toLowerCase();
        return normalizedHeader.contains(field) ||
               _columnMappings[field]?.any((alt) => normalizedHeader.contains(alt)) == true;
      });
    });
  }

  /// Mapeamento de nomes de colunas alternativas
  static const Map<String, List<String>> _columnMappings = {
    'numero': ['número', 'num', 'order', 'id', 'nº'],
    'produto': ['product', 'tipo'],
    'especieCientifico': ['especie', 'scientific', 'nome científico'],
    'nomePopular': ['common_name', 'popular', 'common'],
    'saldoLivre': ['saldo livre', 'free balance', 'disponível'],
    'saldoTotal': ['saldo total', 'total balance'],
  };
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  @override
  String toString() => 'ValidationResult(isValid: $isValid, errors: $errors)';
}

class ValidationBatchResult {
  final int totalItems;
  final int validItems;
  final Map<int, ValidationResult> invalidItems;
  final double successRate;

  ValidationBatchResult({
    required this.totalItems,
    required this.validItems,
    required this.invalidItems,
    required this.successRate,
  });

  @override
  String toString() => '''ValidationBatchResult(
    totalItems: $totalItems,
    validItems: $validItems,
    successRate: ${successRate.toStringAsFixed(2)}%
  )''';
}
