import 'package:app/features/dof/presentation/screens/upload_dof_screen.dart';
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
    ],
  );
});
