import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // Importa la librería Shadcn Ui
import 'package:http/http.dart' as http;

class CustomAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CustomAvatar({
    super.key,
    required this.imageUrl,
    this.size = 50.0, // Tamaño por defecto del avatar
  });

  // Método que intenta cargar la imagen y devuelve la URL válida o una predeterminada
  Future<String> loadImage(String url) async {
    try {
      final response =
          await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return url;
      } else {
        return 'https://cdn.pixabay.com/animation/2023/10/08/03/19/03-19-26-213_512.gif'; // Imagen predeterminada si falla
      }
    } catch (e) {
      return 'https://cdn.pixabay.com/animation/2023/10/08/03/19/03-19-26-213_512.gif'; // Imagen predeterminada en caso de error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: loadImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return SizedBox(
            width: size,
            height: size,
            child: FadeIn(
              duration: Duration(milliseconds: 200),
              child: ShadAvatar(
                snapshot.data!,
                placeholder: SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    shape: BoxShape.circle,
                    width: size,
                    height: size,
                  ),
                ),
                size: Size(size, size),
                backgroundColor: Colors.transparent,
              ),
            ),
          );
        } else {
          // Mientras se carga la imagen, muestra el SkeletonAvatar
          return SizedBox(
            width: size,
            height: size,
            child: SkeletonAvatar(
              style: SkeletonAvatarStyle(
                shape: BoxShape.circle,
                width: size,
                height: size,
              ),
            ),
          );
        }
      },
    );
  }
}
