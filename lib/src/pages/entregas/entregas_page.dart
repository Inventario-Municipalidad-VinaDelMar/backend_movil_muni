import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/providers/logistica/socket/socket_logistica_provider.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:animate_do/animate_do.dart';

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
    _logisticaProvider.connect([LogisticaEvent.enviosByFecha]);
    super.initState();
  }

  @override
  void dispose() {
    _logisticaProvider.disconnect([LogisticaEvent.enviosByFecha]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final logisticaProvider = context.watch<LogisticaProvider>();

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
      body: logisticaProvider.loadingEnvios
          ? const Center(child: CircularProgressIndicator())
          : logisticaProvider.enviosLogisticos.isEmpty
              ? _buildEmptyState(context, size, textStyles)
              : _buildEnviosList(logisticaProvider, size, textStyles),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, Size size, ShadTextTheme textStyles) {
    return ZoomIn(
      duration: const Duration(milliseconds: 200),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.25,
              child: Image.asset(
                'assets/logos/empty.png', // Cambié la imagen a una versión más estilizada
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No se han realizado envíos el día de hoy',
              style: textStyles.p.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Volver al inicio',
                style: textStyles.p.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnviosList(LogisticaProvider logisticaProvider, Size size,
      ShadTextTheme textStyles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logisticaProvider.enviosLogisticos.length,
      itemBuilder: (context, i) {
        final envio = logisticaProvider.enviosLogisticos[i];
        return FadeInRight(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: i * 120),
          child: _buildEnvioCard(envio, size, textStyles),
        );
      },
    );
  }

  Widget _buildEnvioCard(dynamic envio, Size size, ShadTextTheme textStyles) {
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
            // Positioned(
            //   top: -(size.width * 0.08),
            //   right: -(size.width * 0.125),
            //   child: Container(
            //     width: size.height * 0.32,
            //     height: size.height * 0.32,
            //     decoration: BoxDecoration(
            //       color: Colors.blue[500],
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            Positioned(
              top: -(size.width * 0.08),
              right: -(size.width * 0.125),
              child: ClipPath(
                clipper: CurvedClipper(),
                child: Container(
                  width: size.width * 0.78,
                  height: size.height * 0.6,
                  color:
                      Colors.blue[700], // Azul para mantener el estilo actual
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(envio, size, textStyles),
                  SizedBox(height: size.height * 0.01),
                  _buildInfoRow(
                      'Autorizado por: ',
                      envio.solicitud.administrador?.getFullName() ?? 'N/A',
                      textStyles),
                  _buildInfoRow('Fecha creación: ',
                      fechaToLargeName(envio.fecha), textStyles),
                  _buildInfoRow(
                      'Hora de inicio: ', envio.getHoraFormatted(), textStyles),
                  const SizedBox(height: 10),
                  _buildEndHourRow(envio, textStyles),
                  const Divider(),
                  _buildProductsList(envio, size, textStyles),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(dynamic envio, Size size, ShadTextTheme textStyles) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        const Spacer(),
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: size.height * 0.04,
          backgroundImage: const AssetImage('assets/logos/camiones3.gif'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ShadTextTheme textStyles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildEndHourRow(dynamic envio, ShadTextTheme textStyles) {
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
            width: 20,
            animateIcon: AnimateIcons.loading3,
            onTap: () {},
            color: Colors.blue[500]!,
            iconType: IconType.continueAnimation,
          )
        else
          Text(
            envio.getHoraFormatted(),
            style: textStyles.p.copyWith(color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildProductsList(
      dynamic envio, Size size, ShadTextTheme textStyles) {
    return SizedBox(
      height:
          size.height * 0.08, // Ajustamos la altura para el ListView horizontal
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: envio.productos.length,
        itemBuilder: (context, index) {
          final producto = envio.productos[index];
          return Padding(
            padding:
                const EdgeInsets.only(right: 10), // Espaciado entre productos
            child: ShadAvatar(
              producto.urlImagen,
              fit: BoxFit.cover,
              backgroundColor: Colors.transparent,
              size: Size(
                  size.height * 0.07, size.height * 0.07), // Tamaño del avatar
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
      0, size.height * 0.58, // Primer punto de control
      size.width * 0.5, size.height * 0.5, // Primer punto de destino
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
