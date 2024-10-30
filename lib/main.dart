import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:frontend_movil_muni/config/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'src/providers/provider.dart';

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
        ChangeNotifierProvider(create: (_) => UserProvider()..renewUser()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EntregaProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => EnvioProvider()..initialize()),
        ChangeNotifierProvider(
            create: (_) => MovimientoProvider()..initialize()),
        ChangeNotifierProvider(
            create: (_) => PlanificacionProvider()..initialize()),
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
