import 'package:frontend_movil_muni/src/pages/pages.dart';
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
      path: '/entregas',
      builder: (context, state) => EntregasPage(),
      routes: [
        GoRoute(
          path: 'list-envios',
          builder: (context, state) {
            // final idProducto = state.pathParameters['id'] ?? '';
            return EntregasListaEnvios();
          },
        ),
        GoRoute(
          path: 'list-entregas',
          builder: (context, state) {
            // final idProducto = state.pathParameters['id'] ?? '';
            return EntregasLista();
          },
        ),
      ],
    ),
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
