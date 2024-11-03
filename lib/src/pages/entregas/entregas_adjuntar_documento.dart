import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/envio_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

//?Mini modelo para representar al archivo temporal
class FileInfo {
  double peso;
  String nombreOriginal;
  File? file;

  FileInfo({
    required this.peso,
    required this.nombreOriginal,
    required this.file,
  });
}

class EntregasAdjuntarDocumento extends StatefulWidget {
  final String idEntrega;
  final String idEnvio;
  const EntregasAdjuntarDocumento({
    super.key,
    required this.idEntrega,
    required this.idEnvio,
  });

  @override
  State<EntregasAdjuntarDocumento> createState() =>
      _EntregasAdjuntarDocumentoState();
}

class _EntregasAdjuntarDocumentoState extends State<EntregasAdjuntarDocumento> {
  //?Variable para manejar el archivo
  FileInfo? fileLoaded;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final entregaProvider = context.watch<EntregaProvider>();
    final entrega = context
        .watch<EnvioProvider>()
        .findEntregaById(widget.idEnvio, widget.idEntrega);
    if (entrega == null) {
      context.pop();
    }
    return Scaffold(
      backgroundColor:
          Colors.grey[200], // Cambiamos el fondo a un color más suave
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: Text(
          'Actualizar entrega',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.01,
        ),
        width: size.width,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildHeaderInfo(context),
            SizedBox(height: size.height * 0.02),
            ..._buildBoxFileUpload(
              context,
              fileLoaded,
              entrega!,
              //TODO: Funcion para cargar el archivo
              () {
                //1. Abrir administrador de files

                //2. Validar los formatos permitidos, si falla mostrar popup

                //3. Crear la entidad FileInfo con el file elegido
                final file = FileInfo(
                  peso: 1.9,
                  nombreOriginal: 'archivo.png',
                  //TODO: Aqui debe ir el archivo como tal
                  file: null,
                );

                //4. Setear el archivo
                setState(() {
                  fileLoaded = file;
                });
              },
            ),
            SizedBox(height: size.height * 0.02),
            ..._buildFileLoaded(
              context,
              fileLoaded,
              //TODO: Funcion para remover el archivo
              () {
                setState(() {
                  fileLoaded = null;
                  //Haz lo que necesite el file managment
                });
              },
            ),
            Spacer(),
            if (fileLoaded != null)
              ..._buildSubmitButton(
                context,
                entrega,
                //TODO: Funcion para subir el archivo al server
                () async {
                  if (fileLoaded == null) {
                    return;
                  }
                  final Map<String, dynamic> entregaData = {
                    'idEntrega': widget.idEntrega,
                    'file': fileLoaded!.file
                  };

                  try {
                    await entregaProvider.uploadFile(entregaData);
                    if (context.mounted) {
                      //TODO: Mostrar popup de éxito
                      _throwToastSuccess(context);
                      context.pop();
                    }
                  } catch (error) {
                    if (context.mounted) {
                      //TODO: Mostrar popup de fallo
                      _throwToastError(context);
                      // No llamas a `context.pop()` aquí
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildSubmitButton(
    BuildContext context, EntregaEnvio entrega, void Function() onSubmit) {
  final textStyles = ShadTheme.of(context).textTheme;
  final entregaProvider = context.watch<EntregaProvider>();
  return [
    FadeInUp(
      duration: Duration(milliseconds: 400),
      child: ShadButton(
        enabled: !entregaProvider.uploadingFile,
        onPressed: () => onSubmit(),
        size: ShadButtonSize.lg,
        width: double.infinity,
        icon: Text(
          entrega.urlActaLegal != null
              ? entregaProvider.uploadingFile
                  ? 'Resubiendo archivo...'
                  : 'Resubir acta legal'
              : entregaProvider.uploadingFile
                  ? 'Subiendo archivo...'
                  : 'Subir acta legal',
          style: textStyles.p.copyWith(
            color: Colors.white,
          ),
        ),
        child: entregaProvider.uploadingFile
            ? SizedBox(
                width: 23,
                height: 23,
                child: AnimateIcon(
                  onTap: () {},
                  iconType: IconType.continueAnimation,
                  animateIcon: AnimateIcons.loading6,
                  color: Colors.white,
                ),
              )
            : Icon(
                MdiIcons.cloudArrowUp,
                color: Colors.white,
              ),
      ),
    )
  ];
}

List<Widget> _buildFileLoaded(
    BuildContext context, FileInfo? file, void Function() onRemove) {
  Size size = MediaQuery.of(context).size;
  final textStyles = ShadTheme.of(context).textTheme;
  if (file == null) {
    return [];
  }
  return [
    FadeInRight(
      duration: Duration(milliseconds: 200),
      // delay: Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        width: double.infinity,
        height: size.height * 0.08,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(.1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.fileDocumentCheck,
              color: Colors.blue,
              size: size.height * 0.04,
            ),
            SizedBox(width: size.width * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  file.nombreOriginal,
                  style: textStyles.small.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.0085,
                ),
                Text(
                  '${file.peso}MB',
                  style: textStyles.small.copyWith(
                    // fontWeight: FontWeight.normal,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () => onRemove(),
              padding: EdgeInsets.all(0),
              icon: Container(
                padding: EdgeInsets.all(size.height * 0.003),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red[600],
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: size.height * 0.02,
                ),
              ),
            )
          ],
        ),
      ),
    ),
  ];
}

List<Widget> _buildHeaderInfo(BuildContext context) {
  final textStyles = ShadTheme.of(context).textTheme;
  return [
    Text(
      'Adjuntar acta legal',
      style: textStyles.p.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      'Añade tu documento aquí, y solo puedes adjuntar 1 archivo como máximo',
      style: textStyles.small.copyWith(color: Colors.black54),
    ),
  ];
}

List<Widget> _buildBoxFileUpload(
  BuildContext context,
  FileInfo? file,
  EntregaEnvio entrega,
  void Function() onSetFile,
) {
  Size size = MediaQuery.of(context).size;
  final textStyles = ShadTheme.of(context).textTheme;

  return [
    DottedBorder(
      color: Colors.blue[700]!,
      dashPattern: const [6, 6, 6, 6],
      borderType: BorderType.RRect,
      radius: Radius.circular(12),
      padding: EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          height: size.height * 0.22,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.height * 0.08,
                height: size.height * 0.08,
                child: Image.asset('assets/logos/file.png'),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              ShadButton.outline(
                onPressed: () => onSetFile(),
                decoration: ShadDecoration(
                  border: ShadBorder.all(
                    color: Colors.blue[700]!,
                  ),
                ),
                size: ShadButtonSize.sm,
                child: Text(
                  entrega.urlActaLegal != null
                      ? file == null
                          ? 'Resubir archivo'
                          : 'Cambiar archivo resubido'
                      : file == null
                          ? 'Seleccione archivo'
                          : 'Cambiar archivo',
                  style: textStyles.small.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
              ),
              if (entrega.urlActaLegal != null)
                SizedBox(
                  height: size.height * 0.01,
                ),
              if (entrega.urlActaLegal != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.informationOutline,
                      color: Colors.red[300],
                      size: size.height * 0.02,
                    ),
                    SizedBox(
                      width: size.width * 0.012,
                    ),
                    Text(
                      'Hay una acta adjuntada',
                      style: textStyles.small.copyWith(
                        color: Colors.red[300],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
    SizedBox(height: size.height * 0.02),
    Text(
      'Solo archivos .jpg, jpeg, png, y .pdf',
      style: textStyles.small.copyWith(color: Colors.black54),
    ),
  ];
}

void _throwToastError(BuildContext context) {
  final textStyles = ShadTheme.of(context).textTheme;
  Size size = MediaQuery.of(context).size;
  ShadToaster.of(context).show(
    ShadToast.destructive(
      // padding: EdgeInsets.only(bottom: size.height * 0.1),
      offset: Offset(size.width * 0.05, size.height * 0.1),
      title: Row(
        children: [
          Icon(
            MdiIcons.informationOutline,
            color: Colors.white,
          ),
          SizedBox(width: size.width * 0.01),
          Text(
            'Ocurrio un error',
            style: textStyles.p.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      description: const Text('Hubo un fallo al subir el documento'),
    ),
  );
}

void _throwToastSuccess(BuildContext context) {
  final textStyles = ShadTheme.of(context).textTheme;
  Size size = MediaQuery.of(context).size;
  ShadToaster.of(context).show(
    ShadToast(
      backgroundColor: Colors.green,
      // padding: EdgeInsets.only(bottom: size.height * 0.1),
      offset: Offset(size.width * 0.05, size.height * 0.1),
      title: Row(
        children: [
          Icon(
            MdiIcons.handOkay,
            color: Colors.white,
          ),
          SizedBox(width: size.width * 0.01),
          Text(
            'Carga exitosa',
            style: textStyles.p.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      description: Text(
        'El documento se ha subido correctamente',
        style: textStyles.small.copyWith(
          color: Colors.white,
        ),
      ),
    ),
  );
}
