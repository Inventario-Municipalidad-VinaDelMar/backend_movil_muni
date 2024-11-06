import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/pages/entregas/entregas_adjuntar_documento.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/common/manage_product_list.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/envio_provider.dart';
import 'package:frontend_movil_muni/src/widgets/generic_select_input.dart';
import 'package:frontend_movil_muni/src/widgets/generic_text_input.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EntregasFormularioIncidente extends StatefulWidget {
  final String idEnvio;
  const EntregasFormularioIncidente({
    super.key,
    required this.idEnvio,
  });

  @override
  State<EntregasFormularioIncidente> createState() =>
      _EntregasFormularioIncidenteState();
}

class _EntregasFormularioIncidenteState
    extends State<EntregasFormularioIncidente> {
  final _scrollSingleChild = ScrollController();
  final formKey = GlobalKey<ShadFormState>();
  final _controllerDesc = TextEditingController();
  final picker = ImagePicker();
  bool isErrorFoto = false;
  FileInfo? fileLoaded;
  bool loadingPickFile = false;

  Future<void> scrollToTop() async {
    int delay = 100;

    await Future.delayed(Duration(milliseconds: delay));
    _scrollSingleChild.animateTo(
      _scrollSingleChild.position.minScrollExtent, // Posición máxima de scroll
      duration: Duration(milliseconds: 200), // Duración de la animación
      curve: Curves.easeOut, // Curva de la animación
    );
  }

  @override
  Widget build(BuildContext context) {
    final envioProvider = context.watch<EnvioProvider>();
    final envio = envioProvider.findEnvioById(widget.idEnvio);
    final productosAfectados = context
        .watch<EnvioProvider>()
        .getProductosPorEnvioIncidente(widget.idEnvio);
    if (envio == null) {
      context.pop();
    }
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor:
          Colors.grey[200], // Cambiamos el fondo a un color más suave
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: Text(
          'Incidente durante envío',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollSingleChild,
        child: ShadForm(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenericSelectInput<String>(
                  items: const [
                    'Choque',
                    'Extravio',
                    'Daño',
                    'Contaminacion',
                    'Robo'
                  ],
                  onChanged: (_) {
                    setState(() {
                      isErrorFoto = false;
                    });
                  },
                  displayField: (value) => value,
                  labelText: 'Tipo de incidente',
                  fieldId: 'type',
                  padding: size.width * 0.1,
                  errorText: 'Por favor, seleccione el tipo de incidente',
                  placeholderText: 'Seleccionar tipo de incidente',
                ),
                SizedBox(height: size.height * 0.01),
                ShadSwitchFormField(
                  id: 'finishEnvio',
                  checkedTrackColor: Colors.blue,
                  initialValue: false,
                  inputLabel: const Text('Finalizar envío'),
                  label: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text('Estado del envío', style: textStyles.p),
                  ),
                  onChanged: (v) {},
                  inputSublabel: const Text('¿El envío ya no podrá continuar?'),
                ),
                SizedBox(height: size.height * 0.02),
                GenericTextInput(
                  controller: _controllerDesc,
                  labelText: 'Descripcion',
                  placeHolder: 'Indique lo sucedido...',
                  maxLines: 5,
                  maxLength: 255,
                  id: 'descripcion',
                  validator: (v) {
                    if (v.isEmpty) {
                      return 'Indique lo que sucedio en el incidente';
                    }
                    return null;
                  },
                ),
                if (fileLoaded != null)
                  ..._buildImagedLoaded(context, fileLoaded!, () {
                    setState(() {
                      fileLoaded = null;
                    });
                  }),
                if (fileLoaded == null)
                  ..._buildBoxImage(context, isErrorFoto, loadingPickFile,
                      () async {
                    FileInfo? filePick;
                    setState(() {
                      loadingPickFile = true;
                    });
                    //1. Abri camara y obtener foto
                    // await Future.delayed(Duration(seconds: 1));
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
                    //2. Formatear la foto y setiarla
                    if (pickedFile != null) {
                      filePick = FileInfo(
                        peso: 5.1,
                        nombreOriginal: 'foto_tomada.png',
                        imageFile: pickedFile,
                      );
                    }
                    //
                    setState(() {
                      loadingPickFile = false;
                      isErrorFoto = false;
                      if (filePick != null) {
                        fileLoaded = filePick;
                      }
                    });
                  }),
                SizedBox(height: size.height * 0.02),
                ManageProductList(
                  items: productosAfectados,
                  idEnvio: envio!.id,
                  isDelivery: false,
                  scrollSingleChild: _scrollSingleChild,
                  labelText: 'Productos afectados',
                ),
                SizedBox(height: size.height * 0.01),
                _SubmitIncidenteButton(
                  productosAfectados: productosAfectados,
                  scrollToTop: scrollToTop,
                  onSubmit: () async {
                    if (!formKey.currentState!.saveAndValidate()) {
                      scrollToTop();
                      return;
                    }

                    // final close =
                    //     formKey.currentState?.fields['finishEnvio']?.value;
                    // print(bool.parse(close));
                    // print(close);
                    // print(close.runtimeType);
                    final type = formKey.currentState?.fields['type']?.value;
                    if ((type == 'Choque' ||
                            type == 'Contaminacion' ||
                            type == 'Daño') &&
                        fileLoaded?.imageFile == null) {
                      setState(() {
                        isErrorFoto = true;
                      });
                      return;
                    }
                    final Map<String, dynamic> dataIncidente = {
                      if (fileLoaded != null)
                        'fileName': fileLoaded!.imageFile!.name,
                      if (fileLoaded != null)
                        'path': fileLoaded!.imageFile!.path,
                      'idEnvio': widget.idEnvio,
                      'type': type,
                      'finishEnvio': formKey
                          .currentState?.fields['finishEnvio']?.value as bool,
                      'descripcion':
                          formKey.currentState?.fields['descripcion']?.value,
                      'productosAfectados':
                          List.from(productosAfectados.map((p) {
                        return {
                          'productoId': p.productoId,
                          'cantidadAfectada': p.cantidad as int,
                        };
                      }).toList()),
                    };

                    try {
                      await envioProvider.generateNewIncidente(
                          dataIncidente, widget.idEnvio);
                      if (context.mounted) {
                        throwToastSuccess(context, 'Registro exitoso',
                            'Se ha ingresado correctamente el incidente');
                        context.pop();
                      }
                    } catch (error) {
                      if (context.mounted) {
                        throwToastError(
                            context, 'No se ha podido registrar el incidente.');
                        // No llamas a `context.pop()` aquí
                      }
                    }
                  },
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> _buildImagedLoaded(
  BuildContext context,
  FileInfo file,
  void Function() onDelete,
) {
  Size size = MediaQuery.of(context).size;
  final textStyles = ShadTheme.of(context).textTheme;
  return [
    SizedBox(height: size.height * 0.01),
    Text(
      'Evidencia fotografica',
      style: textStyles.p,
    ),
    SizedBox(height: size.height * 0.02),
    file.imageFile != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInLeft(
                duration: Duration(milliseconds: 200),
                child: Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: FileImage(
                        File(
                          file.imageFile!.path,
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: size.width * 0.06,
              ),
              Expanded(
                child: FadeInRight(
                  duration: Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Imagen obtenida',
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.p.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        children: [
                          Text(
                            // file.imageFile!.name,
                            'Esta será la imagen de evidencia para el incidente.',
                            softWrap: true,
                            style: textStyles.small.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.03),
                      ShadButton(
                        onPressed: () => onDelete(),
                        size: ShadButtonSize.sm,
                        child: Text('Cancelar imagen'),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        : Text('No image selected.'),
  ];
}

List<Widget> _buildBoxImage(
  BuildContext context,
  bool error,
  bool pickingFile,
  void Function() onTakeImage,
) {
  Size size = MediaQuery.of(context).size;
  final textStyles = ShadTheme.of(context).textTheme;
  return [
    SizedBox(height: size.height * 0.01),
    Text(
      'Evidencia fotografica',
      style: textStyles.p,
    ),
    _BoxTakeImage(
      error: error,
      takingImage: pickingFile,
      onPickImage: () => onTakeImage(),
    ),
    SizedBox(height: size.height * 0.01),
    Text(
      error
          ? 'Se requiere evidencia para el incidente seleccionado.'
          : 'Solo es necesaria para "Choque", "Contaminacion" o "Daño."',
      style: textStyles.small.copyWith(
        color: error ? Colors.red : Colors.black45,
      ),
    ),
  ];
}

class _SubmitIncidenteButton extends StatelessWidget {
  const _SubmitIncidenteButton({
    required this.productosAfectados,
    required this.scrollToTop,
    required this.onSubmit,
  });

  final List<ProductoEnvio> productosAfectados;
  final void Function() scrollToTop;
  final void Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final envioProvider = context.watch<EnvioProvider>();
    return Visibility(
      visible: productosAfectados.isNotEmpty &&
          MediaQuery.of(context).viewInsets.bottom == 0,
      child: FadeInUp(
        duration: Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: ShadButton(
            padding: EdgeInsets.symmetric(horizontal: 0),
            enabled: !envioProvider.creatingIncidente,
            onPressed: () => onSubmit(),
            width: double.infinity,
            size: ShadButtonSize.lg,
            icon: envioProvider.creatingIncidente
                ? SizedBox(
                    width: size.height * 0.03,
                    height: size.height * 0.03,
                    child: AnimateIcon(
                      animateIcon: AnimateIcons.loading6,
                      color: Colors.white,
                      iconType: IconType.continueAnimation,
                      onTap: () {},
                    ),
                  )
                : null,
            child: envioProvider.creatingIncidente
                ? Text('Creando incidente',
                    style: textStyles.h4.copyWith(
                      color: Colors.white,
                    ))
                : Text(
                    'Ingresar incidente',
                    style: textStyles.h4.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BoxTakeImage extends StatelessWidget {
  const _BoxTakeImage({
    required this.error,
    required this.takingImage,
    required this.onPickImage,
  });
  final bool error;
  final bool takingImage;
  final void Function() onPickImage;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return DottedBorder(
      color: error
          ? Colors.red[500]!
          : Colors.blue[700]!.withOpacity(takingImage ? .4 : 1),
      dashPattern: const [6, 6, 6, 6],
      strokeWidth: error ? 2 : 1,
      borderType: BorderType.RRect,
      radius: Radius.circular(12),
      padding: EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          height: size.height * 0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: takingImage ? .4 : 1,
                child: SizedBox(
                  width: size.height * 0.08,
                  height: size.height * 0.08,
                  child: Image.asset('assets/logos/camera.png'),
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              ShadButton.outline(
                backgroundColor: Colors.transparent,
                width: size.width * 0.56,
                enabled: !takingImage,
                onPressed: () => onPickImage(),
                foregroundColor: Colors.blue[700],
                decoration: ShadDecoration(
                  border: ShadBorder.all(
                    color: Colors.blue[700]!,
                  ),
                ),
                size: ShadButtonSize.sm,
                icon: SizedBox(
                  width: 20,
                  height: 20,
                  child: AnimateIcon(
                    onTap: () {},
                    color: Colors.blue[500]!,
                    iconType: IconType.continueAnimation,
                    animateIcon: AnimateIcons.liveVideo,
                  ),
                ),
                child: Text(
                  takingImage ? 'Buscando...' : 'Tomar foto',
                  style: textStyles.small.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
              ),
              // if (entrega.urlActaLegal != null)
              //   SizedBox(
              //     height: size.height * 0.01,
              //   ),
              // if (entrega.urlActaLegal != null)
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Icon(
              //         MdiIcons.informationOutline,
              //         color: Colors.red[300],
              //         size: size.height * 0.02,
              //       ),
              //       SizedBox(
              //         width: size.width * 0.012,
              //       ),
              //       Text(
              //         'Hay una acta adjuntada',
              //         style: textStyles.small.copyWith(
              //           color: Colors.red[300],
              //         ),
              //       ),
              //     ],
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
