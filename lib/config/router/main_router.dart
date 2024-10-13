import 'package:frontend_movil_muni/src/pages/auth/auth_page.dart';
import 'package:frontend_movil_muni/src/pages/envios/buscar_envios_page.dart';
import 'package:frontend_movil_muni/src/pages/envios/envios_page.dart';
import 'package:frontend_movil_muni/src/pages/pages.dart';
import 'package:frontend_movil_muni/src/pages/tandas/add_tandas_page.dart';
import 'package:go_router/go_router.dart';

final mainRouter = GoRouter(
  initialLocation: '/',
  // initialLocation: '/tandas/add',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/auth', builder: (context, state) => AuthPage()),
    GoRoute(
      path: '/envio',
      builder: (context, state) => const EnviosPage(),
      routes: [
        GoRoute(
          path: ':id/tandas',
          builder: (context, state) {
            final idProducto = state.pathParameters['id'] ?? '';
            print('Parametro router: $idProducto');
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
);
