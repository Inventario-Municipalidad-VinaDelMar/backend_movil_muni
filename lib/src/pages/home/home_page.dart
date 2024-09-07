import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    //NO BORRAR LA SIGUIENTE LINEA HASTA QUE ESTÉ LISTO EL LOGIN
    final inventarioProvider = context.watch<InventarioProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio', style: textStyles.h1),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(1, 7),
                    blurRadius: 12,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.paperPlane,
                    size: size.height * 0.03,
                  ),
                  trailing: const FaIcon(
                    FontAwesomeIcons.chevronRight,
                  ),
                  title: Text(
                    'PLANIFICACIÓN - hoy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.018,
                    ),
                  ),
                  subtitle: const Text(
                    'Genera un nuevo envio con productos del inventario.',
                  ),
                  onTap: () {
                    context.push('/envio');
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 12,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.squarePlus,
                    size: size.height * 0.03,
                  ),
                  trailing: const FaIcon(
                    FontAwesomeIcons.chevronRight,
                  ),
                  title: Text(
                    'CREAR TANDA DE PRODUCTOS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.018,
                    ),
                  ),
                  subtitle: const Text(
                    'Añade una nueva tanda de productos al inventario.',
                  ),
                  onTap: () {
                    context.push('/tandas/add');
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 12,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.bus,
                    size: size.height * 0.03,
                  ),
                  trailing: const FaIcon(
                    FontAwesomeIcons.chevronRight,
                  ),
                  title: Text(
                    'CREAR NUEVA ENTREGA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.018,
                    ),
                  ),
                  subtitle: const Text(
                    'Proximamente...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    // Navigator.pushNamed(context, '/');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
