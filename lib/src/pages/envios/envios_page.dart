import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EnviosPage extends StatefulWidget {
  const EnviosPage({super.key});

  @override
  State<EnviosPage> createState() => _EnviosPageState();
}

class _EnviosPageState extends State<EnviosPage> {
  final List<Map<String, dynamic>> invoices = List.generate(
      5,
      (index) => {
            'nombre': index < 4
                ? ['Legumbres', 'Bebida', 'Cubiertos', 'Panaderia'][index]
                : 'Panaderia',
            'accion': 'cargar>>',
            'checked': false, // Agregar estado del checkbox
          });
  Map<String, dynamic> ejemploDataReal = {
    //?Incialmente(Antes de apretar el boton "Iniciar nuevo envio").
    "envioIniciado": null,

    //?Luego de presionar el boton "Iniciar nuevo envio".
    // "envioIniciado":{
    //   "id":'7cf54f1a-0ecb-43ab-bcbb-d42764d802d0',
    // },

    //*Cuando se presione el boton "Completar el envio", el campo
    //* "envioIniciado", vuelve a null y los checkboxs su propiedad "isComplete"
    //* vuelven a false. Es decir al estado inicial.

    "id": "4edded3a-fa78-4e35-b824-5f61645005f7",
    "fecha": "2024-09-04",
    "detalles": [
      {
        "id": "7cf54f1a-0ecb-43ab-bcbb-d42764d802d0",
        "cantidadPlanificada": 15,
        "categoria": "Arroz",
        "isComplete": false, //Indica si es el checkbox esta "checked" o no.
        "categoriaId": "f0b1ac2a-a958-40c1-95f0-ff48890b6199",
        "urlImagen":
            "https://www.lafallera.es/wp-content/uploads/2023/04/Cocción-para-el-arroz-largo-pasos-y-trucos.jpg"
      },
      {
        "id": "5bdf1f30-c35b-4d5f-a319-b392376e581d",
        "cantidadPlanificada": 88,
        "categoria": "Panadería",
        "isComplete": false, //Indica si es el checkbox esta "checked" o no.
        "categoriaId": "c14d0c57-c188-43fd-b6d2-8db7d6114b05",
        "urlImagen":
            "https://thefoodtech.com/wp-content/uploads/2023/10/PANADERIA-PRINCIPAL-1.jpg"
      },
      {
        "id": "4f0991c5-d895-4293-8053-2a775f1505b6",
        "cantidadPlanificada": 25,
        "categoria": "Bebidas",
        "isComplete": false, //Indica si es el checkbox esta "checked" o no.
        "categoriaId": "54f1a538-2c2b-42c1-b6a6-ab4d360b73d2",
        "urlImagen":
            "https://www.dietdoctor.com/wp-content/uploads/2017/04/Guide_Drinks_16x9b.jpg"
      },
      {
        "id": "7c4194a5-6523-4b87-bfbb-2ab07a020518",
        "cantidadPlanificada": 150,
        "categoria": "Cubiertos",
        "isComplete": false, //Indica si es el checkbox esta "checked" o no.
        "categoriaId": "dee88b0b-0f38-4f10-87fa-dbf972038595",
        "urlImagen":
            "https://eurohome.cl/cdn/shop/products/0302.914-5_1800x.jpg?v=1637683715"
      }
    ]
  };
  bool envioIniciado = false;

  bool _todosSeleccionados() {
    return invoices.every((invoice) => invoice['checked'] == true);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificacion'),
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
                              onChanged: envioIniciado
                                  ? (value) {
                                      setState(() {
                                        invoice['checked'] = value;
                                      });
                                    }
                                  : null,
                              color: envioIniciado ? null : Colors.grey,
                            ),
                          ),
                        ),
                        ShadTableCell(
                          child: SizedBox(
                            height: size.height * 0.045,
                            child: Center(
                              child: ShadButton(
                                enabled: envioIniciado ? true : false,
                                size: ShadButtonSize.sm,
                                onPressed: envioIniciado
                                    ? () {
                                        context.push('/envioBuscar');
                                      }
                                    : null,
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
              enabled:
                  envioIniciado ? envioIniciado && _todosSeleccionados() : true,
              size: ShadButtonSize.lg,
              onPressed: () {
                setState(() {
                  if (envioIniciado) {
                    Navigator.pop(context);
                  } else {
                    envioIniciado = !envioIniciado;
                  }
                });
              },
              icon: const Icon(Icons.swipe_up_outlined),
              child: Text(
                envioIniciado ? 'Completar envío' : 'Iniciar nuevo envío',
                style: textStyles.h4.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
