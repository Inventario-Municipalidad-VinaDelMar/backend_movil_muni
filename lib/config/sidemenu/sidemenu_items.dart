import 'package:animated_icon/animated_icon.dart';

class MenuItem {
  final String title;
  final String subTitle;
  final String? link;
  final AnimateIcons icon;

  const MenuItem({
    required this.title,
    required this.subTitle,
    required this.icon,
    this.link,
  });
}

const List<MenuItem> sidemenuItems = [
  MenuItem(
    title: 'Envios',
    subTitle: 'Planifica un envío.',
    link: '/envio',
    icon: AnimateIcons.bell,
  ),
  MenuItem(
    title: 'Productos',
    subTitle: 'Añade productos.',
    link: '/tandas/add',
    icon: AnimateIcons.paid,
  ),
  MenuItem(
    title: 'Entregas',
    subTitle: 'Registra entregas.',
    link: '/',
    icon: AnimateIcons.compass,
  ),
  MenuItem(
    title: 'Cerrar Sesión',
    subTitle: 'Salir de la cuenta.',
    icon: AnimateIcons.skipBackwards,
  ),
];
