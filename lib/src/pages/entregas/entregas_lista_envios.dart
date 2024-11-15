import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/common/empty_full_screen.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/common/style_by_status.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/socket/socket_envio_provider.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:frontend_movil_muni/src/widgets/time_since.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:animate_do/animate_do.dart';

enum EntregasFinalidad { incidente, registro, actualizacion }

class EntregasListaEnvios extends StatefulWidget {
  final EntregasFinalidad finalidad;
  const EntregasListaEnvios({
    super.key,
    required this.finalidad,
  });

  @override
  State<EntregasListaEnvios> createState() => _EntregasListaEnviosState();
}

class _EntregasListaEnviosState extends State<EntregasListaEnvios> {
  // late EnvioProvider _envioProvider;

  // @override
  // void initState() {
  //   _envioProvider = context.read<EnvioProvider>();
  //   _envioProvider.connect([EnvioEvent.enviosByFecha]);
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   _envioProvider.disconnect([EnvioEvent.enviosByFecha]);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final envioProvider = context.watch<EnvioProvider>();

    return Scaffold(
      backgroundColor:
          Colors.grey[200], // Cambiamos el fondo a un color más suave
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: Text(
          'Seleccione un envío',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: envioProvider.loadingEnvios
          ? const Center(child: CircularProgressIndicator())
          : envioProvider.enviosLogisticos.isEmpty
              ? _buildEmptyState(context, size, textStyles)
              : _buildEnviosList(envioProvider, size, textStyles),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, Size size, ShadTextTheme textStyles) {
    return EmptyFullScreen(
        emptyMessage: 'No se han realizado envíos el día de hoy');
  }

  Widget _buildEnviosList(
      EnvioProvider envioProvider, Size size, ShadTextTheme textStyles) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
          width: size.width,
          child: _buildShadBadge(textStyles),
        ),
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            itemCount: envioProvider.enviosLogisticos.length,
            itemBuilder: (context, i) {
              final envio = envioProvider.enviosLogisticos[i];
              return FadeInRight(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: i * 120),
                child: _buildEnvioCard(envio, size, textStyles),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShadBadge(ShadTextTheme textStyles) {
    String text;
    IconData icon;
    Color color;

    // Configuramos el texto y el icono en función del valor de widget.finalidad
    switch (widget.finalidad) {
      case EntregasFinalidad.incidente:
        text = 'Para registrar un INCIDENTE';
        icon = MdiIcons.truckAlertOutline;
        color = Colors.orange[600]!;
        break;
      case EntregasFinalidad.registro:
        text = 'Para registrar una NUEVA ENTREGA';
        icon = MdiIcons.packageCheck;
        color = Colors.green[600]!;
        break;
      case EntregasFinalidad.actualizacion:
        text = 'Para adjuntar ACTA LEGAL de entrega';
        icon = MdiIcons.folderArrowUp;
        color = Colors.purple[400]!;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        // color: Colors.blue[600],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: textStyles.small.copyWith(color: Colors.white),
          ),
          SizedBox(width: 5),
          Icon(
            icon,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildEnvioCard(
      EnvioLogisticoModel envio, Size size, ShadTextTheme textStyles) {
    String route;

    switch (widget.finalidad) {
      case EntregasFinalidad.incidente:
        route = '/entregas/${envio.id}/add-incidente';
        break;
      case EntregasFinalidad.registro:
        route = '/entregas/${envio.id}/add-entrega';
        break;
      case EntregasFinalidad.actualizacion:
        route = '/entregas/${envio.id}/list-entregas';
        break;
    }
    double top = MediaQuery.of(context).viewPadding.top;
    double bottom = MediaQuery.of(context).viewPadding.bottom;
    double perfectH = (size.height) - (top + bottom);
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        // color: Colors.white70,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned(
              top: -(size.width * 0.08),
              right: -(size.width * 0.125),
              child: ClipPath(
                clipper: CurvedClipper(),
                child: Container(
                  width: size.width * 0.78,
                  height: perfectH * 0.65,
                  color:
                      Colors.blue[700], // Azul para mantener el estilo actual
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: perfectH * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(envio, size, textStyles),
                  // SizedBox(height: size.height * 0.01),
                  _buildInfoRow(
                    label: 'Autorizado por: ',
                    value: envio.autorizante,
                    textStyles: textStyles,
                  ),
                  _buildInfoRow(
                    label: 'Fecha creación: ',
                    value: fechaToLargeName(envio.fecha),
                    textStyles: textStyles,
                  ),

                  _buildInfoRow(
                    label: 'Hora creacion: ',
                    value: envio.getHoraCreacionFormatted(),
                    textStyles: textStyles,
                  ),
                  envio.horaInicioEnvio == null
                      ? _buildInfoRow(
                          label: 'Tiempo en envío: ',
                          value: '-',
                          textStyles: textStyles,
                        )
                      : _buildInfoRowCustom(
                          'Tiempo en envío: ', envio, textStyles),
                  _buildInfoRow(
                    label: 'Ultima entrega en: ',
                    value: envio.entregas.isEmpty
                        ? '-'
                        : envio.entregas.last.comedorSolidario,
                    textStyles: textStyles,
                    activateEllipsis: envio.entregas.isNotEmpty,
                  ),
                  SizedBox(height: size.height * 0.03),
                  _buildEndHourRow(envio, textStyles),
                  _buildInfoRow(
                    label: 'Entregas realizadas: ',
                    value: '${envio.entregas.length}',
                    textStyles: textStyles,
                    keepBlack: true,
                  ),
                  const Divider(),
                  _buildProductsList(envio, size, textStyles),
                  // const Divider(),
                  SizedBox(height: size.height * 0.01),
                  if (envio.status == EnvioStatus.enEnvio ||
                      (envio.status == EnvioStatus.finalizado &&
                          widget.finalidad == EntregasFinalidad.actualizacion))
                    ShadButton(
                      enabled: envio.productos.isNotEmpty &&
                          envio.status != EnvioStatus.cargando &&
                          envio.status != EnvioStatus.sinCargar,
                      onPressed: () => context.push(route),
                      size: ShadButtonSize.sm,
                      width: double.infinity,
                      icon: Icon(MdiIcons.chevronTripleRight),
                      child: Text('Seleccionar'),
                    ),
                  if (envio.incidentes.isNotEmpty)
                    _buildListIncidentes(envio, size, textStyles),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListIncidentes(
      EnvioLogisticoModel envio, Size size, ShadTextTheme textStyles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          'Incidentes informados',
          style: textStyles.p.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.red[800],
            fontSize: size.height * 0.021,
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: size.height * 0.08,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: envio.incidentes.length,
            itemBuilder: (context, i) {
              final incidente = envio.incidentes[i];
              final imageUrl = incidente.evidenciaFotograficaUrl;

              return InkResponse(
                onTap: () => showIncidenteDialog(context, incidente),
                radius: 100,
                child: FutureBuilder(
                  future: _loadImage(imageUrl, context),
                  builder: (context, snapshot) {
                    // Si aún está cargando, mostramos el loader
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: EdgeInsets.all(23),
                        margin: EdgeInsets.only(right: size.width * 0.02),
                        width: size.height * 0.08,
                        height: size.height * 0.08,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[200], // Color de fondo del loader
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }

                    // Si la imagen está cargada o si no hay URL, mostramos el contenido
                    return ZoomIn(
                      duration: Duration(milliseconds: 400),
                      child: Container(
                        margin: EdgeInsets.only(right: size.width * 0.02),
                        width: size.height * 0.08,
                        height: size.height * 0.08,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: imageUrl == null || imageUrl.isEmpty
                              ? Colors.red
                              : null,
                          image: imageUrl != null && imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl == null || imageUrl.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    MdiIcons.truckAlert,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    incidente.type,
                                    style: textStyles.small.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

// Método para cargar la imagen y utilizar `precacheImage`
  Future<void> _loadImage(String? imageUrl, BuildContext context) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await precacheImage(NetworkImage(imageUrl), context);
    }
  }

  void showIncidenteDialog(
    BuildContext context,
    IncidenteEnvio incidente,
  ) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final dialog = ShadDialog.alert(
      constraints: BoxConstraints(
        maxWidth: size.width * 0.9,
      ),
      removeBorderRadiusWhenTiny: false,
      radius: BorderRadius.circular(15),
      title: const Text('Detalles incidente'),
      description: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Motivo'),
                  Spacer(),
                  Text(incidente.type),
                ],
              ),
              Row(
                children: [
                  Text('Fecha'),
                  Spacer(),
                  Text(incidente.fechaFormatted),
                ],
              ),
              Row(
                children: [
                  Text('Hora'),
                  Spacer(),
                  Text(incidente.horaFormatted),
                ],
              ),
              Text('Comentario:'),
              SizedBox(height: size.height * 0.003),
              Text(
                // 'Ea velit id sit incididunt non excepteur officia. Aliqua est elit ad laboris Lorem proident sint in labore Lorem officia Lorem sit. Eu dolore laborum elit quis anim velit consequat cillum elit anim voluptate deserunt non. Consectetur labore proident mollit incididunt in laborum dolor mollit irure laboris laboris. Laborum commodo occaecat incididunt velit aliqua irure adipisicing fugiat duis laboris consequat exercitation ea laboris.',
                '"${incidente.descripcion}"',
                style: textStyles.small.copyWith(
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: size.height * 0.006),
              Text('Evidencia fotografica:'),
              SizedBox(height: size.height * 0.006),
              if (incidente.evidenciaFotograficaUrl == null)
                Center(
                  child: Text(
                    'No se adjunto evidencia fotografica...',
                    style: textStyles.small.copyWith(
                      color: Colors.black45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (incidente.evidenciaFotograficaUrl != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size.height * 0.25,
                      height: size.height * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image:
                              NetworkImage(incidente.evidenciaFotograficaUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                )
            ],
          )),
      actions: [
        ShadButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );

    showShadDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  Widget _buildCardHeader(
      EnvioLogisticoModel envio, Size size, ShadTextTheme textStyles) {
    // Método auxiliar para obtener el color y el ícono según el estado

    final statusStyle = getStatusStyle(envio);
    Size size = MediaQuery.of(context).size;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: size.height * 0.015,
          left: -size.width * 0.04,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
        Row(
          children: [
            const Spacer(),
            Container(
              // backgroundColor: Colors.transparent,
              width: size.height * 0.075,
              height: size.height * 0.075,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(statusStyle['asset']),
                  fit: BoxFit
                      .cover, // Puedes cambiar esto según cómo quieres que se ajuste la imagen
                ),
              ),
              // backgroundImage: AssetImage(statusStyle['asset']),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRowCustom(
      String label, EnvioLogisticoModel envio, ShadTextTheme textStyles) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          Text(
            label,
            style: textStyles.p.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontSize: size.height * 0.021,
            ),
          ),
          const Spacer(),
          TimeSinceWidget(
            horaInicioEnvio: envio.horaInicioEnvio!,
            horaFinalizacion: envio.horaFinalizacion,
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required ShadTextTheme textStyles,
    bool keepBlack = false,
    bool activateEllipsis = false,
  }) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          Text(
            label,
            style: textStyles.p.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontSize: size.height * 0.021,
            ),
          ),
          const Spacer(),
          Container(
            alignment: Alignment.centerRight,
            width: activateEllipsis ? size.width * 0.35 : null,
            child: Text(
              value,
              style: textStyles.small.copyWith(
                color: keepBlack ? Colors.black : Colors.white,
                fontSize: size.height * 0.018,
              ),
              overflow: activateEllipsis ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndHourRow(EnvioLogisticoModel envio, ShadTextTheme textStyles) {
    Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        Text(
          'Hora de termino: ',
          style: textStyles.p.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            fontSize: size.height * 0.021,
          ),
        ),
        const Spacer(),
        if (envio.horaFinalizacion == null)
          AnimateIcon(
            height: 20,
            width: 20,
            animateIcon: AnimateIcons.loading3,
            onTap: () {},
            color: Colors.blue[500]!,
            iconType: IconType.continueAnimation,
          )
        // Text(
        //   '',
        //   style: textStyles.small.copyWith(color: Colors.grey[600]),
        // )
        else
          Text(
            envio.getHoraFinalizacionFormatted(),
            style: textStyles.p.copyWith(
              color: Colors.grey[600],
              fontSize: size.height * 0.018,
            ),
          ),
      ],
    );
  }

  Widget _buildProductsList(
      EnvioLogisticoModel envio, Size size, ShadTextTheme textStyles) {
    return SizedBox(
      // color: Colors.red,
      height:
          size.height * 0.05, // Ajustamos la altura para el ListView horizontal
      child: envio.productos.isEmpty
          ? Text(
              'Se estan cargando productos...',
              style: textStyles.small.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: envio.productos.length,
              itemBuilder: (context, index) {
                final producto = envio.productos[index];
                return Padding(
                  padding: const EdgeInsets.only(
                      right: 10), // Espaciado entre productos
                  child: ShadAvatar(
                    producto.urlImagen,
                    fit: BoxFit.contain,
                    backgroundColor: Colors.transparent,
                    size: Size(
                      size.height * 0.045,
                      size.height * 0.045,
                    ), // Tamaño del avatar
                  ),
                );
              },
            ),
    );
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Empezamos desde la parte superior izquierda
    // path.lineTo(size.width * 0.33, 0); // Primer punto (izquierda)
    path.lineTo(size.width * 0.28, 0); // Primer punto (izquierda)

    // // Curva hacia abajo
    // path.quadraticBezierTo(
    //   0, size.height * 0.52, // Primer punto de control
    //   size.width * 0.55, size.height * 0.46, // Primer punto de destino
    // );
    // Curva hacia abajo
    path.quadraticBezierTo(
      0, size.height * 0.55, // Primer punto de control
      size.width * 0.55, size.height * 0.49, // Primer punto de destino
    );

    // Segunda curva hacia arriba
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.45, // Segundo punto de control
      size.width, size.height * 0.6, // Segundo punto de destino
    );

    path.lineTo(size.width, 0); // Lado superior derecho
    path.close(); // Cerramos la figura

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
