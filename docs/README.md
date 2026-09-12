# Documentação — FISCALIZA

App Flutter de apoio à fiscalização de madeireiras pela Polícia Ambiental.
Projeto de TCC da equipe INF3-EQ1 — CTI Prof. Isaac Portal Roldán.

## Índice

### 00 — Produto
- [Diagrama de casos de uso](00-produto/diagrama-casos-de-uso.png)
- [Casos de uso e manual de usabilidade](00-produto/casos-de-uso-e-manual-de-usabilidade.pdf)

### 01 — Gestão
- [Definição dos papéis](01-gestao/definicao-dos-papeis.pdf)
- [Planilha de avaliação](01-gestao/planilha-de-avaliacao.url)

### 02 — Arquitetura
- [Plano de reestruturação](02-arquitetura/PLANO-DE-REESTRUTURACAO.md) — diagnóstico, estrutura-alvo e execução em fases
- [Documentação técnica](02-arquitetura/documentacao-tecnica.pdf)
- [Implementação do DOF](02-arquitetura/dof-implementacao.md) — parsers, validação e status real de cada componente

### 03 — Negócio
- [Esquema de conversão do DOF](03-negocio/esquema-conversao-dof.md)

### 04 — Decisões (ADR)
- [0001 — MVVM em vez de Clean Architecture completa](04-decisoes/0001-mvvm-em-vez-de-clean-architecture.md)
- [0002 — Remoção da geração de XML](04-decisoes/0002-remocao-da-geracao-de-xml.md)

## Código

O app vive em [`apps/fiscaliza/`](../apps/fiscaliza). Para rodar:

```bash
cd apps/fiscaliza
flutter pub get
flutter run
```

Antes de abrir PR, rode a mesma verificação da CI:

```powershell
.\tools\check.ps1
```
