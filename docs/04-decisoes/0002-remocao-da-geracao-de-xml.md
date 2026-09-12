# ADR 0002 — Remoção da geração de XML

**Data:** 12/09/2026
**Status:** Aceito

## Contexto

O projeto previa converter a planilha DOF (Excel/CSV) para um XML intermediário,
descrito em detalhe em `docs/03-negocio/esquema-conversao-dof.md` e anunciado
como concluído na documentação do app.

Na prática:

- `xml_generator_service.dart` estava **100% comentado** — 86 linhas inertes.
- `DofConversionService`, citado como orquestrador na documentação,
  **nunca existiu**.
- `exemplos/dof_exemplos_uso.dart` referenciava os dois e era a **única fonte
  dos 3 errors** do `flutter analyze`.
- `DofItemModel.fromXmlElement` não era chamado por ninguém.
- A dependência `xml: ^6.6.1` estava declarada sem uso real.

O fluxo que roda em produção é direto: planilha → parser → `DofItemModel` →
Isar. O XML não participa de nenhuma etapa.

## Decisão

Remover tudo relacionado a XML: o serviço comentado, o use case vazio
`export_dof_to_xml.dart`, o factory `fromXmlElement`, os exemplos quebrados e a
dependência do `pubspec.yaml`.

Decisão validada com o desenvolvedor responsável pela área de fiscalização.

## Consequências

**Positivas**
- `flutter analyze` saiu de 20 issues para 0.
- A documentação deixa de prometer um componente inexistente — risco real de
  questionamento na banca.
- Uma dependência a menos no bundle.

**Negativas**
- Se um órgão regulador exigir XML no futuro, a implementação recomeça do zero.
  O esquema de conversão fica preservado em `docs/03-negocio/` como referência.
