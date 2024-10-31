import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/comedor_solidario_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/socket/socket_entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/widgets/generic_select_input.dart';
import 'package:frontend_movil_muni/src/widgets/generic_text_input.dart';
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
  late EntregaProvider _entregaProvider;
  @override
  void initState() {
    _entregaProvider = context.read<EntregaProvider>();
    _entregaProvider.connect(
      [
        EntregaEvent.comedoresSolidarios,
      ],
    );
    super.initState();
  }

  @override
  void dispose() {
    _entregaProvider.disconnect(
      [
        EntregaEvent.comedoresSolidarios,
      ],
    );
    super.dispose();
  }

  void executeAddProduct(
      Size size, EnvioLogisticoModel envio, ShadTextTheme textStyles) {
    int indexSelected = 0;
    final formKey = GlobalKey<ShadFormState>();
    final productoEntregados =
        _entregaProvider.getProductosPorEnvio(widget.idEnvio);
    final productos = List.from(envio.productos);
    // Filtramos los productos eliminando aquellos cuyos IDs están en productoEntregados
    productos.removeWhere((producto) => productoEntregados
        .any((entregado) => entregado.productoId == producto.productoId));
    ProductoEnvio cargaSelected = productos[0];

    showShadDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
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
                            onTap: () {
                              setState(() {
                                indexSelected = i;
                                cargaSelected = carga;
                              });
                            },
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
                        labelText: 'Cantidad entregada',
                        placeHolder:
                            'Total disponible ${cargaSelected.cantidad}',
                        id: 'cantidadEntregada',
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
                enabled: cargaSelected.cantidad > 1,
                child: const Text('Añadir'),
                onPressed: () {
                  if (!formKey.currentState!.saveAndValidate()) {
                    return;
                  }
                  _entregaProvider.addOneProduct(
                    widget.idEnvio,
                    ProductoEnvio(
                      producto: cargaSelected.producto,
                      productoId: cargaSelected.productoId,
                      urlImagen: cargaSelected.urlImagen,
                      cantidad: int.parse(formKey
                          .currentState?.fields['cantidadEntregada']?.value),
                    ),
                  );
                  context.pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final envio = context.watch<EnvioProvider>().findEnvioById(widget.idEnvio);
    final productosEntregados =
        context.watch<EntregaProvider>().getProductosPorEnvio(widget.idEnvio);
    if (envio == null) {
      context.pop();
    }
    final entregasProvider = context.watch<EntregaProvider>();
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!entregasProvider.loadingEntregas)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: GenericSelectInput<ComedorSolidarioModel>(
                  padding: 40,
                  items: entregasProvider.comedores,
                  displayField: (comedor) => comedor.nombre,
                  labelText: 'Comedor solidario',
                  fieldId: 'comedor',
                  placeholderText: 'Seleccionar comedor...',
                ),
              ),
            SizedBox(
              height: size.height * 0.01,
            ),
            _InfoEnvioPreview(
              envio: envio!,
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            ZoomIn(
              duration: Duration(milliseconds: 200),
              delay: Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Text(
                      'Registrar productos entregados',
                      style: textStyles.p.copyWith(
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                    Spacer(),
                    if (productosEntregados.isNotEmpty &&
                        productosEntregados.length < envio.productos.length)
                      ShadButton(
                        height: size.height * 0.035,
                        width: size.height * 0.035,
                        padding: EdgeInsets.all(0),
                        size: ShadButtonSize.sm,
                        onPressed: () =>
                            executeAddProduct(size, envio, textStyles),
                        icon: Icon(
                          Icons.add,
                          size: 24,
                        ),
                      )
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              width: double.infinity,
              height: productosEntregados.isEmpty ? null : size.height * 0.31,
              child: productosEntregados.isEmpty
                  ? FadeInRight(
                      duration: Duration(milliseconds: 200),
                      delay: Duration(milliseconds: 200),
                      child: DottedBorder(
                        color: Colors.blue.withOpacity(.7),
                        dashPattern: const [4.5, 4.5, 4.5, 4.5],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        padding: EdgeInsets.all(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: Container(
                            height: size.height * 0.08,
                            width: double.infinity,
                            color: Colors.blue[500]!.withOpacity(.2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShadButton(
                                  //TODO: Crear entrega
                                  onPressed: () => executeAddProduct(
                                      size, envio, textStyles),
                                  backgroundColor: Colors.blueAccent,
                                  size: ShadButtonSize.sm,
                                  icon: Icon(
                                    Icons.add,
                                    size: 20,
                                  ),
                                  child: Text(
                                    'Registrar',
                                    style: textStyles.small.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: productosEntregados.length,
                      itemBuilder: (context, i) {
                        final cargaEntregada = productosEntregados[i];
                        return Dismissible(
                          key: ValueKey(cargaEntregada.productoId),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              entregasProvider.removeOneProduct(
                                  widget.idEnvio, cargaEntregada);
                              // eliminarProducto(carga);
                            });
                          },
                          child: FadeInRight(
                            duration: Duration(milliseconds: 200),
                            delay: Duration(milliseconds: 100),
                            child: Container(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              margin: EdgeInsets.only(bottom: 5),
                              height: size.height * 0.08,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.blue[500]!.withOpacity(.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  AnimateIcon(
                                    color: Colors.green,
                                    onTap: () {},
                                    iconType: IconType.continueAnimation,
                                    animateIcon: AnimateIcons.checkbox,
                                  ),
                                  ShadAvatar(
                                    cargaEntregada.urlImagen,
                                    fit: BoxFit.contain,
                                    backgroundColor: Colors.transparent,
                                    size: Size(
                                      size.height * 0.05,
                                      size.height * 0.05,
                                    ), // Tamaño del avatar
                                  ),
                                  SizedBox(
                                    width: size.width * 0.03,
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    width: size.width * 0.4,
                                    child: Wrap(
                                      children: [
                                        Text(
                                          cargaEntregada.producto,
                                          softWrap: true,
                                          style: textStyles.p
                                              .copyWith(height: 1.2),
                                        )
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  ShadBadge(
                                    backgroundColor: Colors.blue[500],
                                    child: Text(
                                      '${cargaEntregada.cantidad}',
                                      style: textStyles.small.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Visibility(
              //TODO: Habilitar cuando haya por lo menos 1 producto registrado
              visible: productosEntregados.isNotEmpty,
              child: FadeInUp(
                duration: Duration(milliseconds: 200),
                child: ShadButton(
                  width: size.width,
                  size: ShadButtonSize.lg,
                  child: Text(
                    'Ingresar entrega',
                    style: textStyles.h4.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.only(
        left: 25,
        right: 25,
        top: 15,
      ),
      child: SizedBox(
        width: size.width,
        height: size.height * 0.3,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    // bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[500]!.withOpacity(.7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  width: double.infinity,
                  height: size.height * 0.07,
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: size.height * 0.04,
                        backgroundImage:
                            const AssetImage('assets/logos/camiones3.gif'),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Cargamento actual',
                            style: textStyles.p.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: size.height * 0.0095)
                        ],
                      ),
                      Spacer(),
                      Icon(
                        MdiIcons.mapMarkerDistance,
                        color: Colors.white,
                        size: 35,
                      ),
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  // right: size.width * 0.04,
                  top: -(size.height * 0.01),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      envio.statusToString(),
                      style: textStyles.small.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(10),
                  itemCount: envio.productos.length,
                  itemBuilder: (context, i) {
                    final carga = envio.productos[i];
                    return Column(
                      children: [
                        Container(
                          // color: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          // margin: EdgeInsets.only(bottom: 5),
                          width: double.infinity,
                          height: size.height * 0.05,
                          child: Row(
                            children: [
                              ShadAvatar(
                                carga.urlImagen,
                                fit: BoxFit.contain,
                                backgroundColor: Colors.transparent,
                                size: Size(
                                  size.height * 0.045,
                                  size.height * 0.045,
                                ), // Tamaño del avatar
                              ),
                              SizedBox(width: size.width * 0.03),
                              SizedBox(
                                // height: double.infinity,
                                width: size.width * 0.5,
                                child: Wrap(
                                  children: [
                                    Text(
                                      carga.producto,
                                      style: textStyles.p.copyWith(height: 1.2),
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              ShadBadge(
                                child: Text('${carga.cantidad}'),
                              )
                            ],
                          ),
                        ),
                        if (i < envio.productos.length - 1) Divider(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
