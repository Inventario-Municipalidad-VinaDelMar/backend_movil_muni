import 'package:animate_do/animate_do.dart';
import 'package:color_mesh/color_mesh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/empty_full_screen.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/envio_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EntregasLista extends StatelessWidget {
  final String idEnvio;
  const EntregasLista({
    super.key,
    required this.idEnvio,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final envio = context.watch<EnvioProvider>().findEnvioById(idEnvio);
    return Scaffold(
      backgroundColor:
          Colors.grey[200], // Cambiamos el fondo a un color más suave
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: Text(
          'Seleccione una entrega',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        width: size.width,
        height: double.infinity,
        // color: Colors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (envio!.entregas.isNotEmpty)
            //   Row(
            //     children: [
            //       Icon(MdiIcons.fileArrowUpDownOutline),
            //       SizedBox(width: size.width * 0.03),
            //       Text(
            //         'Adjunte acta legal',
            //         style: textStyles.p.copyWith(
            //           fontWeight: FontWeight.w500,
            //           color: Colors.black87,
            //         ),
            //       ),
            //     ],
            //   ),
            // SizedBox(height: size.height * 0.013),
            // ShadBadge(child: Text(envio!.)),
            // SizedBox(height: size.height * 0.05),
            SizedBox(height: size.height * 0.01),
            Expanded(
              child: SizedBox(
                child: envio!.entregas.isEmpty
                    ? EmptyFullScreen(
                        emptyMessage:
                            'Aun no se registran entregas en este envio')
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: envio.entregas.length,
                        itemBuilder: (context, i) {
                          final entrega = envio.entregas[i];
                          return FadeInRight(
                            duration: Duration(milliseconds: 200),
                            delay: Duration(milliseconds: (i * 150) + 100),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Sección del Icono de Acta Legal
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: AnimatedMeshGradientContainer(
                                          gradient: MeshGradient(
                                            colors: [
                                              Colors.blue[500]!,
                                              Colors.blueAccent,
                                              Colors.blueAccent[700]!,
                                              Colors.blue,
                                            ],
                                            offsets: const [
                                              Offset(0, 0), // topLeft
                                              Offset(0, 1), // topRight
                                              Offset(1, 0), // bottomLeft
                                              Offset(1, 1), // bottomRight
                                            ],
                                          ),
                                          duration:
                                              Duration(milliseconds: 2000),
                                          child: FadeIn(
                                            duration:
                                                Duration(milliseconds: 400),
                                            child: SizedBox(
                                              height: size.height * 0.185,
                                              width: size.width * 0.25,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    padding: EdgeInsets.all(8),
                                                    child: Icon(
                                                      entrega.urlActaLegal ==
                                                              null
                                                          ? MdiIcons.folderAlert
                                                          : MdiIcons
                                                              .folderCheck,
                                                      color: entrega
                                                                  .urlActaLegal ==
                                                              null
                                                          ? Colors
                                                              .deepOrangeAccent
                                                          : Colors.lime,
                                                      size: 28,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  Text(
                                                    entrega.urlActaLegal == null
                                                        ? 'Acta legal vacía'
                                                        : 'Acta legal cargada',
                                                    textAlign: TextAlign.center,
                                                    style: textStyles.small
                                                        .copyWith(
                                                      color: Colors.white
                                                          .withOpacity(.85),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),

                                      // Información principal
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: size.height * 0.01,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                height: size.height * 0.033,
                                                child: Text(
                                                  '${entrega.hora.split(':')[0]}:${entrega.hora.split(':')[1]} ${entrega.getMedioDia()}',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '${entrega.productosEntregados} productos',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  right: size.width * 0.15,
                                                ),
                                                width: double.infinity,
                                                height: size.height * 0.11,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(MdiIcons.mapMarker,
                                                            size: 16,
                                                            color: Colors.blue),
                                                        SizedBox(width: 0),
                                                        Flexible(
                                                          child: Text(
                                                            entrega
                                                                .comedorSolidario,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black87),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      entrega.comedorDireccion,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                      ),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 8),
                                                  ],
                                                ),
                                              )
                                              // Sección del Realizador
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: size.height * 0.005,
                                    right: size.width * 0.015,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        entrega.realizador,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: size.width * 0.025,
                                    bottom: size.height * 0.03,
                                    child: Container(
                                      width: size.width * 0.1,
                                      height: size.width * 0.1,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[500],
                                        borderRadius: BorderRadius.circular(5),
                                        // shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          MdiIcons.cloudUpload,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () => context.push(
                                          '/entregas/$idEnvio/list-entregas/${entrega.id}',
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
