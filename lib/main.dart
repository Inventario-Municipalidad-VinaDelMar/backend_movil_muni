import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:frontend_movil_muni/config/theme/app_theme.dart';
import 'package:frontend_movil_muni/src/providers/envios/envios_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/planificacion_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() async {
  await Environment.initEnvironment();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EnviosProvider()),
        ChangeNotifierProvider(create: (_) => PlanificacionProvider()),
        ChangeNotifierProvider(
            create: (_) => InventarioProvider()..initialize()),
      ],
      child: ShadApp.router(
        theme: AppTheme.getShadTheme(size),
        themeMode: ThemeMode.light,
        darkTheme: AppTheme.getDarkShadTheme(size),
        routerConfig: mainRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
