import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ChooseActionPage extends StatelessWidget {
  const ChooseActionPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[500],
        title: Text(
          'Inventario municipalidad',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.02),
              JelloIn(
                duration: Duration(milliseconds: 400),
                child: SizedBox(
                  width: size.width * 0.65,
                  child: Image.asset('assets/logos/munidos.png'),
                ),
              ),
              SizedBox(height: size.height * 0.045),
              FadeInDown(
                duration: Duration(milliseconds: 200),
                delay: Duration(milliseconds: 100),
                child: Text(
                  '¿Qué desea hacer?',
                  style: textStyles.h4.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Wrap(
                spacing: size.width * 0.02,
                runSpacing: size.height * 0.02,
                alignment: WrapAlignment.center,
                children: [
                  ZoomIn(
                    duration: Duration(milliseconds: 200),
                    child: _CustomContainer(
                      route: '/productos/tandas/add',
                      color: Colors.indigo[400]!,
                      icon: MdiIcons.packageVariantClosedPlus,
                      title: 'Tandas',
                      description: 'Añade una tanda de productos nueva.',
                      titleStyle: textStyles.p.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      descriptionStyle: textStyles.small!.copyWith(
                        color: Colors.white70,
                      ),
                      size: size,
                    ),
                  ),
                  ZoomIn(
                    duration: Duration(milliseconds: 200),
                    delay: Duration(milliseconds: 200),
                    child: _CustomContainer(
                      route: '/productos/mermas/add',
                      color: Colors.teal[400]!,
                      icon: MdiIcons.notebookRemoveOutline,
                      title: 'Mermas',
                      description: 'Registra merma de productos.',
                      titleStyle: textStyles.p.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      descriptionStyle: textStyles.small!.copyWith(
                        color: Colors.white70,
                      ),
                      size: size,
                    ),
                  ),
                  ZoomIn(
                    duration: Duration(milliseconds: 200),
                    delay: Duration(milliseconds: 350),
                    child: _CustomContainer(
                      route: '/productos/reingresos/add',
                      color: Colors.deepOrange[400]!,
                      icon: MdiIcons.tableRefresh,
                      title: 'Re-ingresos',
                      description: 'Re-ingresa productos devueltos.',
                      titleStyle: textStyles.p.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      descriptionStyle: textStyles.small!.copyWith(
                        color: Colors.white70,
                      ),
                      size: size,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomContainer extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final Size size;
  final String route;

  const _CustomContainer({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.size,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            offset: Offset(3, 3),
            blurRadius: 8,
          ),
        ],
      ),
      width: size.width * 0.45,
      height: size.height * 0.23,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.3),
                  // shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: size.width * 0.06,
                ),
              ),
              SizedBox(width: size.width * 0.02),
              Text(title, style: titleStyle),
            ],
          ),
          Spacer(),
          Text(description, style: descriptionStyle),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: CircleBorder(),
                // padding: EdgeInsets.all(2),
              ),
              onPressed: () {
                if (!context.mounted) {
                  return;
                }
                // context.push(route);

                // Función que navega a la ruta y verifica el resultado
                Future<void> navigateAndCheckResult() async {
                  final result = await context.push(route);

                  // Si el resultado es true, volver a navegar a la misma página
                  if (result == true && context.mounted) {
                    // await Future.delayed(Duration(
                    //     milliseconds:
                    //         200)); // Un pequeño delay si lo necesitas
                    navigateAndCheckResult(); // Llamar de nuevo para crear el bucle
                  }
                }

                // Llamamos la función de navegación inicial
                navigateAndCheckResult();
              },
              child: Icon(
                MdiIcons.arrowRight,
                color: color,
                size: size.width * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
