import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EnviosPage extends StatefulWidget {
  const EnviosPage({super.key});

  @override
  State<EnviosPage> createState() => _EnviosPageState();
}

class _EnviosPageState extends State<EnviosPage> {
  final List<Map<String, dynamic>> invoices = List.generate(
      21,
      (index) => {
            'nombre': index < 4
                ? ['Legumbres', 'Bebida', 'Cubiertos', 'Panaderia'][index]
                : 'Panaderia',
            'accion': 'cargar>>',
            'checked': false, // Agregar estado del checkbox
          });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Planificacion', style: textStyles.h4),
      ),
      body: Column(
        children: [
          Center(
            child: SizedBox(
              width: size.width * 0.95,
              height: size.height * 0.82,
              child: ShadTable.list(
                columnSpanExtent: (index) {
                  if (index == 0) {
                    return FixedTableSpanExtent(size.width * 0.3);
                  }
                  if (index == 1) return FixedTableSpanExtent(size.width * 0.3);
                  if (index == 2) {
                    return MaxTableSpanExtent(
                      FixedTableSpanExtent(size.width * 0.15),
                      const RemainingTableSpanExtent(),
                    );
                  }
                  return null;
                },
                header: [
                  ShadTableCell.header(
                    child: Text(
                      'Nombre',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.height * 0.017),
                    ),
                  ),
                  ShadTableCell.header(
                    child: Text(
                      'Completado',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.height * 0.017),
                    ),
                  ),
                  ShadTableCell.header(
                    alignment: Alignment.center,
                    child: Text(
                      'Accion',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.height * 0.017),
                    ),
                  ),
                ],
                children: invoices
                    .map(
                      (invoice) => [
                        ShadTableCell(
                          child: Text(
                            invoice['nombre'],
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: size.height * 0.015),
                          ),
                        ),
                        ShadTableCell(
                          child: Center(
                            child: ShadCheckbox(
                              value: invoice['checked'],
                              onChanged: null,
                            ),
                          ),
                        ),
                        ShadTableCell(
                          child: SizedBox(
                            height: size.height * 0.045,
                            child: ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: () {},
                              icon: const Icon(
                                Icons.search,
                                size: 13,
                              ),
                              child: Text(
                                'Buscar',
                                style: textStyles.small
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    .toList(),
              ),
            ),
          ),
          SizedBox(
            height: size.height * 0.06,
            width: size.width,
            child: ShadButton(
              size: ShadButtonSize.lg,
              onPressed: () {},
              icon: const Icon(Icons.swipe_up_outlined),
              child: Text(
                'Iniciar nuevo envio',
                style: textStyles.h4.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
