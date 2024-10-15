import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class HeaderLogin extends StatelessWidget {
  const HeaderLogin({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            height: size.height * 0.175,
            width: size.width,
            color: Colors.blue[600]!.withOpacity(.5),
          ),
        ),
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            height: size.height * 0.15,
            width: size.width,
            color: Colors.blue[600],
          ),
        ),
      ],
    );
  }
}
