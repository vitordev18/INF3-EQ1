import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/dof/presentation/screens/upload_dof_screen.dart';
import 'package:app/features/fiscalizacao/presentation/captura/captura_screen.dart';
import 'package:app/features/fiscalizacao/presentation/captura/medidas_screen.dart';
import 'package:app/features/fiscalizacao/presentation/screens/fiscalizacao_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/upload-dof', builder: (context, state) => UploadDofScreen()),
      GoRoute(path: '/fiscalizacao', builder: (context, state) => FiscalizacaoHubScreen()),
      GoRoute(
        path: '/fiscalizacao/captura',
        builder: (context, state) {
          final item = state.extra as DofItemModel;
          return CapturaScreen(dofItem: item);
        },
      ),
      GoRoute(
        path: '/fiscalizacao/captura/medidas',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MedidasScreen(
            dofItem: extra['dofItem'] as DofItemModel,
            fotoIndex: extra['fotoIndex'] as int,
          );
        },
      ),
    ],
  );
});
