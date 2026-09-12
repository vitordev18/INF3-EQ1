# Fiscaliza — app

App Flutter de apoio à fiscalização de madeireiras pela Polícia Ambiental.

Confronta o **volume declarado no DOF** com o **volume cubado em campo**:
o fiscal fotografa as pilhas, o YOLO embarcado conta as peças, o fiscal informa
as dimensões e o app deriva o status do item — `emAndamento`, `concluido` ou
`excedente` (madeira além do autorizado).

## Rodando

```bash
flutter pub get
flutter run
```

## Verificação antes do PR

```bash
flutter analyze --fatal-infos
flutter test
```

Ou, da raiz do repositório, `.\tools\check.ps1` — é o que a CI roda.

## Organização do `lib/`

```
app/            MaterialApp + rotas (app_router.dart, app_routes.dart)
core/           Infra transversal: database, ml, logging, utils, constants
design_system/  theme/, components/, dialogs/, painters/
features/
  dof/          Importação e validação da planilha DOF
  fiscalizacao/ Captura, contagem, cubagem e status — o núcleo do produto
  home/         Hub de início
  historico/    Fiscalizações anteriores
  splash/
```

Regra de dependência: `presentation → domain ← data`. `domain/` é Dart puro.
Nenhuma feature importa `presentation/` de outra feature.

Convenções, mapa de arquivos e plano de evolução em
[docs/02-arquitetura/PLANO-DE-REESTRUTURACAO.md](../../docs/02-arquitetura/PLANO-DE-REESTRUTURACAO.md).

## Codegen

Modelos Isar usam `build_runner`. Após alterar um `@Collection()`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> Não renomeie as classes `@Collection()` (`DofItemModel`,
> `FiscalizacaoRegistroModel`, `MedicaoGrupoModel`, `FiscalizacaoSessaoModel`):
> o Isar deriva o nome da coleção do nome da classe e renomear torna
> inacessíveis os dados já gravados nos dispositivos.
