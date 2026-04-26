# Adaptação das Funcionalidades DOF - FISCALIZA

## 📋 Resumo

Implementadas as funcionalidades de conversão DOF conforme o esquema fornecido (Esquema-Conversão.md). O sistema agora suporta:

- ✅ **Parsing de Excel e CSV** com normalização de colunas
- ✅ **Validação rigorosa** de dados com regras de negócio
- ✅ **Geração de XML** bem-formatado com escape de caracteres especiais
- ✅ **Geração de UUIDs** únicos para cada item
- ✅ **Log detalhado** do processo de conversão
- ✅ **Tratamento de vírgula brasileira** (números decimais)

---

## 🗂️ Estrutura de Arquivos Criados

```
lib/features/dof/
├── domain/
│   └── entities/
│       └── dof_item.dart              # Entidade de domínio
├── data/
│   ├── models/
│   │   └── dof_item_model.dart       # Modelo de dados com JSON/XML conversion
│   └── services/
│       ├── csv_parser_service.dart    # Parser para CSV
│       ├── excel_parser_service.dart  # Parser para Excel
│       ├── xml_generator_service.dart # Gerador de XML
│       ├── dof_validator_service.dart # Validador de dados
│       └── dof_conversion_service.dart # Orquestrador da conversão
└── presentation/
    └── screens/
        └── upload_dof_screen.dart     # Tela atualizada com novos serviços
```

---

## 🔧 Componentes Principais

### 1. **DofItem** (Entidade de Domínio)
- Representa um item DOF com campos: id, numero, produto, especieCientifico, nomePopular, saldoLivre, saldoTotal, unidade
- Imutável e segura

### 2. **DofItemModel** (Camada de Dados)
- Estende DofItem
- Métodos: `fromJson()`, `toJson()`, `fromXmlElement()`, `copyWith()`
- Conversão automática de tipos e tratamento de valores nulos

### 3. **CsvParserService**
- Parse de arquivos CSV
- Normalização flexível de nomes de coluna
- Suporte a vírgula brasileira para decimais
- Logs detalhados de processamento

### 4. **ExcelParserService**
- Parse de arquivos Excel (.xlsx, .xls)
- Extrai primeira planilha automaticamente
- Mesmas funcionalidades do CSV com suporte a células Excel

### 5. **DofValidatorService**
- Valida campos obrigatórios (não vazios)
- Valida valores numéricos (>= 0)
- Valida regra: Saldo Livre ≤ Saldo Total
- Validação em lote com relatório de sucesso

### 6. **XmlGeneratorService**
- Gera XML bem-formado conforme o esquema
- Escapa caracteres especiais (&, <, >, ", ')
- Normaliza unidades (m³ → m3)
- Metadata automática (dataImportacao, totalItens, etc)
- Pretty print com indentação

### 7. **DofConversionService**
- Orquestrador principal
- Detecção automática de formato (CSV/Excel)
- Coordena: Parsing → Validação → Geração XML
- Logs estruturados com fase de processamento
- Retorna `DofConversionResult` com sucesso/erro

---

## 📊 Fluxo de Conversão

```
Arquivo (Excel/CSV)
    ↓
[Parser] - Detecta formato, normaliza colunas
    ↓
[Validador] - Valida cada item
    ↓
[Gerador XML] - Cria estrutura XML
    ↓
XML Formatado com Metadata
```

---

## 🎯 Uso na Tela de Upload

```dart
// Seleção de arquivo
final file = File(result.files.single.path!);

// Conversão completa
final conversionResult = await DofConversionService.convertFile(
  file: file,
  customFileName: fileName,
);

// Resultado
if (conversionResult.success) {
  final xmlContent = conversionResult.xmlContent;
  final items = conversionResult.items;
  final validationResult = conversionResult.validationResult;
}
```

---

## 📝 Exemplo de Saída XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dof>
  <metadata>
    <dataImportacao>2026-04-10T19:30:15.234Z</dataImportacao>
    <totalItens>5</totalItens>
    <nomeArquivoOrigem>DOF_Madeireira_ABC_2024.xlsx</nomeArquivoOrigem>
    <versaoSchema>1.0</versaoSchema>
  </metadata>
  <itens>
    <item>
      <id>550e8400-e29b-41d4-a716-446655440001</id>
      <numero>001</numero>
      <produto>Tora de Madeira</produto>
      <especieCientifico>Swietenia macrophylla</especieCientifico>
      <nomePopular>Mogno</nomePopular>
      <saldoLivre>45.80</saldoLivre>
      <saldoTotal>100.00</saldoTotal>
      <unidade>m3</unidade>
    </item>
    <!-- ... mais itens ... -->
  </itens>
</dof>
```

---

## 📋 Validações Implementadas

| Validação | Regra |
|-----------|-------|
| Campos Obrigatórios | numero, produto, especieCientifico, nomePopular, saldoLivre, saldoTotal, unidade |
| Texto Não Vazio | Todos os campos de texto devem ter conteúdo |
| Valores Positivos | saldoLivre >= 0 e saldoTotal >= 0 |
| Lógica de Negócio | saldoLivre <= saldoTotal |
| Unidade Padrão | Se vazio, usa "m³" |
| Vírgula Brasileira | Aceita "45,80" e converte para 45.80 |
| Caracteres Especiais | XML escapa & < > " ' |

---

## 🔍 Normalização de Cabeçalhos

O sistema reconhece variações de nomes de coluna:

| Campo Original | Variações Reconhecidas |
|----------------|------------------------|
| numero | número, num, order, id |
| produto | product, tipo |
| especieCientifico | especie, scientific, nome científico |
| nomePopular | common_name, popular, common |
| saldoLivre | saldo livre, free balance, disponível |
| saldoTotal | saldo total, total balance |
| unidade | unit, un |

---

## 📱 Logs Console

O sistema gera logs estruturados em 5 fases:

```
[FISCALIZA] 🚀 Iniciando conversão DOF...
[FISCALIZA] ⚙️ FASE 1: PARSING
[FISCALIZA] ⚙️ FASE 2: EXTRAÇÃO DE DADOS
[FISCALIZA] ⚙️ FASE 3: VALIDAÇÃO
[FISCALIZA] ⚙️ FASE 4: GERAÇÃO DE XML
[FISCALIZA] ⚙️ FASE 5: PERSISTÊNCIA
[FISCALIZA] ✅ CONVERSÃO CONCLUÍDA COM SUCESSO
```

---

## 🚀 Próximos Passos

1. **Integração com Isar Database** - Salvar itens validados
2. **Salvar XML em arquivo** - Sistema de arquivos ou cloud
3. **Validar XML gerado** - Contra schema XSD (se houver)
4. **Recuperação de dados** - Ler XML e repopular modelo
5. **Sincronização** - Entre arquivo XML e banco de dados

---

## ✅ Checklist de Funcionalidades

- [x] Parsing de Excel com normalização
- [x] Parsing de CSV com normalização
- [x] Validação de campos obrigatórios
- [x] Validação de tipos numéricos
- [x] Validação de regras de negócio
- [x] Geração de UUIDs
- [x] Escape de caracteres XML
- [x] Metadata automática
- [x] Logs estruturados por fase
- [x] Tratamento de vírgula brasileira
- [x] Unidade padrão (m³)
- [x] Suporte a valores vazios com padrões
- [x] Interface de tela atualizada

---

**Versão:** 1.0  
**Data:** 2026-04-26  
**Status:** ✅ Implementação completa conforme esquema
