import 'package:frontend_movil_muni/src/pages/pages.dart';
import 'package:go_router/go_router.dart';

final mainRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
  ],
);
