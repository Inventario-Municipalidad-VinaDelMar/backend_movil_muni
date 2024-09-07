import 'package:frontend_movil_muni/src/pages/pages.dart';
import 'package:frontend_movil_muni/src/pages/tandas/add_tandas_page.dart';
import 'package:frontend_movil_muni/src/pages/tandas/tandas_page.dart';
import 'package:go_router/go_router.dart';

final mainRouter = GoRouter(
  initialLocation: '/',
  // initialLocation: '/tandas/add',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/tandas',
      builder: (context, state) => const TandasPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) {
            return const AddTandasPage();
          },
        ),
      ],
    ),
  ],
);
