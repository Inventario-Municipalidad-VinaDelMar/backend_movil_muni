import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_movil_muni/src/pages/envios/sheet_buscar_envios_page.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart' as shad;
import 'package:shadcn_ui/shadcn_ui.dart';

const frameworks = {
  'nextjs': 'Next.js',
  'svelte': 'SvelteKit',
  'nuxtjs': 'Nuxt.js',
  'remix': 'Remix',
  'astro': 'Astro',
};

const invoices = [
  (
    nombre: "Fideos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Arroz",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Lentejas",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Porotos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
  (
    nombre: "Cubiertos",
    cantidad: "500",
    ubicacion: "Rack Azul-1f",
    vencimiento: "2025-09-01",
  ),
];

class BuscarEnviosPage extends StatefulWidget {
  const BuscarEnviosPage({super.key});

  @override
  State<BuscarEnviosPage> createState() => _BuscarEnviosPageState();
}

class _BuscarEnviosPageState extends State<BuscarEnviosPage> {
  var searchValue = '';

  Map<String, String> get filteredFrameworks => {
        for (final framework in frameworks.entries)
          if (framework.value.toLowerCase().contains(searchValue.toLowerCase()))
            framework.key: framework.value
      };

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tandas de productos', style: textStyles.h2),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
            child: SizedBox(
                width: double.infinity,
                child: Text("Bodega", style: textStyles.h3)),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
            child: SizedBox(
              width: double.infinity,
              child: ShadSelect<String>.withSearch(
                minWidth: 180,
                placeholder:
                    Text('Seleccione una bodega', style: textStyles.h4),
                onSearchChanged: (value) => setState(() => searchValue = value),
                searchPlaceholder: const Text('Buscar bodega'),
                options: [
                  if (filteredFrameworks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Bodega no encontrada'),
                    ),
                  ...frameworks.entries.map(
                    (framework) {
                      return Offstage(
                        offstage:
                            !filteredFrameworks.containsKey(framework.key),
                        child: ShadOption(
                          value: framework.key,
                          child: Text(framework.value),
                        ),
                      );
                    },
                  )
                ],
                selectedOptionBuilder: (context, value) =>
                    Text(frameworks[value]!),
              ),
            ),
          ),
          //tabla
          Center(
            child: SizedBox(
              width: size.width * 0.95,
              height: size.height * 0.75,
              child: ShadTable.list(
                header: const [
                  ShadTableCell.header(child: Text('Nombre')),
                  ShadTableCell.header(child: Text('Cantidad')),
                  ShadTableCell.header(
                    alignment: Alignment.center,
                    child: Text('Ubicacion'),
                  ),
                  ShadTableCell.header(child: Text('Vencimiento')),
                ],
                columnSpanExtent: (index) {
                  if (index == 0) {
                    return FixedTableSpanExtent(size.width * 0.22);
                  }
                  if (index == 1) {
                    return FixedTableSpanExtent(size.width * 0.21);
                  }
                  if (index == 2) {
                    return FixedTableSpanExtent(size.width * 0.26);
                  }
                  if (index == 3) {
                    return FixedTableSpanExtent(size.width * 0.26);
                  }

                  return null;
                },
                children: invoices.map(
                  (invoice) => [
                    ShadTableCell(
                      child: InkWell(
                        onTap: () {
                          showShadSheet(
                            side: shad.ShadSheetSide.bottom,
                            context: context,
                            builder: (context) => const SheetBuscarEnviosPage(
                                side: shad.ShadSheetSide.bottom),
                          );
                        },
                        child: Text(
                          invoice.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    ShadTableCell(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          showShadSheet(
                            side: shad.ShadSheetSide.bottom,
                            context: context,
                            builder: (context) => const SheetBuscarEnviosPage(
                                side: shad.ShadSheetSide.bottom),
                          );
                        },
                        child: Text(invoice.cantidad),
                      ),
                    ),
                    ShadTableCell(
                      child: InkWell(
                        onTap: () {
                          showShadSheet(
                            side: shad.ShadSheetSide.bottom,
                            context: context,
                            builder: (context) => const SheetBuscarEnviosPage(
                                side: shad.ShadSheetSide.bottom),
                          );
                        },
                        child: Text(invoice.ubicacion),
                      ),
                    ),
                    ShadTableCell(
                      child: InkWell(
                        onTap: () {
                          showShadSheet(
                            side: shad.ShadSheetSide.bottom,
                            context: context,
                            builder: (context) => const SheetBuscarEnviosPage(
                                side: shad.ShadSheetSide.bottom),
                          );
                        },
                        child: Text(invoice.vencimiento),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
