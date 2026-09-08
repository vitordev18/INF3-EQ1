import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 2026-09-04: teste de hipótese (edge-to-edge causando o bug do bottomBar,
  // ver [[fiscaliza-historico-plano]]) DESCARTADO — o bug persistiu idêntico
  // mesmo sem esta linha. Reativado, já que não fazia diferença.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: App()));
}
