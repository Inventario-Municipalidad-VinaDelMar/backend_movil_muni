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
                        itemCount: envio!.entregas.length,
                        itemBuilder: (context, i) {
                          final entrega = envio.entregas[i];
                          return FadeInRight(
                            duration: Duration(milliseconds: 200),
                            delay: Duration(milliseconds: (i * 50) + 100),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: size.height * 0.02,
                                  ),
                                  width: double.infinity,
                                  height: size.height * 0.24,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
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
                                          // decoration: BoxDecoration(
                                          //   boxShadow: [
                                          //     BoxShadow(
                                          //       color: Colors.blue[700]!
                                          //           .withOpacity(0.25),
                                          //       offset: Offset(2, 4),
                                          //       blurRadius: 15,
                                          //       spreadRadius: -3,
                                          //     ),
                                          //   ],
                                          // gradient: MeshGradient(
                                          //   colors: [
                                          //     Colors.blue[500]!,
                                          //     Colors.blueAccent,
                                          //     Colors.blue[700]!,
                                          //     Colors.blue,
                                          //   ],
                                          //   offsets: const [
                                          //     Offset(0, 0), // topLeft
                                          //     Offset(0, 1), // topRight
                                          //     Offset(1, 0), // bottomLeft
                                          //     Offset(1, 1), // bottomRight
                                          //   ],
                                          // ),
                                          // gradient: LinearGradient(
                                          //   begin: Alignment.bottomLeft,
                                          //   end: Alignment.centerRight,
                                          //   colors: [
                                          //     Colors.blue[700]!,
                                          //     Colors.blue[400]!,
                                          //   ],
                                          // ),
                                          //   borderRadius:
                                          //       BorderRadius.circular(20),
                                          // ),
                                          // height: double.infinity,
                                          // width: size.width * 0.25,
                                          duration:
                                              Duration(milliseconds: 2000),
                                          child: FadeIn(
                                            duration:
                                                Duration(milliseconds: 400),
                                            child: SizedBox(
                                              height: double.infinity,
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
                                      SizedBox(width: size.height * 0.03),
                                      Expanded(
                                        child: SizedBox(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${entrega.hora.split(':')[0]}:${entrega.hora.split(':')[1]} ${entrega.getMedioDia()}',
                                                    style: textStyles.h4,
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    width: size.height * 0.01,
                                                    height: size.height * 0.01,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue
                                                          .withOpacity(.3),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.01,
                                                  ),
                                                  Text(
                                                    '${entrega.productosEntregados} productos',
                                                    style: textStyles.small
                                                        .copyWith(
                                                      color: Colors.black45,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    MdiIcons.mapMarker,
                                                    color: Colors.black45,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      entrega.comedorSolidario,
                                                      style:
                                                          textStyles.p.copyWith(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            size.height * 0.02,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: size.width * 0.07,
                                                  top: size.height * 0.006,
                                                ),
                                                child: Text(
                                                  entrega.comedorDireccion,
                                                  style:
                                                      textStyles.small.copyWith(
                                                    color: Colors.black45,
                                                    fontSize:
                                                        size.height * 0.015,
                                                  ),
                                                  // overflow:
                                                  //     TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Spacer(),
                                              Row(
                                                children: [
                                                  Icon(
                                                    MdiIcons.accountCircle,
                                                    color: Colors.blue
                                                        .withOpacity(.4),
                                                    size: 30,
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15,
                                                            vertical: 5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        color: Colors.blue
                                                            .withOpacity(.2)),
                                                    child: Text(
                                                      entrega.realizador,
                                                      style: textStyles.small
                                                          .copyWith(
                                                        color: Colors.blue
                                                            .withOpacity(.9),
                                                        fontSize:
                                                            size.height * 0.017,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ShadButton(
                                                onPressed: () => context.push(
                                                    '/entregas/$idEnvio/list-entregas/${entrega.id}'),
                                                height: size.height * 0.03,
                                                width: double.infinity,
                                                size: ShadButtonSize.sm,
                                                icon: Text(
                                                  'Adjuntar',
                                                  style:
                                                      textStyles.small.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                child: Icon(
                                                  MdiIcons.cloudUpload,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: size.height * 0.02),
                                  child: Divider(
                                    color: Colors.black12,
                                  ),
                                ),
                              ],
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
