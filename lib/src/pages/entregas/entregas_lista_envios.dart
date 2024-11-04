import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/empty_full_screen.dart';
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
  late EnvioProvider _envioProvider;

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

    // Configuramos el texto y el icono en función del valor de widget.finalidad
    switch (widget.finalidad) {
      case EntregasFinalidad.incidente:
        text = 'Para registrar un INCIDENTE';
        icon = MdiIcons.truckAlertOutline;
        break;
      case EntregasFinalidad.registro:
        text = 'Para registrar una NUEVA ENTREGA';
        icon = MdiIcons.packageCheck;
        break;
      case EntregasFinalidad.actualizacion:
        text = 'Para adjuntar ACTA LEGAL de entrega';
        icon = MdiIcons.folderArrowUp;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[600],
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
    return Container(
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
                  height: size.height * 0.65,
                  color:
                      Colors.blue[700], // Azul para mantener el estilo actual
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(envio, size, textStyles),
                  // SizedBox(height: size.height * 0.01),
                  _buildInfoRow(
                      'Autorizado por: ', envio.autorizante, textStyles),
                  _buildInfoRow('Fecha creación: ',
                      fechaToLargeName(envio.fecha), textStyles),

                  _buildInfoRow('Hora creacion: ',
                      envio.getHoraCreacionFormatted(), textStyles),
                  envio.horaInicioEnvio == null
                      ? _buildInfoRow('Tiempo en envío: ', '-', textStyles)
                      : _buildInfoRowCustom('Tiempo en envío: ',
                          envio.horaInicioEnvio!, textStyles),
                  _buildInfoRow(
                    'Ultima entrega en: ',
                    envio.entregas.isEmpty
                        ? '-'
                        : envio.entregas.first.comedorSolidario,
                    textStyles,
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildEndHourRow(envio, textStyles),
                  _buildInfoRow(
                    'Entregas realizadas: ',
                    '${envio.entregas.length}',
                    textStyles,
                  ),
                  const Divider(),
                  _buildProductsList(envio, size, textStyles),
                  // const Divider(),
                  SizedBox(height: 5),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(
      EnvioLogisticoModel envio, Size size, ShadTextTheme textStyles) {
    // Método auxiliar para obtener el color y el ícono según el estado
    Map<String, dynamic> _getStatusStyle(EnvioStatus status) {
      switch (status) {
        case EnvioStatus.sinCargar:
          return {
            'color': Colors.grey[300],
            'icon': Icons.hourglass_empty,
            'textColor': Colors.grey[700],
            'label': envio.statusToString(),
          };
        case EnvioStatus.cargando:
          return {
            'color': Colors.yellow[100],
            'icon': Icons.local_shipping,
            'textColor': Colors.yellow[800],
            'label': envio.statusToString(),
          };
        case EnvioStatus.enEnvio:
          return {
            'color': Colors.blue[100],
            'icon': Icons.directions_car,
            'textColor': Colors.blue[800],
            'label': envio.statusToString(),
          };
        case EnvioStatus.finalizado:
          return {
            'color': Colors.green[100],
            'icon': Icons.check_circle,
            'textColor': Colors.green[800],
            'label': envio.statusToString(),
          };
      }
    }

    final statusStyle = _getStatusStyle(envio.status);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusStyle['color'],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                statusStyle['icon'],
                color: statusStyle['textColor'],
                size: 18,
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
        const Spacer(),
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: size.height * 0.04,
          backgroundImage: const AssetImage('assets/logos/camiones3.gif'),
        ),
      ],
    );
  }

  Widget _buildInfoRowCustom(
      String label, String value, ShadTextTheme textStyles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          Text(
            label,
            style: textStyles.p
                .copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          const Spacer(),
          TimeSinceWidget(hora: value)
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ShadTextTheme textStyles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          Text(
            label,
            style: textStyles.p
                .copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          const Spacer(),
          Text(
            value,
            style: textStyles.small.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEndHourRow(EnvioLogisticoModel envio, ShadTextTheme textStyles) {
    return Row(
      children: [
        Text(
          'Hora de termino: ',
          style: textStyles.p
              .copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800]),
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
            envio.getHoraCreacionFormatted(),
            style: textStyles.p.copyWith(color: Colors.grey[600]),
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
    path.lineTo(size.width * 0.3, 0); // Primer punto (izquierda)

    // Curva hacia abajo
    path.quadraticBezierTo(
      0, size.height * 0.56, // Primer punto de control
      size.width * 0.52, size.height * 0.5, // Primer punto de destino
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
