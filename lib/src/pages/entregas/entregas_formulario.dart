import 'package:animate_do/animate_do.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EntregasFormulario extends StatefulWidget {
  final String idEnvio;
  const EntregasFormulario({
    super.key,
    required this.idEnvio,
  });

  @override
  State<EntregasFormulario> createState() => _EntregasFormularioState();
}

class _EntregasFormularioState extends State<EntregasFormulario> {
  late EnvioProvider _envioProvider;
  late EnvioLogisticoModel envio;
  @override
  void initState() {
    _envioProvider = context.read<EnvioProvider>();
    final envioFounded = _envioProvider.findEnvioById(widget.idEnvio);
    if (envioFounded == null) {
      context.pop();
    }
    envio = envioFounded!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Scaffold(
      backgroundColor:
          Colors.grey[200], // Cambiamos el fondo a un color más suave
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: Text(
          'Nueva entrega',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoEnvioPreview(
            envio: envio,
          ),
          SizedBox(
            height: size.height * 0.1,
          ),
          ZoomIn(
            duration: Duration(milliseconds: 200),
            delay: Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Producto entregados',
                style: textStyles.h4,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          FadeInRight(
            duration: Duration(milliseconds: 200),
            delay: Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: DottedBorder(
                color: Colors.blue.withOpacity(.7),
                dashPattern: const [4.5, 4.5, 4.5, 4.5],
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                padding: EdgeInsets.all(6),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Container(
                    height: size.height * 0.1,
                    width: double.infinity,
                    color: Colors.blue[500]!.withOpacity(.2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        ShadButton(
                          size: ShadButtonSize.sm,
                          icon: Icon(Icons.add),
                          child: Text('Registrar producto'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _InfoEnvioPreview extends StatelessWidget {
  const _InfoEnvioPreview({
    required this.envio,
  });

  final EnvioLogisticoModel envio;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 15,
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          FadeInDown(
            duration: Duration(milliseconds: 200),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue[800],
              ),
              width: size.width,
              height: size.width * 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeIn(
                    duration: Duration(milliseconds: 200),
                    delay: Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        envio.statusToString(),
                        style: textStyles.p.copyWith(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  FadeIn(
                    duration: Duration(milliseconds: 200),
                    delay: Duration(milliseconds: 700),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fechaToLargeName(envio.fecha),
                            style:
                                textStyles.small.copyWith(color: Colors.white),
                          ),
                          Spacer(),
                          Text(
                            envio.getHoraFormatted(),
                            style:
                                textStyles.small.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  FadeIn(
                    duration: Duration(milliseconds: 200),
                    delay: Duration(milliseconds: 800),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cargamento actual',
                            style: textStyles.h4.copyWith(color: Colors.white),
                          ),
                          Spacer(),
                          Icon(
                            MdiIcons.truckCargoContainer,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.085,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            child: FadeInUp(
              duration: Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.3,
                      ),
                      offset: Offset(2, 4),
                      blurRadius: 15,
                      spreadRadius: -3,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blueAccent.withOpacity(.95),
                ),
                width: size.width * 0.7,
                height: size.width * 0.4,
                child: FadeIn(
                  duration: Duration(milliseconds: 200),
                  delay: Duration(milliseconds: 900),
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                      bottom: 5,
                    ),
                    // scrollDirection: Axis.horizontal,
                    itemCount: envio.productos.length,
                    itemBuilder: (context, i) {
                      final producto = envio.productos[i];

                      return FadeInLeft(
                        duration: Duration(milliseconds: 200),
                        delay: Duration(milliseconds: (i * 150) + 900),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          width: double.infinity,
                          height: size.height * 0.05,
                          // color: Colors.black,
                          child: Row(
                            children: [
                              ZoomIn(
                                duration: Duration(milliseconds: 200),
                                delay: Duration(milliseconds: (i * 150) + 1100),
                                child: ShadAvatar(
                                  producto.urlImagen,
                                  fit: BoxFit.contain,
                                  backgroundColor: Colors.transparent,
                                  size: Size(
                                    size.height * 0.06,
                                    size.height * 0.06,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.05),
                              SizedBox(
                                width: size.width * 0.35,
                                child: Flexible(
                                  child: Wrap(
                                    children: [
                                      Text(
                                        producto.producto,
                                        style: textStyles.small.copyWith(
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),
                              ShadBadge(
                                child: Text(
                                  '${producto.cantidad}',
                                  style: textStyles.small.copyWith(
                                    color: Colors.white,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
