import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:frontend_movil_muni/src/providers/logistica/logistica_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/socket/socket_logistica_provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EntregasPage extends StatefulWidget {
  const EntregasPage({super.key});

  @override
  State<EntregasPage> createState() => _EntregasPageState();
}

class _EntregasPageState extends State<EntregasPage> {
  late LogisticaProvider _logisticaProvider;
  @override
  void initState() {
    _logisticaProvider = context.read<LogisticaProvider>();
    _logisticaProvider.connect(
      [
        LogisticaEvent.enviosByFecha,
      ],
    );
    super.initState();
  }

  @override
  void dispose() {
    _logisticaProvider.disconnect([
      LogisticaEvent.enviosByFecha,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final logisticaProvider = context.watch<LogisticaProvider>();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[500],
        title: Text(
          'Seleccione un envío',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: logisticaProvider.loadingEnvios
          ? Center(child: CircularProgressIndicator())
          : logisticaProvider.enviosLogisticos.isEmpty
              ? ZoomIn(
                  duration: Duration(milliseconds: 200),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon(
                        //   size: 100,
                        //   Icons.no_transfer_outlined,
                        //   color: Colors.grey[500]!.withOpacity(.5),
                        // ),
                        SizedBox(
                          height: size.height * 0.3,
                          child: Image.asset(
                            'assets/logos/empty.png',
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No se han realizados envíos el dia de hoy',
                          style: textStyles.p.copyWith(color: Colors.grey[500]),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        ShadButton(
                          onPressed: () => context.pop(),
                          child: Text('Volver al inicio'),
                        ),
                        SizedBox(
                          height: size.height * 0.2,
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: logisticaProvider.enviosLogisticos.length,
                    itemBuilder: (context, i) {
                      final envio = logisticaProvider.enviosLogisticos[i];

                      return FadeInRight(
                        duration: Duration(milliseconds: 200),
                        delay: Duration(milliseconds: i * 150),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 10),
                          width: double.infinity,
                          height: size.height * 0.4,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  const AssetImage('assets/logos/entrega2.png'),
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                              colorFilter: ColorFilter.mode(
                                Colors.white12,
                                // Colors.white.withOpacity(.05),
                                BlendMode.dstIn,
                              ),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                              colors: [
                                Colors.blue[500]!.withBlue(130),
                                Colors.blue[500]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(
                                    2, 4), // Desplazamiento de la sombra
                                blurRadius: 6, // Difusión de la sombra
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Row(
                                  children: [
                                    ShadBadge(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.08,
                                        vertical: 7,
                                      ),
                                      child: Text(
                                        envio.statusToString(),
                                        style: textStyles.h4.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    ShadAvatar(
                                      size: Size(
                                        size.height * 0.07,
                                        size.height * 0.07,
                                      ),
                                      'assets/logos/camiones3.gif',
                                      backgroundColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),
                              Row(
                                children: [
                                  Text(
                                    'Autorización de: ',
                                    style: textStyles.p.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${envio.solicitud.administrador?.getFullName()}',
                                    style: textStyles.p.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              Row(
                                children: [
                                  Text(
                                    'Fecha creación: ',
                                    style: textStyles.p.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    fechaToLargeName(envio.fecha),
                                    style: textStyles.p.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              Row(
                                children: [
                                  Text(
                                    'Hora de inicio: ',
                                    style: textStyles.p.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    envio.getHoraFormatted(),
                                    style: textStyles.p.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              Row(
                                children: [
                                  Text(
                                    'Hora de termino: ',
                                    style: textStyles.p.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  if (envio.horaFinalizacion == null)
                                    AnimateIcon(
                                      color: Colors.white,
                                      onTap: () {},
                                      animateIcon: AnimateIcons.loading3,
                                      iconType: IconType.continueAnimation,
                                      height: 24,
                                      width: 24,
                                    ),
                                  if (envio.horaFinalizacion != null)
                                    Text(
                                      envio.getHoraFormatted(),
                                      style: textStyles.p.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: envio.productos.map((p) {
                                          return Container(
                                            margin: EdgeInsets.only(left: 4),
                                            child: ShadAvatar(
                                              size: Size(
                                                size.height * 0.05,
                                                size.height * 0.05,
                                              ),
                                              p.urlImagen,
                                              backgroundColor: Colors.white,
                                            ),
                                          );
                                        }).toList() as List<Widget>,
                                      ),
                                      SizedBox(height: size.height * 0.01),
                                      Text(
                                        '${envio.productos.length} productos en reparto',
                                        style: textStyles.small.copyWith(
                                          color: Colors.white,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
