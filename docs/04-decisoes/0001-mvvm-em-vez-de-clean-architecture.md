# ADR 0001 — MVVM + Repository em vez de Clean Architecture completa

**Data:** 12/09/2026
**Status:** Aceito

## Contexto

O repositório acumulou três convenções arquiteturais concorrentes:

1. **Clean Architecture completa** — `domain/repositories/`, `domain/usecases/`,
   `data/repositories/`, com **6 arquivos de 0 byte**: a estrutura foi anunciada
   mas nunca preenchida.
2. **Riverpod "providers por feature"** — `fiscalizacao_providers.dart` com 763
   linhas reunindo providers, quatro classes de estado e o Notifier.
3. **MVVM** — adotado espontaneamente pela equipe nas últimas sprints
   (`upload_dof_viewmodel.dart`, `medidas_viewmodel.dart`).

Cada tela nova exigia decidir "onde eu ponho isso?", com três respostas
defensáveis. Numa equipe de 7 pessoas isso custa revisão e gera conflito de
merge.

## Decisão

Adotar **MVVM + Repository, feature-first**, alinhado à orientação oficial de
arquitetura do Flutter: duas camadas obrigatórias — UI (View + ViewModel) e
Data (Repository + Service) — com `domain/` reservado a **regras de negócio
puras e testáveis**, não a interfaces de passagem.

Consequentemente:

- Os 4 stubs de Clean Architecture foram **removidos**, não preenchidos.
- `*_local_datasource.dart` virou `*_repository.dart`.
- O sufixo único para estado de tela é `ViewModel` — nada de `Notifier` ou
  `Controller`.

## Consequências

**Positivas**
- Uma única resposta para "onde ponho isso?", documentada no plano.
- A regra que decide `concluido` vs. `excedente` virou função pura
  (`domain/calculo_status.dart`) e ganhou teste sem banco.
- Menos indireção: o caminho da tela ao dado tem 2 saltos, não 4.

**Negativas**
- Sem *use cases*, lógica compartilhada entre ViewModels precisa de disciplina
  para não ser duplicada — o lugar dela é `domain/`.
- Se o app crescer para dezenas de features, a decisão deve ser reavaliada.
