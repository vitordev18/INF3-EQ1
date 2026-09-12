import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fiscaliza/app/router/app_routes.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/dof/presentation/upload/upload_dof_screen.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/cadastro/cadastro_screen.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/captura_screen.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/hub/concluir_fiscalizacao_screen.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/hub/hub_fiscalizacao_screen.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/medidas/medidas_screen.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/validacao/validacao_screen.dart';
import 'package:fiscaliza/features/historico/presentation/screens/historico_screen.dart';
import 'package:fiscaliza/features/home/presentation/screens/home_screen.dart';
import 'package:fiscaliza/features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.historico,
        builder: (context, state) => const HistoricoScreen(),
      ),
      GoRoute(
        path: AppRoutes.uploadDof,
        builder: (context, state) => const UploadDofScreen(),
      ),
      GoRoute(
        path: AppRoutes.hub,
        builder: (context, state) => const FiscalizacaoHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.concluir,
        builder: (context, state) => const ConcluirFiscalizacaoScreen(),
      ),
      GoRoute(
        path: AppRoutes.cadastro,
        builder: (context, state) => const CadastroScreen(),
      ),
      GoRoute(
        path: AppRoutes.validacao,
        builder: (context, state) => const ValidacaoScreen(),
      ),
      GoRoute(
        path: AppRoutes.captura,
        builder: (context, state) {
          final item = state.extra;
          if (item is! DofItemModel) return const FiscalizacaoHubScreen();
          return CapturaScreen(dofItem: item);
        },
      ),
      GoRoute(
        path: AppRoutes.medidas,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Map<String, dynamic>) {
            return const FiscalizacaoHubScreen();
          }
          final dofItem = extra['dofItem'];
          final fotoIndex = extra['fotoIndex'];
          if (dofItem is! DofItemModel || fotoIndex is! int) {
            return const FiscalizacaoHubScreen();
          }
          return MedidasScreen(dofItem: dofItem, fotoIndex: fotoIndex);
        },
      ),
    ],
  );
});
