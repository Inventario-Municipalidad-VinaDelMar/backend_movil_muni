import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/planificacion_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SheetBuscarEnviosPage extends StatefulWidget {
  final String producto;
  final String productoId;
  final String tandaId;
  const SheetBuscarEnviosPage({
    super.key,
    required this.side,
    required this.producto,
    required this.productoId,
    required this.tandaId,
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
    final theme = ShadTheme.of(context);
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    final planificacionProvider = context.watch<PlanificacionProvider>();
    final detalle =
        planificacionProvider.getOneDetallePlanificacion(widget.productoId);

    return ShadSheet(
      constraints: widget.side == ShadSheetSide.left ||
              widget.side == ShadSheetSide.right
          ? const BoxConstraints(maxWidth: 512)
          : null,
      title: Text('Tanda de "${widget.producto}"', style: textStyles.h3),
      actions: [
        ShadButton(
          enabled: _controller.value.text != '' &&
              !planificacionProvider.creatingMovimiento,
          size: ShadButtonSize.sm,
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            await planificacionProvider.addNewMovimiento({
              'cantidadRetirada': int.parse(_controller.value.text),
              'idTanda': widget.tandaId,
              'idEnvioProducto': detalle!.id,
            }).then((value) {
              if (context.mounted) {
                context.pop();
                context.pushReplacement('/envio');
              }
            });
          },
          icon: !planificacionProvider.creatingMovimiento
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
            enabled: !planificacionProvider.creatingMovimiento,
            controller: _controller,
            onChanged: (p0) => setState(() {}),
            label: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text('Cantidad', style: textStyles.h4),
            ),
            placeholder: const Text('Ingrese la cantidad a retirar'),
            keyboardType: TextInputType.number,
            description: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('Cantidad maxima ${detalle!.cantidadPlanificada}'),
            ),
          ),
        ),
      ),
    );
  }
}
