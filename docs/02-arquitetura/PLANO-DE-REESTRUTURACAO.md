# Plano de Reestruturação e Organização — FISCALIZA

**Projeto:** FISCALIZA — App de apoio à fiscalização de madeireiras (Polícia Ambiental)
**Repositório:** `INF3-EQ1` — TCC, Curso Técnico de Informática, CTI Prof. Isaac Portal Roldán
**Documento:** Plano de reestruturação de diretórios e arquitetura
**Autor:** Tech Lead / Desenvolvimento
**Data:** 07/09/2026
**Versão:** 1.0
**Status:** Proposta para aprovação da equipe

---

## Sumário

1. [Sumário executivo](#1-sumário-executivo)
2. [Baseline: estado atual medido](#2-baseline-estado-atual-medido)
3. [Diagnóstico](#3-diagnóstico)
4. [Princípios que guiam a proposta](#4-princípios-que-guiam-a-proposta)
5. [Estrutura-alvo do repositório](#5-estrutura-alvo-do-repositório)
6. [Estrutura-alvo do código (`lib/`)](#6-estrutura-alvo-do-código-lib)
7. [Estrutura-alvo dos testes](#7-estrutura-alvo-dos-testes)
8. [Estrutura-alvo da documentação](#8-estrutura-alvo-da-documentação)
9. [Mapa de-para completo](#9-mapa-de-para-completo)
10. [Convenções de código e nomenclatura](#10-convenções-de-código-e-nomenclatura)
11. [Plano de execução em fases](#11-plano-de-execução-em-fases)
12. [Riscos e mitigações](#12-riscos-e-mitigações)
13. [Não-objetivos (fora de escopo agora)](#13-não-objetivos-fora-de-escopo-agora)
14. [Anexos](#14-anexos)

---

## 1. Sumário executivo

### 1.1 O problema

O FISCALIZA funciona e resolve um problema real: comparar o **volume declarado no DOF** com o **volume cubado em campo**, apontando o status `excedente` quando há madeira além do autorizado. O código que entrega isso tem qualidade — visão computacional embarcada, persistência local, undo, cascade delete, reindexação de fotos.

O problema não é o *que* foi construído, é *onde* cada coisa mora. O repositório acumulou **três convenções arquiteturais concorrentes** ao longo das sprints:

| Convenção | Vestígios no código |
|---|---|
| Clean Architecture completa | `domain/repositories/`, `domain/usecases/`, `data/repositories/` — **6 arquivos, todos com 0 bytes** |
| Riverpod "providers por feature" | `presentation/providers/fiscalizacao_providers.dart` — 535 linhas com providers + 4 classes de estado + o Notifier |
| MVVM (adotado nas últimas sprints) | `presentation/viewmodels/upload_dof_viewmodel.dart`, `medidas_viewmodel.dart` |

Cada nova tela hoje exige uma decisão de "onde eu ponho isso?", e as três respostas são defensáveis. Isso custa tempo de revisão, gera conflito de merge e não escala para os 7 integrantes da equipe.

### 1.2 A proposta em uma frase

> **Adotar a arquitetura oficial recomendada pelo Flutter (MVVM + Repository, feature-first), eliminar as camadas vazias de Clean Architecture, extrair um Design System de dentro do `core/`, e promover `src/app` a `apps/fiscaliza` no padrão de monorepo — em 4 fases incrementais, cada uma com o app funcionando ao final.**

### 1.3 Por que MVVM + Repository, e não Clean Architecture completa

A equipe **já começou a migrar** para ViewModels por conta própria (`upload_dof_viewmodel.dart`, `medidas_viewmodel.dart`). Essa direção coincide com a orientação oficial de arquitetura do Flutter, que recomenda duas camadas obrigatórias — **UI (View + ViewModel)** e **Data (Repository + Service)** — com camada de domínio (*use cases*) apenas **opcional**, quando há lógica compartilhada entre ViewModels.

Manter a Clean Architecture completa neste projeto significaria preencher 6 arquivos hoje vazios com código de passagem (`DofRepository` → `DofRepositoryImpl` → `LoadDofFromExcel` → ViewModel) para um app com 3 coleções no banco e 7 telas. O custo de cerimônia não se paga; o custo de manter camadas vazias no repositório, sim — elas confundem quem chega e sugerem que existe uma estrutura que não existe.

**Decisão: MVVM + Repository, com `domain/` reservado para regras de negócio puras e testáveis** (cálculo de status, validação de DOF, perfis de peça) — não para interfaces de passagem.

### 1.4 Ganhos esperados

| Ganho | Como se mede |
|---|---|
| Onboarding de integrante em nova tela | "Onde ponho isso?" tem **uma** resposta documentada |
| Menos conflito de merge | Arquivos de 1.400 linhas quebrados por responsabilidade |
| Regra de negócio testável sem banco | Cálculo de status sai do datasource Isar → função pura |
| Consistência visual entre telas | `AppTheme` aplicado (hoje é código morto) + Design System |
| Entregável instalável | Fim do `applicationId = com.example.app` |
| Confiança em refatorar | CI rodando `analyze` + `test` a cada push |

### 1.5 Custo e cronograma

| Fase | Escopo | Esforço | Risco | Move arquivos? |
|---|---|---|---|---|
| **0** | Estabilização e guard-rails | 1–2 dias | 🟢 Baixo | Não |
| **1** | Identidade do produto | 0,5 dia | 🟡 Médio | Não |
| **2** | Reorganização do `lib/` | 3–4 dias | 🟡 Médio | Sim |
| **3** | Reorganização do repositório | 0,5–1 dia | 🟢 Baixo | Sim |
| **4** | Telas e features habilitadas | contínuo | — | Não |

**Total até o repositório reorganizado: ~6 dias de trabalho concentrado.** As fases 0 e 1 entregam valor imediato mesmo se as demais forem adiadas.

---

## 2. Baseline: estado atual medido

Medições feitas em 07/09/2026, no commit `2d75fb6`, para servir de linha de base e permitir verificar o efeito de cada fase.

| Métrica | Valor atual |
|---|---|
| Arquivos `.dart` em `lib/` | 43 |
| Linhas totais em `lib/` | 10.188 |
| Linhas geradas (`.g.dart`, Isar) | 4.588 (45%) |
| Linhas escritas à mão | ~5.600 |
| Arquivos com 0 byte (stubs) | 6 |
| Maior arquivo escrito à mão | `captura_screen.dart` — 1.406 linhas |
| `flutter analyze` | **52 issues**: 3 errors, 1 warning, 48 infos |
| Origem dos 3 errors | 100% em `exemplos/dof_exemplos_uso.dart` (fora do `lib/`) |
| `flutter test` | **18 testes, todos passando** ✅ |
| Telas navegáveis | 5 (Splash, Upload DOF, Hub, Captura, Medidas) |
| Telas stub (0 byte) | 2 (Cadastro, Validação) |
| Coleções Isar | 3 (`DofItemModel`, `FiscalizacaoRegistroModel`, `MedicaoGrupoModel`) |

**A suíte de testes verde é o ativo mais importante deste plano.** Ela é a rede de segurança que torna a reestruturação segura: nenhuma fase é considerada concluída sem os 18 testes passando.

---

## 3. Diagnóstico

### 3.1 Nível repositório

```
INF3-EQ1/
├── docs/            3 arquivos binários (PDF/PNG), sem índice, sem versionamento textual
├── gestao/          index.html com 0 byte  ← pasta morta
├── landing/         site estático da vitrine do produto
├── sprints/         1 atalho .url para planilha externa
└── src/
    └── app/         ← o app Flutter inteiro, 2 níveis abaixo da raiz
        ├── DOF_IMPLEMENTATION.md      ← documentação dentro do código
        ├── IMPLEMENTATION_SUMMARY.md  ← documentação dentro do código
        ├── esquema-conversao.md       ← documentação dentro do código
        └── exemplos/                  ← única fonte dos 3 errors do analyzer
```

**Achados:**

| # | Achado | Impacto |
|---|---|---|
| R1 | `src/app` é uma indireção sem função — não há um segundo app nem `packages/` para justificar `src/` | Confunde; `.vscode/launch.json` precisa de `cwd` explícito |
| R2 | Três documentos `.md` de arquitetura moram dentro do pacote Flutter | Documentação some do radar de quem procura em `docs/` |
| R3 | `exemplos/dof_exemplos_uso.dart` referencia `DofConversionService` e `XmlGeneratorService`, **que não existem** | Gera os únicos 3 errors do `flutter analyze` |
| R4 | `gestao/index.html` tem 0 byte | Pasta morta no repositório |
| R5 | `docs/` só tem binários (PDF/PNG) — sem diffs, sem revisão por PR | Decisões de arquitetura não têm histórico rastreável |

### 3.2 Nível `lib/`

**Achado A — Camadas vazias de Clean Architecture (6 arquivos, 0 byte)**

```
features/dof/domain/repositories/dof_repository.dart          0 byte
features/dof/domain/usecases/export_dof_to_xml.dart           0 byte
features/dof/domain/usecases/load_dof_from_excel.dart         0 byte
features/dof/data/repositories/dof_repository_impl.dart       0 byte
features/fiscalizacao/presentation/cadastro/cadastro_screen.dart    0 byte
features/fiscalizacao/presentation/validacao/validacao_screen.dart  0 byte
```

Os 4 primeiros anunciam uma arquitetura que não foi seguida. Os 2 últimos são telas prometidas ao usuário.

**Achado B — Rota inexistente causa crash garantido** 🔴

`hub` → `fiscalizacao_screen.dart:51` executa `context.push('/fiscalizacao/cadastro')` pelo FAB "Produto Extra".
Essa rota **não está registrada** em `app/routes.dart`. Qualquer toque no FAB derruba a navegação.

**Achado C — Provider de infraestrutura mora dentro de uma feature**

`isarServiceProvider` é declarado em `features/dof/presentation/providers/dof_providers.dart`.
Consequência: `features/fiscalizacao/.../fiscalizacao_providers.dart:12` **importa a camada de apresentação da feature `dof`** só para alcançar o banco de dados. O banco não pertence ao DOF; pertence ao app.

**Achado D — Regra de negócio dentro do datasource de persistência**

`FiscalizacaoLocalDatasource.recalcularEPersistirVolume()` faz três coisas: soma volumes, **decide o status da fiscalização** (`emAndamento` / `concluido` / `excedente`) e persiste. A regra mais importante do produto — a que define se há indício de irregularidade — está acoplada ao Isar e, por isso, não é testável isoladamente.

**Achado E — Arquivos com responsabilidade múltipla**

| Arquivo | Linhas | O que contém |
|---|---|---|
| `presentation/providers/fiscalizacao_providers.dart` | 535 | 4 providers + `FiscEditAction` (3 subclasses) + `FotoSession` + `CapturaState` + `CapturaNotifier` |
| `presentation/captura/captura_screen.dart` | 1.406 | Tela + gestos + hit-test + widgets privados + cards |
| `presentation/captura/medidas_screen.dart` | 726 | Tela + formulário + tabela + navegação entre fotos |

Arquivos desse tamanho são ímãs de conflito de merge numa equipe de 7 pessoas trabalhando em paralelo.

**Achado F — Nomenclatura inconsistente na camada de apresentação**

```
dof/presentation/screens/           dof/presentation/viewmodels/     ← "viewmodels"
fiscalizacao/presentation/screens/  fiscalizacao/presentation/providers/medidas_viewmodel.dart
fiscalizacao/presentation/captura/  ← tela agrupada por pasta        ← viewmodel dentro de "providers"
fiscalizacao/presentation/cadastro/
```

Um ViewModel dentro de uma pasta `providers/`; telas ora em `screens/`, ora em pasta própria.

**Achado G — Design System escrito e nunca aplicado** 🔴

`AppTheme.light` tem 113 linhas configurando Poppins, botões, inputs, cards, divisores, FAB e tipografia.
`app/app.dart` **não passa `theme:` para o `MaterialApp.router`**. O tema inteiro é código morto, e cada tela reescreve cores e estilos na mão.

**Achado H — Código transversal duplicado**

O truque `const Object _sentinel = Object()` (para permitir `copyWith` com `null` explícito) está **duplicado em 3 arquivos**: `fiscalizacao_providers.dart`, `upload_dof_viewmodel.dart`, `medidas_viewmodel.dart`.

**Achado I — Código morto e promessas não cumpridas**

| Item | Situação |
|---|---|
| `core/errors/exceptions.dart` | 3 exceções definidas, **nenhuma usada** em todo o `lib/` |
| `AppConstants` (11 constantes) | **Nenhuma usada** — incluindo `margemTolerancia = 0.10`, a "margem de 10%" anunciada na landing page |
| `xml_generator_service.dart` | 86 linhas, **100% comentadas** |
| `pdf`, `printing`, `share_plus`, `file_saver`, `permission_handler`, `camera` | Declaradas no `pubspec.yaml`, **zero imports** no `lib/` |
| "Laudo PDF no padrão oficial" (landing) | Não existe nenhuma linha de código de geração de PDF |

**Achado J — Estado do Hub é volátil**

O Hub lê a lista de itens de `parsedDofItemsProvider`, um `NotifierProvider` **em memória**, alimentado apenas no momento do upload. Os itens estão salvos no Isar, mas o Hub não os lê de lá. **Ao reabrir o app, o Hub aparece vazio** — comportamento crítico para um app cuja proposta de valor é funcionar offline, em campo, o dia inteiro.

**Achado K — `print()` em vez de logging estruturado**

48 dos 52 issues do analyzer são `avoid_print`, concentrados nos parsers CSV/Excel. `print()` permanece no build de release, expondo dados da fiscalização no logcat do dispositivo.

### 3.3 Nível plataforma / identidade do produto

| # | Achado | Valor atual | Impacto |
|---|---|---|---|
| P1 | Nome do pacote Dart | `app` → `import 'package:app/...'` | Genérico; imports não comunicam o produto |
| P2 | `applicationId` Android | `com.example.app` | 🔴 **Bloqueia publicação**; `com.example.*` é rejeitado pela Play Store |
| P3 | `namespace` Android | `com.example.app` | Mesmo problema |
| P4 | `android:label` | `"app"` | Ícone no launcher aparece como "app" |
| P5 | iOS `CFBundleDisplayName` | `"app"` | Idem no iOS |
| P6 | Título do `MaterialApp` | `"Fizcaliza"` | 🔴 **Erro de digitação no nome do produto** |

O achado P6 é de baixo esforço e alto constrangimento: o nome do produto está escrito errado no código que roda.

### 3.4 Achados priorizados

| Sev. | ID | Achado | Fase |
|---|---|---|---|
| 🔴 Crítico | B | FAB "Produto Extra" → rota inexistente → crash | 0 |
| 🔴 Crítico | G | `AppTheme` nunca aplicado | 0 |
| 🔴 Crítico | P6 | "Fizcaliza" — nome do produto com erro de digitação | 0 |
| 🔴 Crítico | P2/P3 | `com.example.app` bloqueia distribuição | 1 |
| 🔴 Crítico | J | Hub perde os dados ao reiniciar o app | 2 |
| 🟠 Alto | D | Regra de status acoplada ao Isar | 2 |
| 🟠 Alto | C | Infra (`isarServiceProvider`) dentro da feature `dof` | 2 |
| 🟠 Alto | E | Arquivos de 535 / 726 / 1.406 linhas | 2 |
| 🟠 Alto | R3 | `exemplos/` gera os 3 errors do analyzer | 0 |
| 🟡 Médio | A | 6 stubs de 0 byte | 0 / 2 |
| 🟡 Médio | F | Nomenclatura inconsistente em `presentation/` | 2 |
| 🟡 Médio | K | `print()` em produção | 0 |
| 🟡 Médio | H | `_sentinel` triplicado | 2 |
| 🟡 Médio | R1/R2 | `src/app` e docs dentro do pacote | 3 |
| 🟢 Baixo | I | Código morto (`exceptions`, `AppConstants`, XML comentado) | 0 / 4 |
| 🟢 Baixo | R4/R5 | `gestao/` vazio, `docs/` só binário | 3 |

---

## 4. Princípios que guiam a proposta

Sete princípios, extraídos de práticas consolidadas em times Flutter de escala (orientação oficial de arquitetura do Flutter, convenções do *Very Good CLI*, organização dos *Flutter samples* do Google, tooling de monorepo com *Melos*). Cada decisão deste plano se justifica por pelo menos um deles.

### P1 — Feature-first, não layer-first

Diretórios de primeiro nível dentro de `features/` são **capacidades do produto** (`dof`, `fiscalizacao`, `laudo`), não camadas técnicas (`screens/`, `models/`, `services/`).

*Por quê:* uma tarefa de sprint quase sempre é "mexer no fluxo de medidas", não "mexer em todos os models". Feature-first mantém a mudança concentrada numa pasta → menos conflito de merge, revisão de PR mais fácil.
*Status:* o projeto **já segue** isso. O plano preserva e reforça.

### P2 — Regra de dependência em uma única direção

```
presentation  ──▶  domain  ◀──  data
                    ▲
                    └── domain NÃO importa presentation nem data
```

Regra prática, verificável em revisão de PR:

- `domain/` importa **apenas** Dart puro. Nada de Flutter, Isar, ou `package:` de terceiros.
- `data/` pode importar `domain/`.
- `presentation/` pode importar `domain/` e `data/`.
- **Nenhuma feature importa `presentation/` de outra feature.**

*Hoje violado por:* Achado C (`fiscalizacao` importa `dof/presentation/providers/`).

### P3 — Infraestrutura transversal mora em `core/`, nunca dentro de uma feature

Banco de dados, logging, ML, tratamento de erro e utilidades não pertencem a nenhuma feature. Quando duas features precisam da mesma coisa, ela sobe para `core/` — não vira import cruzado.

### P4 — Design System é uma camada, não uma pasta de sobras

`core/widgets/` é onde componentes visuais vão morrer sem serem encontrados. Um diretório `design_system/` explícito, com `theme/`, `components/` e `painters/`, torna reuso a opção óbvia e evita que cada tela redefina `AppColors.green` e `BorderRadius.circular(12)` na mão — algo que hoje acontece em **todas** as telas.

### P5 — Um jeito só de fazer cada coisa

Consistência vale mais que sofisticação. Havendo três formas de declarar estado, o time gasta em decidir o que deveria gastar em construir. Este plano **escolhe uma** (MVVM + Repository) e remove os vestígios das outras.

### P6 — Regra de negócio testável sem infraestrutura

O cálculo que decide `concluido` vs. `excedente` é o coração do produto. Ele precisa rodar num teste unitário em milissegundos, sem abrir banco, sem emulador. Isso exige que ele seja uma **função pura em `domain/`**, chamada pelo repositório — e não código embutido numa transação Isar.

### P7 — `test/` espelha `lib/`

Todo arquivo `lib/a/b/c.dart` tem seu teste em `test/a/b/c_test.dart`. Regra mecânica, elimina a pergunta "onde está o teste disso?" e torna óbvio o que ainda não tem cobertura.

---

## 5. Estrutura-alvo do repositório

```
INF3-EQ1/
│
├── .github/
│   └── workflows/
│       └── ci.yaml                  # analyze + test a cada push/PR   [NOVO]
│
├── apps/
│   └── fiscaliza/                   # ← ex-src/app (pacote Flutter)
│       ├── android/
│       ├── ios/
│       ├── lib/                     # ver seção 6
│       ├── test/                    # ver seção 7
│       ├── assets/
│       │   ├── fonts/
│       │   ├── icons/
│       │   └── models/              # yolo_madeira.tflite + labels.txt
│       ├── analysis_options.yaml
│       └── pubspec.yaml
│
├── docs/                            # ver seção 8
│   ├── README.md                    # índice navegável                [NOVO]
│   ├── 00-produto/
│   ├── 01-gestao/
│   ├── 02-arquitetura/
│   ├── 03-negocio/
│   └── 04-decisoes/                 # ADRs                            [NOVO]
│
├── web/                             # artefatos web do projeto
│   └── landing/                     # ← ex-landing/
│
├── tools/                           # scripts de apoio                [NOVO]
│   └── check.ps1                    # analyze + test + format local
│
├── .gitignore
└── README.md
```

### 5.1 Justificativa de cada movimento

| Movimento | Justificativa |
|---|---|
| `src/app` → `apps/fiscaliza` | `apps/` + `packages/` é o layout canônico de repositórios Flutter multi-artefato (padrão do Melos e de times que publicam mais de um binário). Já deixa o caminho aberto para `packages/` sem nova reorganização. O nome `fiscaliza` substitui o genérico `app`. |
| `landing/` → `web/landing/` | Separa artefato web de artefato mobile na raiz. Torna explícito que a raiz do repo tem **dois** produtos: o app e o site. |
| `gestao/` → excluído | `index.html` com 0 byte. Se houver intenção de retomar, entra como `web/gestao/` quando tiver conteúdo. |
| `sprints/` → `docs/01-gestao/` | Um atalho `.url` não justifica um diretório de primeiro nível. |
| `.md` de dentro de `src/app` → `docs/` | Documentação de arquitetura e de negócio não é código-fonte. Quem procura documentação abre `docs/`. |
| `.github/workflows/` | Sem CI, "funciona na minha máquina" é a única garantia que o time tem. |
| `tools/` | Um script único que roda a mesma verificação da CI localmente, antes do push. |

### 5.2 Arquivos que precisam ser atualizados junto com a movimentação

Movimentação de diretório quebra referências. Checklist obrigatório da Fase 3:

- [ ] `.vscode/launch.json` — 3 configurações com `"cwd": "src\\app"` → `"apps\\fiscaliza"`
- [ ] `README.md` (raiz) — instruções de `cd` e `flutter run`
- [ ] `.github/workflows/ci.yaml` — `working-directory`
- [ ] `.gitignore` — verificar padrões com caminho fixo `src/`
- [ ] Qualquer link relativo entre os `.md` movidos

---

## 6. Estrutura-alvo do código (`lib/`)

```
apps/fiscaliza/lib/
│
├── main.dart                          # entrypoint mínimo: runApp(bootstrap())
├── bootstrap.dart                     # [NOVO] init assíncrono + captura global de erro
│
├── app/
│   ├── app.dart                       # MaterialApp.router + theme  ← aplicar AppTheme aqui
│   └── router/
│       ├── app_router.dart            # GoRouter (ex-routes.dart)
│       └── app_routes.dart            # [NOVO] constantes de path — fim das strings mágicas
│
├── core/                              # infraestrutura transversal — NÃO importa features
│   ├── constants/
│   │   └── app_constants.dart
│   ├── database/
│   │   ├── isar_service.dart          # ← core/services/
│   │   └── database_providers.dart    # [NOVO] isarServiceProvider mora aqui (resolve Achado C)
│   ├── errors/
│   │   └── exceptions.dart            # usar de verdade nos parsers, ou remover
│   ├── logging/
│   │   └── app_logger.dart            # [NOVO] substitui print() (resolve Achado K)
│   ├── ml/
│   │   ├── yolo_service.dart          # ← core/services/
│   │   └── recognition.dart           # [NOVO] extraído de yolo_service.dart
│   └── utils/
│       ├── formatting_converter.dart
│       └── sentinel.dart              # [NOVO] dedup do _sentinel x3 (resolve Achado H)
│
├── design_system/                     # [NOVO diretório] — resolve Achados G e P4
│   ├── theme/
│   │   ├── app_colors.dart            # ← core/theme/
│   │   ├── app_spacing.dart           # [NOVO] fim dos SizedBox(height: 16) mágicos
│   │   ├── app_typography.dart        # [NOVO]
│   │   └── app_theme.dart             # ← core/theme/
│   ├── components/
│   │   ├── app_scaffold.dart          # ← core/widgets/
│   │   ├── status_badge.dart          # [NOVO] extraído do Hub
│   │   ├── empty_state.dart           # [NOVO] repetido em 3 telas hoje
│   │   ├── primary_button.dart        # [NOVO]
│   │   └── section_card.dart          # [NOVO]
│   ├── dialogs/
│   │   └── confirm_dialog.dart        # ← core/utils/dialogs.dart
│   └── painters/
│       ├── bounding_box_painter.dart  # ← core/widgets/box_painter.dart
│       └── manual_box_editor_painter.dart
│
├── features/
│   │
│   ├── splash/
│   │   └── presentation/
│   │       └── splash_screen.dart
│   │
│   ├── dof/                           # importar planilha DOF e validar
│   │   ├── domain/
│   │   │   ├── dof_item.dart
│   │   │   └── dof_validator.dart     # ← data/services/ (é regra de negócio, não serviço de I/O)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── dof_item_model.dart
│   │   │   │   └── dof_item_model.g.dart
│   │   │   ├── services/
│   │   │   │   ├── csv_parser_service.dart
│   │   │   │   └── excel_parser_service.dart
│   │   │   └── dof_repository.dart    # ← data/datasources/dof_local_datasource.dart
│   │   └── presentation/
│   │       └── upload/
│   │           ├── upload_dof_screen.dart
│   │           ├── upload_dof_view_model.dart
│   │           └── widgets/
│   │               └── dof_preview_table.dart
│   │
│   ├── fiscalizacao/                  # o núcleo do produto
│   │   ├── domain/
│   │   │   ├── status_fiscalizacao.dart
│   │   │   ├── calculo_status.dart    # [NOVO] regra pura (resolve Achados D e P6)
│   │   │   └── perfil_peca.dart       # [NOVO] Prancha/Viga/Caibro/Tábua/Ripa
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── fiscalizacao_registro_model.dart (+ .g.dart)
│   │   │   │   └── medicao_grupo_model.dart (+ .g.dart)
│   │   │   └── fiscalizacao_repository.dart   # ← data/datasources/
│   │   └── presentation/
│   │       ├── hub/
│   │       │   ├── hub_fiscalizacao_screen.dart      # ← screens/fiscalizacao_screen.dart
│   │       │   ├── hub_view_model.dart               # [NOVO] resolve Achado J
│   │       │   └── widgets/item_dof_card.dart
│   │       ├── captura/
│   │       │   ├── captura_screen.dart
│   │       │   ├── captura_view_model.dart           # ← providers/fiscalizacao_providers.dart
│   │       │   ├── captura_state.dart                # [NOVO] split
│   │       │   ├── foto_session.dart                 # [NOVO] split
│   │       │   ├── fisc_edit_action.dart             # [NOVO] split
│   │       │   └── widgets/
│   │       │       ├── header_card.dart
│   │       │       ├── thumbnail_strip.dart
│   │       │       └── deteccoes_summary.dart
│   │       ├── medidas/
│   │       │   ├── medidas_screen.dart
│   │       │   ├── medidas_view_model.dart           # ← providers/medidas_viewmodel.dart
│   │       │   └── widgets/
│   │       │       ├── form_medidas.dart
│   │       │       └── tabela_medidas.dart
│   │       ├── cadastro/
│   │       │   ├── cadastro_produto_screen.dart      # [IMPLEMENTAR — Fase 4]
│   │       │   └── cadastro_produto_view_model.dart
│   │       └── validacao/
│   │           ├── validacao_screen.dart             # [IMPLEMENTAR — Fase 4]
│   │           └── validacao_view_model.dart
│   │
│   └── laudo/                         # [NOVA FEATURE — Fase 4]
│       ├── domain/laudo_fiscalizacao.dart
│       ├── data/pdf_generator_service.dart
│       └── presentation/
│           ├── laudo_preview_screen.dart
│           └── laudo_view_model.dart
│
└── l10n/                              # [futuro — ver Não-objetivos]
```

### 6.1 As quatro mudanças estruturais que mais importam

**① `isarServiceProvider` sai da feature `dof` para `core/database/`**
Elimina o único import cruzado entre features. Depois disso, `fiscalizacao` e `dof` são independentes uma da outra — exceto por `DofItemModel`, que é legitimamente compartilhado (ver §6.2).

**② A regra de status vira função pura em `domain/calculo_status.dart`**

```dart
// features/fiscalizacao/domain/calculo_status.dart
// Dart puro: sem Flutter, sem Isar. Testável em milissegundos.

StatusFiscalizacao calcularStatus({
  required double volumeMedidoM3,
  required double saldoDeclaradoM3,
  required int pecasContadas,
  required int pecasMedidas,
}) {
  final todasMedidas = pecasContadas > 0 && pecasMedidas >= pecasContadas;
  if (!todasMedidas || volumeMedidoM3 == 0.0) return StatusFiscalizacao.emAndamento;
  if (volumeMedidoM3 <= saldoDeclaradoM3)     return StatusFiscalizacao.concluido;
  return StatusFiscalizacao.excedente;
}
```

O `FiscalizacaoRepository.recalcularEPersistirVolume()` passa a **chamar** essa função, em vez de conter a regra. Ganho concreto: a tabela-verdade completa do status (incluindo o caso de fronteira `volume == saldoTotal`) passa a ser testável sem abrir banco.

**③ `fiscalizacao_providers.dart` (535 linhas) é dividido em 4 arquivos**

| Novo arquivo | Conteúdo extraído |
|---|---|
| `captura/fisc_edit_action.dart` | `FiscEditAction`, `FiscAddedDetections`, `FiscRemovedDetection`, `FiscMovedDetection` |
| `captura/foto_session.dart` | `FotoSession` |
| `captura/captura_state.dart` | `CapturaState` |
| `captura/captura_view_model.dart` | `CapturaNotifier` → renomeado `CapturaViewModel` |

Os providers de infraestrutura (`yoloServiceProvider`, `fiscalizacaoRepositoryProvider`, `registroPorItemProvider`) ficam num `fiscalizacao_providers.dart` enxuto.

**④ O Hub passa a ler do repositório, não da memória** (resolve Achado J)

`parsedDofItemsProvider` (estado volátil) é substituído por um `FutureProvider` que lê `DofRepository.getAllDofs()`. O Hub ganha um `HubViewModel` responsável por combinar itens DOF + registros de fiscalização. **Consequência funcional: o app passa a sobreviver a um reinício em campo** — requisito implícito de um app cuja proposta é operar offline durante uma jornada inteira de fiscalização.

### 6.2 Sobre `DofItemModel` ser compartilhado entre features

`DofItemModel` é usado por 6 arquivos da feature `fiscalizacao`. Isso **não** é uma violação: o item do DOF é a entidade central do domínio, e a fiscalização existe justamente para confrontá-lo. A regra P2 proíbe importar `presentation/` de outra feature — importar `domain/`/`data/models/` é legítimo.

**Decisão:** manter `DofItemModel` em `features/dof/data/models/`. Se no futuro uma terceira feature depender dele, promover `DofItem` (a entidade de domínio, Dart puro) para `lib/shared/domain/` e manter o `Model` (Isar) na feature.

### 6.3 Nota crítica sobre o Isar durante a movimentação

> ⚠️ **Mover arquivos de model é seguro. Renomear as classes NÃO é.**

O Isar deriva o nome da coleção do **nome da classe** anotada com `@Collection()`. Mover `dof_item_model.dart` de pasta não altera o schema. Mas renomear `DofItemModel` → `DofItem` mudaria o nome da coleção e **tornaria inacessíveis os dados já gravados** nos dispositivos de teste.

**Regra da Fase 2:** as três classes `DofItemModel`, `FiscalizacaoRegistroModel` e `MedicaoGrupoModel` **não são renomeadas**. Apenas movidas.

Após qualquer movimentação de model, regenerar:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 7. Estrutura-alvo dos testes

Espelhamento 1:1 de `lib/` (princípio P7):

```
apps/fiscaliza/test/
├── fixtures/
│   ├── dof_exemplo.csv                    # ← src/app/exemplos/
│   └── dof_colunas_variantes.csv          # [NOVO] cabeçalhos alternativos
├── core/
│   ├── ml/recognition_test.dart           # ← test/recognition_serialization_test.dart
│   └── utils/formatting_converter_test.dart
├── features/
│   ├── dof/
│   │   ├── domain/dof_validator_test.dart          # [NOVO] validador nunca testado
│   │   └── data/services/csv_parser_service_test.dart  # [NOVO]
│   └── fiscalizacao/
│       ├── domain/calculo_status_test.dart         # [NOVO] ⭐ regra central do produto
│       └── data/cubagem_persistence_test.dart      # ← existente, preservar
└── app/
    └── app_test.dart                      # ← widget_test.dart (renomear e dar conteúdo real)
```

### 7.1 Prioridade de cobertura

| Prioridade | Alvo | Justificativa |
|---|---|---|
| ⭐ 1 | `calculo_status_test.dart` | É a regra que decide se há infração. Testar a tabela-verdade completa, incluindo `volume == saldoTotal` |
| 2 | `dof_validator_test.dart` | 124 linhas de validação hoje **sem nenhum teste e sem nenhum uso** |
| 3 | `csv_parser_service_test.dart` | Normalização de cabeçalho e vírgula decimal brasileira são fontes clássicas de bug de campo |
| 4 | `app_test.dart` | Hoje é o smoke test padrão do Flutter ("Counter increments") — não testa nada do FISCALIZA |

**Meta realista para o TCC:** cobertura das regras de negócio em `domain/`, não cobertura total. Testar `domain/` é barato (Dart puro, sem mock) e é exatamente o que a banca vai questionar.

---

## 8. Estrutura-alvo da documentação

```
docs/
├── README.md                            # [NOVO] índice de tudo abaixo
│
├── 00-produto/
│   ├── visao-geral.md                   # [NOVO] problema, usuário, proposta de valor
│   ├── diagrama-casos-de-uso.png        # ← docs/
│   └── manual-do-usuario.pdf
│
├── 01-gestao/
│   ├── definicao-dos-papeis.pdf         # ← docs/
│   ├── planilha-de-avaliacao.url        # ← sprints/
│   └── convencoes-de-trabalho.md        # [NOVO] branches, PR, Definition of Done
│
├── 02-arquitetura/
│   ├── PLANO-DE-REESTRUTURACAO.md       # ← este documento
│   ├── documentacao-tecnica.pdf         # ← docs/
│   ├── arquitetura-do-app.md            # [NOVO] camadas, fluxo de dados, diagrama
│   └── dof-implementacao.md             # ← src/app/DOF_IMPLEMENTATION.md (revisado)
│
├── 03-negocio/
│   ├── regras-de-negocio.md             # [NOVO] DOF vs. cubagem, tabela de status
│   └── esquema-conversao-dof.md         # ← src/app/esquema-conversao.md
│
└── 04-decisoes/                         # ADRs — Architecture Decision Records
    ├── 0001-mvvm-em-vez-de-clean-architecture.md
    ├── 0002-isar-como-banco-local.md
    └── 0003-yolo-tflite-embarcado.md
```

### 8.1 Correção obrigatória na documentação existente

`DOF_IMPLEMENTATION.md` e `IMPLEMENTATION_SUMMARY.md` afirmam, como concluído:

> ✅ **Status: PRONTO PARA PRODUÇÃO**
> `xml_generator_service.dart` — Gerador de XML ✓
> `dof_conversion_service.dart` — Orquestrador ✓

Na realidade: o gerador de XML está **inteiramente comentado** e o orquestrador **não existe**. Documentação que descreve funcionalidade inexistente é pior que ausência de documentação — ela induz a equipe ao erro e é vulnerável ao questionamento da banca.

**Ação:** consolidar os dois arquivos em um único `docs/02-arquitetura/dof-implementacao.md`, com um cabeçalho de status honesto:

```markdown
| Componente | Status | Arquivo |
|---|---|---|
| Parser CSV | ✅ Implementado | data/services/csv_parser_service.dart |
| Parser Excel | ✅ Implementado | data/services/excel_parser_service.dart |
| Validador | ⚠️ Implementado, não integrado ao fluxo | domain/dof_validator.dart |
| Gerador XML | ❌ Não implementado (código comentado) | — |
| Orquestrador de conversão | ❌ Não implementado | — |
```

### 8.2 ADRs (Architecture Decision Records)

Registro curto (1 página) por decisão relevante: **contexto → decisão → consequências**.
Para um TCC, ADRs têm valor duplo: organizam a equipe **e** dão à banca evidência escrita de que as escolhas técnicas foram deliberadas, não acidentais. Os três primeiros ADRs a escrever estão listados na estrutura acima.

---

## 9. Mapa de-para completo

Legenda: 📁 mover · ✏️ mover e renomear · ✂️ dividir · 🆕 criar · 🗑️ excluir · ✅ manter

### 9.1 Raiz do repositório

| # | Origem | Destino | Ação |
|---|---|---|---|
| 1 | `src/app/` | `apps/fiscaliza/` | 📁 |
| 2 | `landing/` | `web/landing/` | 📁 |
| 3 | `gestao/index.html` (0 byte) | — | 🗑️ |
| 4 | `sprints/Planilha de avaliação.url` | `docs/01-gestao/planilha-de-avaliacao.url` | ✏️ |
| 5 | `docs/Definição dos papeis.pdf` | `docs/01-gestao/definicao-dos-papeis.pdf` | ✏️ |
| 6 | `docs/Diagrama casos de uso.png` | `docs/00-produto/diagrama-casos-de-uso.png` | ✏️ |
| 7 | `docs/Documentação Técnica.pdf` | `docs/02-arquitetura/documentacao-tecnica.pdf` | ✏️ |
| 8 | `src/app/DOF_IMPLEMENTATION.md` | `docs/02-arquitetura/dof-implementacao.md` | ✏️ |
| 9 | `src/app/IMPLEMENTATION_SUMMARY.md` | consolidar em #8 | 🗑️ |
| 10 | `src/app/esquema-conversao.md` | `docs/03-negocio/esquema-conversao-dof.md` | ✏️ |
| 11 | `src/app/exemplos/dof_exemplo.csv` | `apps/fiscaliza/test/fixtures/dof_exemplo.csv` | 📁 |
| 12 | `src/app/exemplos/dof_exemplos_uso.dart` | — (origem dos 3 errors) | 🗑️ |
| 13 | `src/app/README.md` (template do Flutter) | reescrever com conteúdo do produto | ✏️ |
| 14 | — | `.github/workflows/ci.yaml` | 🆕 |
| 15 | — | `tools/check.ps1` | 🆕 |
| 16 | — | `docs/README.md` (índice) | 🆕 |

### 9.2 `lib/` — raiz e `app/`

| # | Origem | Destino | Ação |
|---|---|---|---|
| 17 | `lib/main.dart` | `lib/main.dart` | ✅ |
| 18 | — | `lib/bootstrap.dart` | 🆕 |
| 19 | `lib/app/app.dart` | `lib/app/app.dart` — **adicionar `theme:`** e corrigir `"Fizcaliza"` | ✏️ |
| 20 | `lib/app/routes.dart` | `lib/app/router/app_router.dart` | ✏️ |
| 21 | — | `lib/app/router/app_routes.dart` (constantes de path) | 🆕 |

### 9.3 `lib/core/`

| # | Origem | Destino | Ação |
|---|---|---|---|
| 22 | `core/services/isar_service.dart` | `core/database/isar_service.dart` | 📁 |
| 23 | `isarServiceProvider` (em `dof/presentation/providers/`) | `core/database/database_providers.dart` | ✂️ |
| 24 | `core/services/yolo_service.dart` | `core/ml/yolo_service.dart` | 📁 |
| 25 | classe `Recognition` (dentro de #24) | `core/ml/recognition.dart` | ✂️ |
| 26 | `core/utils/formatting_converter.dart` | `core/utils/formatting_converter.dart` | ✅ |
| 27 | `core/errors/exceptions.dart` | usar nos parsers ou remover | ✏️ |
| 28 | `core/constants/app_constants.dart` | manter; **usar `margemTolerancia`** ou remover a constante | ✏️ |
| 29 | `_sentinel` (triplicado) | `core/utils/sentinel.dart` | ✂️ |
| 30 | — | `core/logging/app_logger.dart` | 🆕 |

### 9.4 `lib/design_system/` (novo)

| # | Origem | Destino | Ação |
|---|---|---|---|
| 31 | `core/theme/app_colors.dart` | `design_system/theme/app_colors.dart` | 📁 |
| 32 | `core/theme/app_theme.dart` | `design_system/theme/app_theme.dart` | 📁 |
| 33 | `core/utils/dialogs.dart` | `design_system/dialogs/confirm_dialog.dart` | ✏️ |
| 34 | `core/widgets/app_scaffold.dart` | `design_system/components/app_scaffold.dart` | 📁 |
| 35 | `core/widgets/box_painter.dart` | `design_system/painters/bounding_box_painter.dart` | ✏️ |
| 36 | `core/widgets/manual_box_editor.dart` | `design_system/painters/manual_box_editor_painter.dart` | ✏️ |
| 37 | — | `design_system/theme/app_spacing.dart` | 🆕 |
| 38 | — | `design_system/components/status_badge.dart` (extraído do Hub) | 🆕 |
| 39 | — | `design_system/components/empty_state.dart` | 🆕 |

### 9.5 `lib/features/dof/`

| # | Origem | Destino | Ação |
|---|---|---|---|
| 40 | `domain/entities/dof_item.dart` | `domain/dof_item.dart` | 📁 |
| 41 | `domain/repositories/dof_repository.dart` (0 byte) | — | 🗑️ |
| 42 | `domain/usecases/export_dof_to_xml.dart` (0 byte) | — | 🗑️ |
| 43 | `domain/usecases/load_dof_from_excel.dart` (0 byte) | — | 🗑️ |
| 44 | `data/repositories/dof_repository_impl.dart` (0 byte) | — | 🗑️ |
| 45 | `data/datasources/dof_local_datasource.dart` | `data/dof_repository.dart` | ✏️ |
| 46 | `data/models/dof_item_model.dart` (+ `.g.dart`) | `data/models/` (mesmo lugar) — **não renomear a classe** | ✅ |
| 47 | `data/services/csv_parser_service.dart` | `data/services/` | ✅ |
| 48 | `data/services/excel_parser_service.dart` | `data/services/` | ✅ |
| 49 | `data/services/dof_validator_service.dart` | `domain/dof_validator.dart` (é regra, não I/O) | ✏️ |
| 50 | `data/services/xml_generator_service.dart` (comentado) | decidir: `features/laudo/` ou 🗑️ | ✏️ |
| 51 | `presentation/screens/upload_dof_screen.dart` | `presentation/upload/upload_dof_screen.dart` | 📁 |
| 52 | `presentation/viewmodels/upload_dof_viewmodel.dart` | `presentation/upload/upload_dof_view_model.dart` | ✏️ |
| 53 | `presentation/providers/dof_providers.dart` | dividir: infra→#23; `parsedDofItemsProvider`→substituído por leitura do repositório | ✂️ |

### 9.6 `lib/features/fiscalizacao/`

| # | Origem | Destino | Ação |
|---|---|---|---|
| 54 | `domain/entities/status_fiscalizacao.dart` | `domain/status_fiscalizacao.dart` | 📁 |
| 55 | regra de status (dentro de `recalcularEPersistirVolume`) | `domain/calculo_status.dart` | ✂️ |
| 56 | `tamanhosComuns` (dentro de `medidas_viewmodel.dart`) | `domain/perfil_peca.dart` | ✂️ |
| 57 | `data/datasources/fiscalizacao_local_datasource.dart` | `data/fiscalizacao_repository.dart` | ✏️ |
| 58 | `data/models/*.dart` (+ `.g.dart`) | mesmo lugar — **não renomear as classes** | ✅ |
| 59 | `presentation/screens/fiscalizacao_screen.dart` | `presentation/hub/hub_fiscalizacao_screen.dart` | ✏️ |
| 60 | — | `presentation/hub/hub_view_model.dart` (lê do repositório) | 🆕 |
| 61 | `presentation/providers/fiscalizacao_providers.dart` (535 ln) | ✂️ em 5 arquivos (ver §6.1-③) | ✂️ |
| 62 | `presentation/providers/medidas_viewmodel.dart` | `presentation/medidas/medidas_view_model.dart` | ✏️ |
| 63 | `presentation/captura/captura_screen.dart` (1.406 ln) | `presentation/captura/` + `widgets/` | ✂️ |
| 64 | `presentation/captura/medidas_screen.dart` (726 ln) | `presentation/medidas/medidas_screen.dart` + `widgets/` | ✂️ |
| 65 | `presentation/cadastro/cadastro_screen.dart` (0 byte) | implementar na Fase 4 | 🆕 |
| 66 | `presentation/validacao/validacao_screen.dart` (0 byte) | implementar na Fase 4 | 🆕 |

### 9.7 `test/`

| # | Origem | Destino | Ação |
|---|---|---|---|
| 67 | `test/widget_test.dart` (smoke padrão do Flutter) | `test/app/app_test.dart` — com conteúdo real | ✏️ |
| 68 | `test/recognition_serialization_test.dart` | `test/core/ml/recognition_test.dart` | ✏️ |
| 69 | `test/features/fiscalizacao/cubagem_persistence_test.dart` | `test/features/fiscalizacao/data/` | 📁 |
| 70 | — | `test/features/fiscalizacao/domain/calculo_status_test.dart` | 🆕 |
| 71 | — | `test/features/dof/domain/dof_validator_test.dart` | 🆕 |
| 72 | — | `test/fixtures/` | 🆕 |

**Resumo:** 72 movimentos — 6 exclusões de código morto, 20 criações, 46 movimentações/divisões.

---

## 10. Convenções de código e nomenclatura

Estas convenções passam a valer para **todo código novo** a partir da aprovação deste plano, inclusive antes de as fases serem executadas.

### 10.1 Arquivos e diretórios

| Regra | Exemplo |
|---|---|
| Arquivos em `snake_case.dart` | `hub_fiscalizacao_screen.dart` |
| Diretórios em `snake_case`, singular quando conceito, plural quando coleção | `domain/`, `models/`, `widgets/` |
| Um widget/classe **pública** por arquivo | `StatusBadge` em `status_badge.dart` |
| Widgets privados de uma tela (`_HeaderCard`) → extrair para `widgets/` quando > 40 linhas | `captura/widgets/header_card.dart` |

### 10.2 Sufixos obrigatórios

| Sufixo | Papel | Camada |
|---|---|---|
| `_screen.dart` | Tela roteável | presentation |
| `_view_model.dart` | Estado + ações da tela (Riverpod `Notifier`) | presentation |
| `_state.dart` | Classe imutável de estado, quando extraída | presentation |
| `_repository.dart` | Acesso a dados, expõe o domínio | data |
| `_service.dart` | I/O bruto (arquivo, ML, banco) | data / core |
| `_model.dart` | Classe `@Collection()` do Isar | data |
| `_painter.dart` | `CustomPainter` | design_system |

> ⚠️ **Nada de `_notifier.dart` e `_controller.dart` a partir de agora.** O projeto tem hoje `CapturaNotifier` e teve `UploadDofController`; a convenção única passa a ser `ViewModel`, alinhada ao caminho que a equipe já vinha tomando e à orientação oficial do Flutter.

### 10.3 Imports

```dart
// ✅ Entre pastas diferentes: sempre absoluto com o nome do pacote
import 'package:fiscaliza/features/dof/domain/dof_item.dart';

// ✅ Dentro da mesma pasta: relativo curto
import 'captura_state.dart';

// ❌ Nunca: relativo atravessando pastas
import '../../../../core/services/isar_service.dart';
```

Ordem dos blocos, separados por linha em branco: `dart:` → `package:flutter` → `package:` terceiros → `package:fiscaliza` → relativos.

### 10.4 Providers Riverpod

| Regra | Motivo |
|---|---|
| Provider é declarado **no arquivo do que ele expõe** | Nunca mais um provider global escondido dentro de um arquivo de tela |
| Provider de infraestrutura mora em `core/` | Achado C |
| Sufixo `Provider` no nome da variável | `capturaViewModelProvider` |
| Usar a API moderna `Notifier`/`AsyncNotifier` | O projeto já migrou; não reintroduzir `StateNotifier` |
| `AutoDispose` por padrão em telas | Libera memória ao sair — relevante num app que segura imagens decodificadas |

### 10.5 Idioma

O projeto é bilíngue **de propósito** e isso deve ser explícito, não acidental:

| Contexto | Idioma | Exemplo |
|---|---|---|
| Domínio e regra de negócio | **Português** | `saldoTotal`, `volumeTotalM3`, `StatusFiscalizacao.excedente` |
| Infraestrutura e termos técnicos | **Inglês** | `Repository`, `ViewModel`, `runInference`, `copyWith` |
| Texto de interface | **Português** | `'Salvar Fiscalização'` |
| Comentários e documentação | **Português** | — |

*Justificativa:* o domínio é jurídico-ambiental brasileiro (DOF, saldo, cubagem, espécie). Traduzir `saldoLivre` para `freeBalance` afasta o código do vocabulário do fiscal e do próprio documento legal.

### 10.6 Proibições

| ❌ Proibido | ✅ Em vez disso |
|---|---|
| `print()` | `AppLogger.info()` / `.error()` |
| Cor literal em tela (`Color(0xFF37c064)`) | `AppColors.green` via `Theme.of(context)` |
| String de rota literal (`'/fiscalizacao/captura'`) | `AppRoutes.captura` |
| `as Type` sem verificação em `state.extra` | Validar e tratar `null` com fallback |
| Feature importar `presentation/` de outra feature | Subir o compartilhado para `core/` ou `shared/` |
| Renomear classe `@Collection()` do Isar | Só mover o arquivo (§6.3) |

### 10.7 Definition of Done — nova tela

Checklist aplicável a toda tela nova (Cadastro, Validação, Laudo):

- [ ] Pasta própria em `features/<feature>/presentation/<tela>/`
- [ ] `<tela>_screen.dart` + `<tela>_view_model.dart`; a tela **não** contém regra de negócio
- [ ] Rota registrada em `app_router.dart` **e** constante em `app_routes.dart`
- [ ] Argumentos de rota validados (sem `as Type` cru)
- [ ] Usa `AppScaffold` e componentes do `design_system/`
- [ ] Zero cor/spacing literal
- [ ] Estados de *loading*, *vazio* e *erro* tratados visualmente
- [ ] Regra de negócio nova → função pura em `domain/` + teste unitário
- [ ] `flutter analyze` sem novos issues
- [ ] `flutter test` verde
- [ ] Testada em tela pequena (≤ 5") — o uso real é em campo, com uma mão

---

## 11. Plano de execução em fases

Regra transversal: **cada fase termina com o app compilando, os 18 testes passando e o fluxo Splash → Upload → Hub → Captura → Medidas navegável.** Nenhuma fase deixa a `main` quebrada.

> **Sobre versionamento:** este plano descreve movimentações de arquivo que devem ser feitas com `git mv` (preserva o histórico do arquivo). **Nenhuma operação de commit, push ou pull faz parte deste documento** — a decisão de quando e como versionar cada fase é da equipe.

---

### Fase 0 — Estabilização e guard-rails

**Objetivo:** zerar o ruído e instalar a rede de segurança **antes** de mover qualquer arquivo.
**Esforço:** 1–2 dias · **Risco:** 🟢 Baixo · **Move arquivos:** não

| # | Ação | Achado |
|---|---|---|
| 0.1 | Registrar `/fiscalizacao/cadastro` no router com tela stub navegável (ou desabilitar o FAB até a Fase 4) | B 🔴 |
| 0.2 | `app.dart`: adicionar `theme: AppTheme.light` | G 🔴 |
| 0.3 | `app.dart`: corrigir `title: 'Fizcaliza'` → `'FISCALIZA'` | P6 🔴 |
| 0.4 | Excluir `src/app/exemplos/dof_exemplos_uso.dart` (mover o `.csv` para fixtures) | R3 |
| 0.5 | Criar `core/logging/app_logger.dart` e substituir os 48 `print()` | K |
| 0.6 | Remover variável não usada `contagemSalva` (`fiscalizacao_screen.dart:97`) | — |
| 0.7 | Endurecer `analysis_options.yaml` (anexo 14.1) | — |
| 0.8 | Criar `.github/workflows/ci.yaml` (anexo 14.2) | — |
| 0.9 | Criar `tools/check.ps1` (anexo 14.3) | — |

**Critério de pronto:**
- `flutter analyze` → **0 issues** (de 52)
- `flutter test` → 18/18 ✅
- FAB "Produto Extra" não derruba o app
- Todas as telas renderizam com Poppins e o tema aplicado
- CI verde no primeiro push

**Por que primeiro:** com o analyzer em zero, qualquer issue introduzido nas fases seguintes aparece imediatamente. Sem isso, um erro novo se esconde no meio de 52 mensagens.

---

### Fase 1 — Identidade do produto

**Objetivo:** o app deixa de se chamar "app" e passa a ser instalável/distribuível.
**Esforço:** 0,5 dia · **Risco:** 🟡 Médio (toca `android/` e `ios/` e **todos** os imports) · **Move arquivos:** não

| # | Ação | De | Para |
|---|---|---|---|
| 1.1 | Nome do pacote Dart (`pubspec.yaml`) | `app` | `fiscaliza` |
| 1.2 | Substituição global de imports | `package:app/` | `package:fiscaliza/` |
| 1.3 | `android/app/build.gradle.kts` — `namespace` e `applicationId` | `com.example.app` | `br.edu.ctiroldan.fiscaliza` |
| 1.4 | `AndroidManifest.xml` — `android:label` | `"app"` | `"Fiscaliza"` |
| 1.5 | `ios/Runner/Info.plist` — `CFBundleDisplayName` | `"app"` | `"Fiscaliza"` |
| 1.6 | `pubspec.yaml` — `description` | template | descrição real do produto |

**Riscos e cuidados:**
- 1.2 é substituição de texto em ~40 arquivos. Fazer com *Replace in Files* do VS Code, revisando o diff.
- Alterar `applicationId` faz o Android tratar como **outro app**: a instalação anterior não é substituída e os dados Isar do dispositivo de teste ficam órfãos. Desinstalar a versão antiga antes de reinstalar.
- Executar `flutter clean` após 1.3.

**Critério de pronto:** `flutter build apk --debug` conclui; app aparece como "Fiscaliza" no launcher; analyze e testes verdes.

**Por que antes da Fase 2:** renomear o pacote toca todos os imports. Fazer isso **antes** de mover arquivos evita empilhar duas mudanças massivas de import no mesmo diff.

---

### Fase 2 — Reorganização do `lib/`

**Objetivo:** uma arquitetura, uma convenção, regra de negócio testável.
**Esforço:** 3–4 dias · **Risco:** 🟡 Médio · **Move arquivos:** sim

Executar em **5 lotes**, cada um com analyze + test ao final. Não iniciar o lote seguinte com o anterior quebrado.

**Lote 2.A — Infraestrutura (`core/`)** — mapa #22 a #30
- `isar_service.dart` → `core/database/`; criar `database_providers.dart` com `isarServiceProvider` (resolve o import cruzado C)
- `yolo_service.dart` → `core/ml/`; extrair `Recognition` para arquivo próprio
- Criar `core/utils/sentinel.dart` e eliminar as 3 duplicatas

**Lote 2.B — Design System** — mapa #31 a #39
- Criar `design_system/` com `theme/`, `components/`, `dialogs/`, `painters/`
- Extrair `StatusBadge` do Hub e `EmptyState` (hoje repetido em 3 telas)
- Criar `app_spacing.dart` e começar a substituir `SizedBox` mágicos

**Lote 2.C — Domínio e repositórios** — mapa #40 a #58
- 🗑️ Excluir os 4 stubs de Clean Architecture (0 byte)
- `*_local_datasource.dart` → `*_repository.dart`
- ⭐ Extrair `calcularStatus()` para `domain/calculo_status.dart` + **escrever o teste da tabela-verdade**
- `dof_validator_service.dart` → `domain/dof_validator.dart`
- Extrair `tamanhosComuns` → `domain/perfil_peca.dart`
- Regenerar: `dart run build_runner build --delete-conflicting-outputs`

**Lote 2.D — Apresentação** — mapa #51 a #66
- Padronizar em `presentation/<tela>/` com `_screen` + `_view_model`
- ✂️ Dividir `fiscalizacao_providers.dart` (535 ln) em 5 arquivos
- ✂️ Extrair widgets privados de `captura_screen.dart` (1.406 ln) para `captura/widgets/`
- Criar `app_routes.dart` e eliminar strings de rota literais

**Lote 2.E — Hub persistente** — Achado J 🔴
- Criar `hub_view_model.dart` lendo `DofRepository.getAllDofs()`
- Remover `parsedDofItemsProvider`
- **Validar manualmente:** importar DOF → fechar o app completamente → reabrir → o Hub deve manter os itens e seus status

**Critério de pronto da Fase 2:**
- `flutter analyze` → 0 issues
- `flutter test` → 18 anteriores + testes novos de `calculo_status` e `dof_validator`
- Nenhum arquivo escrito à mão com mais de ~400 linhas
- `grep "features/.*/presentation" lib/features/` não retorna import entre features distintas
- Hub sobrevive a reinício do app

---

### Fase 3 — Reorganização do repositório

**Objetivo:** raiz do repositório legível para quem chega — inclusive a banca.
**Esforço:** 0,5–1 dia · **Risco:** 🟢 Baixo (mecânico, mas exige o checklist §5.2) · **Move arquivos:** sim

| # | Ação |
|---|---|
| 3.1 | `git mv src/app apps/fiscaliza` |
| 3.2 | `git mv landing web/landing`; remover `gestao/` vazio |
| 3.3 | Reorganizar `docs/` conforme §8 |
| 3.4 | Mover os 3 `.md` de dentro do pacote para `docs/` e **corrigir os status falsos** (§8.1) |
| 3.5 | Atualizar `.vscode/launch.json`, `README.md` raiz, `ci.yaml` (checklist §5.2) |
| 3.6 | Criar `docs/README.md` (índice) e os 3 primeiros ADRs |
| 3.7 | Reescrever `apps/fiscaliza/README.md` (hoje é o template do Flutter) |

**Critério de pronto:** clonar em pasta limpa → `cd apps/fiscaliza && flutter pub get && flutter run` funciona; F5 no VS Code funciona; CI verde; nenhum link quebrado em `docs/`.

**Coordenação obrigatória:** esta fase reescreve caminhos de todo o repositório. Combinar uma janela com a equipe — todo trabalho em andamento deve estar integrado ou rebaseado antes. Existem 4 branches remotas (`feat/implementacao-visao-computacional`, `feat/medidas`, `feat/xls-csv-to-xml`, `fix/arruma-erro-deteccao-area-especifica`) que precisam ser verificadas antes.

---

### Fase 4 — Features habilitadas pela reestruturação

**Objetivo:** entregar o que a landing page promete.
**Esforço:** contínuo · **Risco:** 🟢 Baixo (estrutura já pronta)

Ordem sugerida, por relação valor × esforço:

| Ordem | Entrega | Por quê |
|---|---|---|
| 1 | **`CadastroProdutoScreen`** | Fecha o crash da Fase 0 com a funcionalidade real. Produto extra = item **fora do DOF** → conceitualmente já nasce `excedente`, o achado mais grave de uma fiscalização |
| 2 | **`ValidacaoScreen`** | Revisão consolidada antes do laudo. Ativa o `DofValidator` — 124 linhas prontas, hoje sem nenhum uso |
| 3 | **Feature `laudo` (PDF)** | Entrega prometida na landing; `pdf`, `printing` e `share_plus` já estão no `pubspec`. É o artefato que a banca vê |
| 4 | **Busca de madeireira** | `SplashScreen` tem campo de busca com `onSubmitted` vazio; exige decidir se haverá entidade "Madeireira/Empresa" |
| 5 | **Decisão sobre XML** | `xml_generator_service.dart` está 100% comentado. Implementar dentro de `laudo/` **ou excluir** e corrigir a documentação |
| 6 | **`margemTolerancia`** | A "margem de 10% por espécie" anunciada na landing não existe no cálculo. Implementar em `calculo_status.dart` **ou** remover a promessa da landing |

Os itens 5 e 6 são **decisões de produto**, não tarefas técnicas: exigem que a equipe defina se a funcionalidade entra no escopo do TCC ou sai da comunicação.

---

## 12. Riscos e mitigações

| # | Risco | Prob. | Impacto | Mitigação |
|---|---|---|---|---|
| 1 | **Conflito de merge** com as 4 branches remotas abertas | Alta | Alto | Fases 2 e 3 em janela combinada; toda branch integrada ou rebaseada antes; anunciar no grupo da equipe |
| 2 | **Perda de dados Isar** por renomear classe de coleção | Média | Alto | Regra explícita (§6.3): as 3 classes `@Collection()` **não** são renomeadas, apenas movidas |
| 3 | **Codegen dessincronizado** após mover models | Alta | Médio | `dart run build_runner build --delete-conflicting-outputs` ao fim de cada lote que toca models |
| 4 | Renomear pacote quebra imports em massa | Alta | Médio | Fase 1 isolada, só isso; *Replace in Files* com revisão do diff; CI valida |
| 5 | Reestruturação consumir tempo de entrega do TCC | Média | Alto | Fases 0 e 1 (≤ 2,5 dias) já entregam a maior parte do valor; Fases 2–3 são adiáveis sem bloquear a Fase 4 |
| 6 | Regressão silenciosa na captura/YOLO | Média | Alto | Roteiro de teste manual fixo ao fim de cada lote: foto → área → detectar → editar → medidas → salvar → reabrir |
| 7 | `applicationId` novo gera app duplicado no device | Alta | Baixo | Desinstalar versão antiga antes de reinstalar; comunicar à equipe |
| 8 | Divergência entre membros sobre a convenção | Média | Médio | Este documento aprovado em reunião + ADR 0001 registrando a decisão |

### 12.1 Roteiro de teste manual (regressão)

Executar ao final de cada lote da Fase 2 e ao final da Fase 3:

1. Abrir o app → Splash renderiza com logo e Poppins
2. Upload DOF → selecionar `dof_exemplo.csv` → 5 itens na tabela
3. "Confirmar e Prosseguir" → Hub lista 5 cards com status `Pendente`
4. Abrir um item → Captura → adicionar foto da galeria
5. Desenhar 1 área → "Detectar" → contagem aparece
6. "Editar" → remover 1 detecção → "Undo" → detecção volta
7. "Medidas" → adicionar grupo (300 / 30 / 5 / qtd) → volume calculado
8. Salvar → voltar ao Hub → status e volume atualizados no card
9. **Fechar o app completamente e reabrir** → Hub mantém os dados (válido a partir do lote 2.E)

---

## 13. Não-objetivos (fora de escopo agora)

Decisões deliberadas de **não** fazer. Registrá-las evita que sejam reabertas a cada sprint e protege o cronograma do TCC.

| Não faremos | Por quê | Quando reconsiderar |
|---|---|---|
| **Monorepo com `packages/` + Melos** | Um único app. Extrair `design_system` para pacote local adiciona tooling sem consumidor. A estrutura `apps/` já deixa o caminho pronto | Quando existir um segundo app (ex.: painel web do comando) |
| **Flavors (dev/hml/prod)** | Não há backend nem ambientes. O app é 100% offline | Se surgir sincronização com servidor |
| **Internacionalização (`l10n`)** | Usuário é a Polícia Ambiental brasileira. Extrair ~200 strings agora é custo puro | Se houver interesse de outro país/estado com outro idioma |
| **`freezed` em todas as classes de estado** | Já está no `pubspec` mas não é usado. Os `copyWith` manuais funcionam e a equipe os entende. Migrar tudo é churn sem ganho funcional | Se `copyWith` manual começar a gerar bugs |
| **Injeção de dependência com `get_it`** | Riverpod já resolve DI. Duas soluções competindo é pior que uma | Nunca, enquanto Riverpod for a escolha |
| **Clean Architecture completa** | §1.3 — cerimônia desproporcional ao tamanho do app | Se o app crescer para dezenas de features |
| **Cobertura de testes ampla de widget** | Caro e frágil. O retorno está em `domain/` | Após a Fase 4, se sobrar tempo |
| **CI com build assinado / distribuição** | Requer keystore e segredos; fora do escopo acadêmico | Se houver entrega real à Polícia Ambiental |
| **Trocar Isar por outro banco** | Isar funciona, tem 3 coleções estáveis e testes verdes | Nunca antes da entrega do TCC |

---

## 14. Anexos

### 14.1 `analysis_options.yaml` proposto

```yaml
analyzer:
  exclude:
    - build/**
    - android/**
    - ios/**
    - web/**
    - windows/**
    - macos/**
    - linux/**
    - "**/*.g.dart"        # código gerado pelo Isar não deve ser lintado
  language:
    strict-casts: true
    strict-raw-types: true
  errors:
    avoid_print: error             # promove a erro: barra print() na CI
    unused_import: error
    unused_local_variable: error

include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_locals
    - prefer_single_quotes
    - require_trailing_commas
    - sort_child_properties_last
    - unawaited_futures
    - use_super_parameters
```

> A exclusão de `**/*.g.dart` é importante: os 4.588 linhas geradas pelo Isar representam 45% do `lib/` e não devem ser objeto de lint.

### 14.2 `.github/workflows/ci.yaml` proposto

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: apps/fiscaliza    # ajustar para src/app antes da Fase 3
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Instalar dependências
        run: flutter pub get

      - name: Verificar formatação
        run: dart format --output=none --set-exit-if-changed .

      - name: Análise estática
        run: flutter analyze --fatal-infos

      - name: Testes
        run: flutter test
```

### 14.3 `tools/check.ps1` proposto

```powershell
# Roda localmente a mesma verificação da CI, antes de abrir PR.
$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot\..\apps\fiscaliza"   # ajustar para src\app antes da Fase 3

Write-Host '==> pub get'  -ForegroundColor Cyan
flutter pub get

Write-Host '==> format'   -ForegroundColor Cyan
dart format --output=none --set-exit-if-changed .

Write-Host '==> analyze'  -ForegroundColor Cyan
flutter analyze --fatal-infos

Write-Host '==> test'     -ForegroundColor Cyan
flutter test

Write-Host 'OK — pronto para PR.' -ForegroundColor Green
```

### 14.4 `bootstrap.dart` proposto

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/logging/app_logger.dart';

/// Inicialização assíncrona do app, isolada do main() para ser testável
/// e para centralizar o tratamento global de erro.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App de campo, usado com uma mão: trava em retrato.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  FlutterError.onError = (details) {
    AppLogger.error('FlutterError', details.exception, details.stack);
  };

  runZonedGuarded(
    () => runApp(const ProviderScope(child: App())),
    (error, stack) => AppLogger.error('Uncaught', error, stack),
  );
}
```

### 14.5 `app_routes.dart` proposto

```dart
/// Caminhos de rota centralizados — elimina strings mágicas espalhadas
/// pelas telas. Foi uma string literal divergente que causou o crash
/// do FAB "Produto Extra" (Achado B).
abstract final class AppRoutes {
  static const splash    = '/';
  static const uploadDof = '/upload-dof';
  static const hub       = '/fiscalizacao';
  static const captura   = '/fiscalizacao/captura';
  static const medidas   = '/fiscalizacao/captura/medidas';
  static const cadastro  = '/fiscalizacao/cadastro';   // faltava registrar
  static const validacao = '/fiscalizacao/validacao';
  static const laudo     = '/fiscalizacao/laudo';
}
```

### 14.6 Glossário do domínio

Vocabulário usado no código e na documentação. Mantido em português por decisão de §10.5.

| Termo | Significado |
|---|---|
| **DOF** | Documento de Origem Florestal — autorização oficial de transporte/armazenamento de produto florestal |
| **Saldo Total** | Volume (m³) autorizado no DOF para o item |
| **Saldo Livre** | Volume ainda não consumido do saldo total |
| **Cubagem** | Medição das peças (comprimento × largura × altura × quantidade) para obter o volume real |
| **Peça** | Unidade física de madeira detectada e contada (tora, prancha, viga, caibro, tábua, ripa) |
| **Excedente** | Volume cubado **maior** que o saldo declarado → indício de irregularidade |
| **Produto Extra** | Item encontrado em campo que **não consta** no DOF |
| **Detecção** | Peça identificada pelo modelo YOLO numa foto |
| **Área** | Retângulo desenhado pelo fiscal para restringir a detecção a uma região da foto |

---

## Aprovação

| Papel | Nome | Aprovação |
|---|---|---|
| Product Owner | Sarah | ☐ |
| Scrum Master | Matheus Germano | ☐ |
| Technical Lead | João Pedro | ☐ |
| Equipe de Desenvolvimento | Vitor · Henrique Dornellas · Henrique Hikaru · Gabriel Heleno | ☐ |

**Próximo passo após aprovação:** executar a Fase 0 — ela não move nenhum arquivo, não gera conflito com branches abertas e já elimina os 3 achados críticos 🔴 (crash do FAB, tema não aplicado, nome do produto com erro de digitação).

---

*Documento vivo. Alterações relevantes de arquitetura devem gerar um ADR em `docs/04-decisoes/`.*
