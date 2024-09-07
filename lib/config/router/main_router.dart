import 'package:frontend_movil_muni/src/pages/envios/envios_page.dart';
import 'package:frontend_movil_muni/src/pages/pages.dart';
import 'package:go_router/go_router.dart';

final mainRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/envio', builder: (context, state) => EnviosPage()),
  ],
);
