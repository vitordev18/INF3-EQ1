# Fiscaliza — app

App Flutter de vistoria/fiscalização, 100% offline (armazenamento local via Isar). Roda em Android, iOS, Windows, Linux, macOS e Web.

### 1. Instalar o FVM 

- **Windows**: `choco install fvm` (Chocolatey) ou, se já tiver Dart/Flutter instalado, `dart pub global activate fvm`
- **macOS**: `brew tap leoafarias/fvm && brew install fvm`
- **Linux**: `curl -fsSL https://fvm.app/install.sh | bash`

Confirme a instalação em qualquer terminal novo: `fvm --version`.

### 2. Instalar e usar a versão travada do projeto

Dentro da pasta `app/` (onde está este README):

```
fvm install
fvm flutter pub get
```

O `fvm install` lê o `.fvmrc`, baixa aquela versão exata do Flutter (uma vez só, fica em cache global) e cria uma pasta `.fvm/` local apontando pra ela. O `fvm flutter pub get` baixa as dependências do `pubspec.lock` usando essa versão travada.

A partir daqui, **todo comando Flutter/Dart do projeto deve ser prefixado com `fvm`**: `fvm flutter run`, `fvm flutter build windows`, `fvm dart run build_runner build`, etc. Rodar `flutter` sem o prefixo usa a versão global do PC, que pode divergir da travada aqui.

### 3. Apontar a IDE para a versão travada (recomendado)

- **VS Code**: em `.vscode/settings.json` do projeto, adicione `"dart.flutterSdkPath": ".fvm/flutter_sdk"`.
- **Android Studio / IntelliJ**: em *Settings → Languages & Frameworks → Flutter*, aponte o SDK path para `<pasta do projeto>/.fvm/flutter_sdk`.

Isso garante que autocomplete, análise e debug da IDE usem a mesma versão do `fvm flutter run`.

## Checklist rápido pra um PC novo

1. Instalar FVM (passo 1 acima).
2. Clonar o repo e entrar em `INF3-EQ1/src/app`.
3. `fvm install && fvm flutter pub get`.
4. Instalar o toolchain nativo da(s) plataforma(s) que for buildar (seção acima).
5. `fvm flutter doctor` — resolver qualquer item marcado com erro antes de rodar o app.
6. `fvm flutter run`.

## Sobre o projeto

App de vistoria/fiscalização com captura de fotos, marcação de áreas/regiões, classificação por modelo TFLite embarcado e geração de relatórios (PDF/Excel), tudo funcionando offline com persistência local em Isar.
