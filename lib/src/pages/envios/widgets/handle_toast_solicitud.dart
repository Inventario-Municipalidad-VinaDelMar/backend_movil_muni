import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/solicitud_envio.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void handleToastSolicitud(SolicitudEnvioModel solicitud, BuildContext context) {
  //*Este provider es un singleton, cada instancia se refiere a la misma
  UserProvider userProvider = UserProvider();

  late String message;
  late IconData icono;
  late Color color;
  switch (solicitud.status) {
    case SolicitudStatus.aceptada:
      color = Colors.green[500]!;
      icono = Icons.check_circle;
      message =
          '${userProvider.user!.id == solicitud.solicitante.id ? 'TÚ' : 'La'} solicitud fue aceptada';
      break;
    case SolicitudStatus.rechaza:
      color = Colors.red[500]!;
      icono = MdiIcons.closeCircle;
      message =
          '${userProvider.user!.id == solicitud.solicitante.id ? 'TÚ' : 'La'} solicitud fue rechazada';
      break;
    case SolicitudStatus.expirada:
      icono = Icons.info_rounded;
      color = Colors.orange[500]!;
      message =
          '${userProvider.user!.id == solicitud.solicitante.id ? 'TÚ' : 'La'} solicitud ha expirado';
      break;
    default:
  }
  Size size = MediaQuery.of(context).size;
  final textStyles = ShadTheme.of(context).textTheme;
  final colors = ShadTheme.of(context).colorScheme;
  showShadDialog(
    context: context,
    builder: (context) => ShadDialog.alert(
      expandActionsWhenTiny: false,
      removeBorderRadiusWhenTiny: false,
      radius: BorderRadius.circular(20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            color: color,
          ),
          SizedBox(width: 10),
          Text(message),
        ],
      ),
      description: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Solicitud atendida por:'),
            SizedBox(
              height: size.height * 0.025,
            ),
            ShadAvatar(
              solicitud.administrador!.imageUrl ??
                  'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              solicitud.administrador!.getFullName(),
              style: textStyles.p
                  .copyWith(fontWeight: FontWeight.bold, color: colors.muted),
            ),
          ],
        ),
      ),
      actions: [
        ShadButton(
          backgroundColor: Colors.blue[500],
          width: double.infinity,
          child: const Text('Aceptar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
