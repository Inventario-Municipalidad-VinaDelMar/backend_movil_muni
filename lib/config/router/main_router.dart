import 'package:frontend_movil_muni/src/pages/auth/auth_page.dart';
import 'package:frontend_movil_muni/src/pages/envios/buscar_envios_page.dart';
import 'package:frontend_movil_muni/src/pages/envios/envios_page.dart';
import 'package:frontend_movil_muni/src/pages/pages.dart';
import 'package:frontend_movil_muni/src/pages/tandas/add_tandas_page.dart';
import 'package:go_router/go_router.dart';

import '../../src/providers/provider.dart';

UserProvider _userProvider = UserProvider();

final mainRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _userProvider.userListener,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => AuthPage()),
    GoRoute(
      path: '/envio',
      builder: (context, state) => const EnviosPage(),
      routes: [
        GoRoute(
          path: ':id/tandas',
          builder: (context, state) {
            final idProducto = state.pathParameters['id'] ?? '';
            return BuscarEnviosPage(productoId: idProducto);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/tandas/add',
      builder: (context, state) => const AddTandasPage(),
    ),
  ],
  redirect: (context, state) {
    final isGoingTo = state.matchedLocation;
    final user = _userProvider.userListener.value;

    if (user == null) {
      if (isGoingTo == '/login') return null;

      return '/login';
    }

    if (isGoingTo == '/login')
    // isGoingTo == '/register' ||
    // isGoingTo == '/splash')
    {
      return '/';
    }
    return null;
  },
);
