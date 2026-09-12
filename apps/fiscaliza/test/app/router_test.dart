import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:fiscaliza/app/router/app_router.dart';
import 'package:fiscaliza/app/router/app_routes.dart';

void main() {
  late ProviderContainer container;
  late GoRouter router;

  setUp(() {
    container = ProviderContainer();
    router = container.read(routerProvider);
  });

  tearDown(() => container.dispose());

  List<String> pathsRegistrados(List<RouteBase> routes) => [
    for (final r in routes)
      if (r is GoRoute) ...[r.path, ...pathsRegistrados(r.routes)],
  ];

  const declaradas = <String>[
    AppRoutes.splash,
    AppRoutes.home,
    AppRoutes.historico,
    AppRoutes.uploadDof,
    AppRoutes.hub,
    AppRoutes.concluir,
    AppRoutes.cadastro,
    AppRoutes.validacao,
    AppRoutes.captura,
    AppRoutes.medidas,
  ];

  test('toda rota declarada em AppRoutes está registrada no router', () {
    final registradas = pathsRegistrados(router.configuration.routes);

    for (final rota in declaradas) {
      expect(
        registradas,
        contains(rota),
        reason: '$rota está em AppRoutes mas não foi registrada no router',
      );
    }
  });

  test('não há rota registrada fora de AppRoutes', () {
    final registradas = pathsRegistrados(router.configuration.routes);

    for (final rota in registradas) {
      expect(
        declaradas,
        contains(rota),
        reason: '$rota foi registrada mas não existe como constante',
      );
    }
  });

  test('não há caminho duplicado', () {
    final registradas = pathsRegistrados(router.configuration.routes);
    expect(registradas.toSet().length, registradas.length);
  });

  test('a rota inicial é a splash', () {
    expect(router.configuration.routes.whereType<GoRoute>().first.path,
        AppRoutes.splash);
  });

  test('toda constante de rota começa com barra', () {
    for (final rota in declaradas) {
      expect(rota.startsWith('/'), isTrue, reason: rota);
    }
  });
}
