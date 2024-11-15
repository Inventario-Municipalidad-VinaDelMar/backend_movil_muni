import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/envio_provider.dart';
import 'package:frontend_movil_muni/src/widgets/generic_text_input.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DialogSetProducto extends StatelessWidget {
  final bool isDelivey;
  final GlobalKey<ShadFormState> formKey;
  final ProductoEnvio cargaSelected;
  final List<ProductoEnvio> productos;
  final int indexSelected;
  final String idEnvio;
  final void Function(int, ProductoEnvio) onTap;
  const DialogSetProducto({
    super.key,
    required this.cargaSelected,
    required this.indexSelected,
    required this.formKey,
    required this.idEnvio,
    required this.onTap,
    required this.productos,
    required this.isDelivey,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final entregaProvider = context.watch<EntregaProvider>();
    final envioProvider = context.watch<EnvioProvider>();
    return ShadDialog.alert(
      backgroundColor: Colors.grey[100],
      removeBorderRadiusWhenTiny: false,
      radius: BorderRadius.circular(15),
      constraints: BoxConstraints(
        maxWidth: size.width * 0.9,
      ),
      title: Text('Seleccione un producto'),
      description: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: ShadForm(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: size.height * 0.18,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: productos.length,
                  itemBuilder: (context, i) {
                    final carga = productos[i];
                    return GestureDetector(
                      onTap: () => onTap(i, carga),
                      child: Container(
                        padding: EdgeInsets.only(top: 5, left: 10),
                        margin: EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            Opacity(
                              opacity: indexSelected == i ? 1.0 : 0.3,
                              child: ShadAvatar(
                                carga.urlImagen,
                                fit: BoxFit.contain,
                                backgroundColor: Colors.transparent,
                                size: Size(
                                  size.height * 0.1,
                                  size.height * 0.1,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            SizedBox(
                              width: size.width * 0.2,
                              child: Wrap(
                                children: [
                                  Text(
                                    carga.producto,
                                    style: textStyles.small.copyWith(
                                      color: indexSelected == i
                                          ? Colors.black87
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (cargaSelected.cantidad > 0)
                GenericTextInput(
                  labelText:
                      isDelivey ? 'Cantidad entregada' : 'Cantidad afectada',
                  placeHolder: 'Total disponible ${cargaSelected.cantidad}',
                  id: 'cantidad',
                  inputType: TextInputType.number,
                  // error: (p0) {},
                  validator: (v) {
                    if (v.isEmpty) {
                      return 'Ingrese una Cantidad';
                    }
                    final cantidad = int.parse(v);
                    if (cantidad > cargaSelected.cantidad) {
                      return 'Esta cantidad es mayor que el stock';
                    }
                    return null;
                  },
                ),
              if (cargaSelected.cantidad < 1)
                Padding(
                  padding: const EdgeInsets.only(left: 9, top: 15),
                  child: Row(
                    children: [
                      Flexible(
                        child: Wrap(
                          children: [
                            Text(
                              'Ya no queda de este producto en el cargamento.',
                              style: textStyles.small
                                  .copyWith(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        ShadButton.outline(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ShadButton(
          enabled: cargaSelected.cantidad >= 1,
          child: const Text('Añadir'),
          onPressed: () {
            if (!formKey.currentState!.saveAndValidate()) {
              return;
            }
            final producto = ProductoEnvio(
              producto: cargaSelected.producto,
              productoId: cargaSelected.productoId,
              urlImagen: cargaSelected.urlImagen,
              cantidad:
                  int.parse(formKey.currentState?.fields['cantidad']?.value),
            );
            if (isDelivey) {
              entregaProvider.addOneProduct(idEnvio, producto);
            } else {
              envioProvider.addOneProduct(idEnvio, producto);
            }

            context.pop();
          },
        ),
      ],
    );
  }
}
