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
          path: ':finalidad/list-envios',
          builder: (context, state) {
            final finalidadStr = state.pathParameters['finalidad'];
            final finalidad = EntregasFinalidad.values.firstWhere(
              (e) => e.toString().split('.').last == finalidadStr,
              orElse: () => EntregasFinalidad
                  .registro, // Valor predeterminado en caso de que no haya coincidencia
            );
            return EntregasListaEnvios(
              finalidad: finalidad,
            );
          },
        ),
        GoRoute(
          path: ':id/list-entregas',
          builder: (context, state) {
            final idEnvio = state.pathParameters['id'] ?? '';
            return EntregasLista(
              idEnvio: idEnvio,
            );
          },
        ),
        GoRoute(
          path: ':id/add-entrega',
          builder: (context, state) {
            final idEnvio = state.pathParameters['id'] ?? '';
            return EntregasFormulario(
              idEnvio: idEnvio,
            );
          },
        ),
        GoRoute(
          path: ':id/add-incidente',
          builder: (context, state) {
            final idEnvio = state.pathParameters['id'] ?? '';
            return EntregasFormularioIncidente(
              idEnvio: idEnvio,
            );
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
