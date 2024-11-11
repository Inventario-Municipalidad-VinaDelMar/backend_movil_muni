import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/common/style_by_status.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/envio_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/socket/socket_envio_provider.dart';
import 'package:frontend_movil_muni/src/widgets/generic_text_input.dart';
import 'package:frontend_movil_muni/src/widgets/time_since.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FormReingresos extends StatefulWidget {
  const FormReingresos({super.key});

  @override
  State<FormReingresos> createState() => _FormReingresosState();
}

class _FormReingresosState extends State<FormReingresos> {
  late EnvioProvider _envioProvider;
  EnvioLogisticoModel? envioSelected;
  int? indexSelected;
  List<ProductoEnvio> productos = [];
  TextEditingController controllerComentario = TextEditingController();
  ScrollController singleChildSc = ScrollController();
  final formKey = GlobalKey<ShadFormState>();
  @override
  void initState() {
    _envioProvider = context.read<EnvioProvider>();
    _envioProvider.connect([EnvioEvent.enviosByFecha]);
    super.initState();
  }

  @override
  void dispose() {
    _envioProvider.disconnect([EnvioEvent.enviosByFecha]);
    super.dispose();
  }

  Future<void> scrollToBottom() async {
    int delay = 500;
    await Future.delayed(Duration(milliseconds: delay));
    singleChildSc.animateTo(
      singleChildSc.position.maxScrollExtent,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final envioProvider = context.watch<EnvioProvider>();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[500],
        title: Text(
          'Re-ingresar productos',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: singleChildSc,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: ShadForm(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Para hacer una devolución de productos, seleccione de que envío provienen:',
                  style: textStyles.p.copyWith(
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
                envioProvider.loadingEnvios
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: size.height * 0.36,
                        // color: Colors.red,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.03),
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          itemCount: envioProvider.enviosLogisticos
                              .where((envio) =>
                                  envio.status == EnvioStatus.enEnvio ||
                                  envio.status == EnvioStatus.finalizado)
                              .toList()
                              .length,
                          itemBuilder: (context, i) {
                            final envio = envioProvider.enviosLogisticos
                                .where((envio) =>
                                    envio.status == EnvioStatus.enEnvio ||
                                    envio.status == EnvioStatus.finalizado)
                                .toList()[i];

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    indexSelected = i;
                                    envioSelected = envio;
                                    productos.clear();
                                  });
                                  setState(() {
                                    productos = List.from(envio.productos);
                                  });
                                  scrollToBottom();
                                },
                                child: Opacity(
                                  // opacity: 1,
                                  opacity: i == indexSelected ? 1 : .6,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        right: size.width * 0.05),
                                    child: _MiniCardEnvio(
                                      envio: envio,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                if (envioSelected == null)
                  FadeInLeft(
                    duration: Duration(milliseconds: 200),
                    child: Text(
                      'Solo figuran envios "finalizados".',
                      style: textStyles.small.copyWith(
                        color: Colors.black38,
                      ),
                    ),
                  ),
                if (envioSelected != null) ...[
                  FadeInLeft(
                    duration: Duration(milliseconds: 200),
                    child: GenericTextInput(
                      controller: controllerComentario,
                      maxLength: 87,
                      maxLines: 2,
                      labelText: 'Comentario',
                      placeHolder: 'Razón de la devolución...',
                      id: 'comentario',
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Es necesario comentar la razón de la devolución';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.015,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Productos a re-ingresar',
                      style: textStyles.p.copyWith(
                        color: Colors.black87,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.015,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: productos.length,
                    itemBuilder: (context, i) {
                      final producto = productos[i];
                      return FadeInRight(
                        duration: Duration(milliseconds: 200),
                        delay: Duration(milliseconds: i * 150),
                        child: Opacity(
                          opacity: producto.cantidad <= 0 ? 0.5 : 1.0,
                          child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.03,
                                vertical: size.height * 0.01,
                              ),
                              margin:
                                  EdgeInsets.only(bottom: size.height * 0.01),
                              width: double.infinity,
                              // height: size.height * 0.1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Colors.lightBlueAccent,
                                    Colors.blue[700]!,
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        producto.producto,
                                        style: textStyles.small.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                  // SizedBox(
                                  //   height: size.height * 0.008,
                                  // ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: size.height * 0.05,
                                        height: size.height * 0.05,
                                        child: ShadAvatar(
                                          producto.urlImagen,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      Spacer(),
                                      ShadBadge(
                                        backgroundColor: Colors.red[300],
                                        child: producto.cantidad <= 0
                                            ? Text(
                                                'No hay unidades disponibles.')
                                            : Text(
                                                'Devolución --> ${producto.cantidad}   unidades',
                                              ),
                                      )
                                    ],
                                  ),
                                ],
                              )),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  ShadButton(
                    onPressed: () {
                      if (!formKey.currentState!.saveAndValidate()) {
                        return;
                      }
                      //TODO: Ingresar devolución
                      context.pop();
                    },
                    size: ShadButtonSize.lg,
                    width: double.infinity,
                    child: Text('Confirmar devolución'),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCardEnvio extends StatelessWidget {
  final EnvioLogisticoModel envio;
  const _MiniCardEnvio({required this.envio});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    final statusStyle = getStatusStyle(envio);
    return Container(
      padding: EdgeInsets.only(
        top: size.height * 0.01,
        bottom: size.height * 0.013,
        left: size.width * 0.03,
        right: size.width * 0.03,
      ),
      width: size.width * 0.5,
      height: size.height * 0.3,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width * 0.38,
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: size.height * 0.001,
            ),
            decoration: BoxDecoration(
              color: statusStyle['color'],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (statusStyle['textColor'] as Color).withOpacity(.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(4, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  statusStyle['icon'],
                  color: statusStyle['textColor'],
                  size: size.height * 0.03,
                ),
                const SizedBox(width: 6),
                Text(
                  statusStyle['label'],
                  style: TextStyle(
                    color: statusStyle['textColor'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.006),
          Row(
            children: [
              Text('Fecha'),
              Spacer(),
              Text(
                envio.getFechaFormatted(),
              ),
            ],
          ),
          Row(
            children: [
              Text('Creacion'),
              Spacer(),
              Text(
                envio.getHoraCreacionFormatted(),
              ),
            ],
          ),
          Row(
            children: [
              Text('Finalizacion'),
              Spacer(),
              Text(
                envio.getHoraFinalizacionFormatted(),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.008),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tiempo en envio'),
                envio.horaInicioEnvio == null
                    ? Text('-')
                    : TimeSinceWidget(
                        horaInicioEnvio: envio.horaInicioEnvio!,
                        horaFinalizacion: envio.horaFinalizacion,
                        style: textStyles.small.copyWith(
                          color: colors.muted,
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Spacer(),
          SizedBox(
            height: size.height * 0.07,
            width: double.infinity,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: envio.productos.length,
              itemBuilder: (context, i) {
                final producto = envio.productos[i];
                return Container(
                  margin: EdgeInsets.only(right: size.width * 0.01),

                  // width: size.height * 0.01,
                  // height: size.height * 0.01,
                  child: ShadAvatar(
                    producto.urlImagen,
                    backgroundColor: Colors.transparent,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
