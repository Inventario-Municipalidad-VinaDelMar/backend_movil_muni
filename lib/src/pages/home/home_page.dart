import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/planificacion_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; // Obtenemos el tamaño de la pantalla
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;

    //NO BORRAR LAS SIGUIENTE LINEAS HASTA QUE ESTÉ LISTO EL LOGIN
    final inventarioProvider = context.watch<InventarioProvider>();
    final planificacionProvider = context.watch<PlanificacionProvider>();

    // Data para cada tarjeta (con iconos temporales)
    final List<Map<String, dynamic>> gridItems = [
      {
        'title': 'Envios',
        'subtitle': 'Genera un envío según planificación',
        'footer': '4 Items',
        'icon': AnimateIcons.bell,
        'route': '/envio'
      },
      {
        'title': 'Productos',
        'subtitle': 'Añade tandas de productos',
        'footer': '',
        'icon': AnimateIcons.paid,
        'route': '/tandas/add'
      },
      {
        'title': 'Entregas',
        'subtitle': 'Registra entregas a Comedores Solidarios',
        'footer': '',
        'icon': AnimateIcons.compass,
        'route': '/envio'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.all(size.height * 0.008),
          child: Image.asset(
            'assets/logos/stocknow.png',
          ),
        ),
        leadingWidth: size.width * 0.2,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.settings,
              size: 30,
              color: Colors.white,
            ),
          )
        ],
        title: Text(
          'Inicio',
          style: textStyles.h2.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Dos columnas
            crossAxisSpacing: 16, // Espacio horizontal entre tarjetas
            mainAxisSpacing: 16, // Espacio vertical entre tarjetas
            childAspectRatio: size.width /
                (size.height *
                    0.6), // Ajuste dinámico de la proporción de las tarjetas
          ),
          itemCount: gridItems.length,
          itemBuilder: (context, index) {
            final item = gridItems[index];

            return InkWell(
              onTap: () => context.push(item['route']),
              child: SizedBox(
                width: size.width *
                    0.4, // Las tarjetas ocupan el 40% del ancho de la pantalla
                height: size.height *
                    0.3, // Las tarjetas ocupan el 30% del alto de la pantalla
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[300]!],
                      stops: const [
                        0.5,
                        1.0,
                      ], // Gradiente entre dos tonos de azul
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ..._BackgroundCircles._buildCircles(context),
                      Card(
                        color: Colors
                            .transparent, // Hace la tarjeta transparente para que se vea el gradiente
                        elevation:
                            0, // Evitar sombras para que el gradiente se vea más limpio
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 16, left: 16, bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: AnimateIcon(
                                  onTap: () {},
                                  iconType: IconType.continueAnimation,
                                  color: Colors.white,
                                  animateIcon: item['icon'],
                                ),
                              ),
                              SizedBox(height: size.height * 0.015),
                              Text(
                                item['title'],
                                style: textStyles.h4.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['subtitle'],
                                style: textStyles.small.copyWith(
                                  color: Colors.blueGrey[100],
                                  // fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item['footer'],
                                style: textStyles.small.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackgroundCircles {
  static List<Widget> _buildCircles(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    return [
      Positioned(
        top: 0,
        right: -size.height * 0.06,
        child: Container(
          width: size.height * 0.18,
          height: size.height * 0.18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withOpacity(.08),
          ),
        ),
      ),
      Positioned(
        top: 10,
        left: size.width * 0.16,
        child: Container(
          width: size.height * 0.02,
          height: size.height * 0.02,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withOpacity(.1),
          ),
        ),
      ),
      Positioned(
        bottom: 10,
        left: size.width * 0.03,
        child: Container(
          width: size.height * 0.06,
          height: size.height * 0.06,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withOpacity(.1),
          ),
        ),
      ),
    ];
  }
}
