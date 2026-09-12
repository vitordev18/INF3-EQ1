# Importação do DOF — estado real da implementação

**Atualizado em:** 12/09/2026

> Versões anteriores deste documento declaravam "✅ PRONTO PARA PRODUÇÃO" e
> listavam um gerador de XML e um orquestrador de conversão como concluídos.
> Nenhum dos dois existia no código. Esta versão descreve **apenas o que está
> implementado e rodando**.

## Status por componente

| Componente | Status | Arquivo |
|---|---|---|
| Parser CSV | ✅ Implementado | `features/dof/data/services/csv_parser_service.dart` |
| Parser Excel (.xlsx/.xls) | ✅ Implementado | `features/dof/data/services/excel_parser_service.dart` |
| Normalização de cabeçalhos | ✅ Implementado | ambos os parsers |
| Geração de UUID por item | ✅ Implementado | ambos os parsers |
| Vírgula decimal brasileira | ✅ Implementado | ambos os parsers |
| Persistência no Isar | ✅ Implementado | `features/dof/data/dof_repository.dart` |
| Validador de itens | ⚠️ Implementado e **testado**, ainda **não integrado** ao fluxo de upload | `features/dof/domain/dof_validator.dart` |
| Geração de XML | ❌ Removida — ver [ADR 0002](../04-decisoes/0002-remocao-da-geracao-de-xml.md) | — |
| Orquestrador de conversão | ❌ Nunca existiu | — |

## Fluxo que roda hoje

```
Planilha (.xlsx / .xls / .csv)
        ↓
  FilePicker  →  UploadDofViewModel
        ↓
  CsvParserService | ExcelParserService
        ↓  (normaliza colunas, gera UUID, trata vírgula decimal)
  List<DofItemModel>
        ↓
  DofRepository.saveDofItems()  →  Isar
        ↓
  Hub de Fiscalização
```

Não há etapa de XML em nenhum ponto.

## Colunas obrigatórias

Os parsers reconhecem variações de nome e exigem a presença de:

`numero` · `produto` · `especieCientifico` · `nomePopular` · `saldoLivre` · `saldoTotal`

`unidade` é opcional e assume `m³` quando ausente.

| Campo | Variações reconhecidas |
|---|---|
| `numero` | número, num, id, nº |
| `produto` | produto, product |
| `especieCientifico` | especie, científico, scientific |
| `nomePopular` | popular, common |
| `saldoLivre` | saldo livre, free, disponível |
| `saldoTotal` | saldo total, total |
| `unidade` | unidade, unit |

## Regras do validador

Implementadas em `DofValidator` e cobertas por
`test/features/dof/domain/dof_validator_test.dart`:

- Campos de texto obrigatórios não podem ser vazios.
- `saldoLivre >= 0` e `saldoTotal >= 0`.
- `saldoLivre <= saldoTotal`.
- `unidade` não pode ser vazia.
- `validateBatch` devolve a taxa de sucesso e os índices inválidos.

> **Pendência conhecida:** a tela de upload ainda não chama o `DofValidator`.
> Integrá-lo é pré-requisito da tela de Validação (Fase 4 do plano).

## Referências

- [Esquema de conversão do DOF](../03-negocio/esquema-conversao-dof.md) — formato da planilha de origem
- [Plano de reestruturação](PLANO-DE-REESTRUTURACAO.md)
