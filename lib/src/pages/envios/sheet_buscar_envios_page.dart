import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_movil_muni/src/providers/movimientos/movimiento_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/planificacion_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SheetBuscarEnviosPage extends StatefulWidget {
  final String producto;
  final String productoId;
  final String productoImgUrl;
  final String tandaId;
  final int cantidadDisponible;
  const SheetBuscarEnviosPage({
    super.key,
    required this.side,
    required this.producto,
    required this.productoId,
    required this.tandaId,
    required this.cantidadDisponible,
    required this.productoImgUrl,
  });

  final ShadSheetSide side;

  @override
  State<SheetBuscarEnviosPage> createState() => _SheetBuscarEnviosPageState();
}

class _SheetBuscarEnviosPageState extends State<SheetBuscarEnviosPage> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    final planificacionProvider = context.watch<PlanificacionProvider>();
    final movimientoProvider = context.watch<MovimientoProvider>();
    final detalle =
        planificacionProvider.getOneDetallePlanificacion(widget.productoId);

    return ShadSheet(
      constraints: widget.side == ShadSheetSide.left ||
              widget.side == ShadSheetSide.right
          ? const BoxConstraints(maxWidth: 512)
          : null,
      title: Row(
        children: [
          ShadAvatar(
            widget.productoImgUrl,
            placeholder: const SkeletonAvatar(
              style: SkeletonAvatarStyle(
                  shape: BoxShape.circle, width: 50, height: 50),
            ),
            backgroundColor: Colors.transparent,
          ),
          Text('Tanda de "${widget.producto}"', style: textStyles.h4),
        ],
      ),
      actions: [
        ShadButton(
          enabled:
              (_controller.value.text != '' && _controller.value.text != '0') &&
                  !movimientoProvider.creatingMovimiento,
          size: ShadButtonSize.sm,
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            await movimientoProvider.addNewMovimiento({
              'cantidadRetirada': int.parse(_controller.value.text),
              'idTanda': widget.tandaId,
              'idEnvioProducto': detalle!.id,
            }).then((value) {
              if (context.mounted) {
                context.pop();
                context.pop();
                // context.pushReplacement('/envio');
              }
            });
          },
          icon: !movimientoProvider.creatingMovimiento
              ? FaIcon(
                  FontAwesomeIcons.check,
                  size: size.height * 0.025,
                )
              : const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
          child: Text(
            'Confirmar',
            style: textStyles.h4.copyWith(color: Colors.white),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Form(
          key: _formKey,
          child: ShadInputFormField(
            validator: (value) {
              if (value.isEmpty) {
                return 'Ingrese una cantidad';
              }

              int? cantidad;
              try {
                cantidad = int.parse(value);
              } catch (e) {
                return 'Ingrese un número válido';
              }

              if (cantidad > detalle.cantidadPlanificada) {
                return 'La cantidad no puede ser mayor a ${detalle.cantidadPlanificada}';
              }

              return null; // Si pasa la validación, no se retorna ningún error
            },
            enabled: !movimientoProvider.creatingMovimiento,
            controller: _controller,
            onChanged: (p0) => setState(() {}),
            label: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Row(
                children: [
                  Text('Cantidad a retirar', style: textStyles.p),
                  Spacer(),
                  ShadBadge(
                      child: Text('Disponible: ${widget.cantidadDisponible}'))
                ],
              ),
            ),
            placeholder: const Text('0'),
            keyboardType: TextInputType.number,
            description: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                  'Retiro maximo por envío ${detalle!.cantidadPlanificada}'),
            ),
          ),
        ),
      ),
    );
  }
}
