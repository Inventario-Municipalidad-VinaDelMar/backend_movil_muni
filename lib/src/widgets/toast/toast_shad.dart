import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void throwToastError({
  required BuildContext context,
  required String descripcion,
  bool? bottomMargin = false,
}) {
  final textStyles = ShadTheme.of(context).textTheme;
  Size size = MediaQuery.of(context).size;
  ShadToaster.of(context).show(
    ShadToast.destructive(
      duration: Duration(milliseconds: 1000),
      // padding: EdgeInsets.only(bottom: size.height * 0.1),
      offset: Offset(size.width * 0.05,
          bottomMargin! ? size.height * 0.1 : size.height * 0.02),
      title: Row(
        children: [
          Icon(
            MdiIcons.informationOutline,
            color: Colors.white,
          ),
          SizedBox(width: size.width * 0.01),
          Text(
            'Error inesperado',
            style: textStyles.p.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      description: Text(descripcion),
    ),
  );
}

void throwToastSuccess(
    {required BuildContext context,
    required String title,
    required String descripcion,
    bool? bottomMargin = false,
    int? duration = 1200}) {
  final textStyles = ShadTheme.of(context).textTheme;
  Size size = MediaQuery.of(context).size;
  ShadToaster.of(context).show(
    ShadToast(
      duration: Duration(milliseconds: duration!),
      backgroundColor: Colors.green,
      // padding: EdgeInsets.only(bottom: size.height * 0.1),
      offset: Offset(size.width * 0.05,
          bottomMargin! ? size.height * 0.1 : size.height * 0.02),
      title: Row(
        children: [
          Icon(
            MdiIcons.handOkay,
            color: Colors.white,
          ),
          SizedBox(width: size.width * 0.01),
          Text(
            title,
            style: textStyles.p.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      description: Text(
        descripcion,
        style: textStyles.small.copyWith(
          color: Colors.white,
        ),
      ),
    ),
  );
}
